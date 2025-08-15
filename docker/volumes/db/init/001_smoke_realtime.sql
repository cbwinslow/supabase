-- Create a table and trigger to emit a NOTIFY payload on insert
-- This file will be executed at Postgres init if the volume init directory is used.

CREATE TABLE IF NOT EXISTS public.smoke_realtime (
  id serial PRIMARY KEY,
  data text NOT NULL,
  created_at timestamptz DEFAULT now()
);

CREATE OR REPLACE FUNCTION public.notify_smoke() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  PERFORM pg_notify('smoke_channel', json_build_object('id', NEW.id, 'data', NEW.data, 'created_at', NEW.created_at)::text);
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS smoke_realtime_notify ON public.smoke_realtime;
CREATE TRIGGER smoke_realtime_notify
  AFTER INSERT ON public.smoke_realtime
  FOR EACH ROW EXECUTE FUNCTION public.notify_smoke();

-- Ensure the extension for JSON functions exists (builtin in PG >= 9.4)


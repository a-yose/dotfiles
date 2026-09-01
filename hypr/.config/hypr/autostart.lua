-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Bring up the standing work layout at login. ws-layout is launch-or-focus
-- throughout, so this is also safe to re-run by hand afterwards.
--
-- o.launch_on_start wraps the command in `uwsm-app --` and runs it from the
-- compositor's environment, which is what keeps herdr happy: no HERDR_* vars
-- leak in, so the ws 2 entry doesn't trip herdr's nested-session guard.
o.launch_on_start("ws-layout")

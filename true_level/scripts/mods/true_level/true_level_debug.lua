local mod = get_mod("true_level")
local Profiler = rawget(_G, "Profiler")
local profiler_start = Profiler and Profiler.start
local profiler_stop = Profiler and Profiler.stop

mod._debug_mode = mod:get("enable_debug_mode")

mod.debug = {
    -- Profiler scopes are only recorded while debug mode is enabled.
    profile_start = function(scope)
        if mod._debug_mode and profiler_start then
            profiler_start(scope)
        end
    end,
    profile_stop = function(scope)
        if mod._debug_mode and profiler_stop then
            profiler_stop(scope)
        end
    end,
    dump = function(table, name, depth)
        if mod._debug_mode then
            mod:dump(table, name, depth)
        end
    end,
    echo = function(str, add)
        if mod._debug_mode then
            if add then
                for k, v in pairs(add) do
                    str = str .. "\n" .. k .. ": " .. v
                end
            end

            mod:echo(str)
        end
    end,
    compare = function(prev, now)
        if mod._debug_mode then
            mod.debug.echo("{#color(230,60,60)}BEFORE:{#reset()}", prev)
            mod.debug.echo("{#color(60,60,230)}AFTER:{#reset()}", now)
        end
    end,
}

mod:command("debug_true_level", "", function()
    mod:dump(mod._self, "self")
    mod:dump(mod._others, "others")
end)
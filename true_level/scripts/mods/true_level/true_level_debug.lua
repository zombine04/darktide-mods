local mod = get_mod("true_level")

mod._debug_mode = mod:get("enable_debug_mode")

mod.debug = {
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
}
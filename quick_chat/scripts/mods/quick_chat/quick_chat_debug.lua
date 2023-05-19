local mod = get_mod("quick_chat")

mod.debug = {
    echo = function(s)
        if mod:get("enable_debug_mode") then
            mod:echo(s)
        end
    end,
    echo_kv = function(k, v)
        if mod:get("enable_debug_mode") then
            mod:echo(tostring(k) .. ": " .. tostring(v))
        end
    end,
}
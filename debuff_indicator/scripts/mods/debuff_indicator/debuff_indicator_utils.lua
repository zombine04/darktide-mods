local mod = get_mod("debuff_indicator")

mod._is_major = function(buff_name)
    for _, v in ipairs(mod.buff_names) do
        if buff_name == v then
            return true
        end
    end

    return false
end

mod._is_dot = function(buff_name)
    for _, v in ipairs(mod.dot_names) do
        if buff_name == v then
            return true
        end
    end

    return false
end

mod._get_colored_text = function(buff_name, buff_display_name)
    local r = mod:get("color_r_" .. buff_name)
    local g = mod:get("color_g_" .. buff_name)
    local b = mod:get("color_b_" .. buff_name)

    return string.format("{#color(%s,%s,%s)}%s{#reset()}", r, g, b, buff_display_name)
end
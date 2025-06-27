local mod = get_mod("debuff_indicator")
local Breeds = require("scripts/settings/breed/breeds")

local _get_options = function()
    local options = {}

    for _, v in ipairs(mod.display_style_names) do
        options[#options + 1] = {
            text = "display_style_" .. v,
            value = v
        }
    end

    return options
end

local widgets = {
    {
        setting_id = "display_style",
        type = "dropdown",
        default_value = "both",
        tooltip = "display_style_options",
        options = _get_options(),
        sub_widgets = {
            {
                setting_id = "key_cycle_style",
                type = "keybind",
                default_value = {},
                keybind_trigger = "pressed",
                keybind_type = "function_call",
                function_name = "cycle_style",
            },
        }
    },
    {
        setting_id = "enable_filter",
        type = "checkbox",
        default_value = true,
        tooltip = "filter_disabled",
    },
    {
        setting_id = "distance",
        type = "numeric",
        default_value = 20,
        range = { 5, 80 },
    },
    {
        setting_id = "offset_z",
        type = "numeric",
        default_value = 20,
        range = { 0, 50 },
    },
    {
        setting_id = "font",
        type = "group",
        sub_widgets = {
            {
                setting_id = "font_size",
                type = "numeric",
                default_value = 20,
                range = { 1, 40 },
            },
            {
                setting_id = "font_opacity",
                type = "numeric",
                default_value = 255,
                range = { 0, 255 },
            },
        }
    },
}

local widgets_debuff = {}
local color_option = {}

local _is_duplicated = function(a)
    local join = function(t)
        return string.format("%s,%s,%s", t[2], t[3], t[4])
    end

    for i, table in ipairs(color_option) do
        local b = Color[table.text](255, true)

        if join(a) == join(b) then
            return true
        end
    end

    return false
end

for i, name in ipairs(Color.list) do
    if not _is_duplicated(Color[name](255, true)) then
        color_option[#color_option + 1] = { text = name, value = name }
    end
end

table.sort(color_option, function(a, b)
    return a.text < b.text
end)

for _, buff_name in ipairs(mod.buff_names) do
    if not string.match(buff_name, "psyker_protectorate_spread_charged") then
        widgets_debuff[#widgets_debuff + 1] = {
            setting_id = "group_" .. buff_name,
            type = "group",
            sub_widgets = {
                {
                    setting_id = "enable_" .. buff_name,
                    type = "checkbox",
                    default_value = true
                },
                {
                    setting_id = "color_" .. buff_name,
                    type = "dropdown",
                    default_value = "white_smoke",
                    options = table.clone(color_option)
                }
            }
        }
    end
end

for _, keyword in ipairs(mod.keywords) do
    widgets_debuff[#widgets_debuff + 1] = {
        setting_id = "group_" .. keyword,
        type = "group",
        sub_widgets = {
            {
                setting_id = "enable_" .. keyword,
                type = "checkbox",
                default_value = true
            },
            {
                setting_id = "color_" .. keyword,
                type = "dropdown",
                default_value = "white_smoke",
                options = table.clone(color_option)
            }
        }
    }
end

widgets[#widgets + 1] = {
    setting_id = "debuff_and_dot",
    type = "group",
    sub_widgets = widgets_debuff,
}

local widgets_breed = {
    {
        type = "minion",
        sub_widgets = {}
    },
    {
        type = "elite",
        sub_widgets = {}
    },
    {
        type = "specialist",
        sub_widgets = {}
    },
    {
        type = "monster",
        sub_widgets = {}
    },
    {
        type = "captain",
        sub_widgets = {}
    },
}

local _is_special_enemy = function(smart_tag_target_type)
    return smart_tag_target_type == "breed"
end

local _type_by_tags = function(tags)
    local type = "minion"

    if tags.elite then
        type = "elite"
    elseif tags.special then
        type = "specialist"
    elseif tags.monster then
        type = "monster"
    elseif tags.captain or tags.cultist_captain then
        type = "captain"
    end

    return type
end

for breed_name, breed in pairs(Breeds) do
    if breed_name ~= "chaos_plague_ogryn_sprayer" and
       breed.display_name ~= "loc_breed_display_name_undefined" and
       not mod.mutators[breed.name] then
        local default_value = _is_special_enemy(breed.smart_tag_target_type)
        local type = _type_by_tags(breed.tags)
        local index = table.find_by_key(widgets_breed, "type", type)
        local sub_widgets = widgets_breed[index].sub_widgets

        sub_widgets[#sub_widgets + 1] = {
            setting_id = breed_name,
            type = "checkbox",
            default_value = default_value,
        }
    end
end

for i, type_table in ipairs(widgets_breed) do
    local type = type_table.type
    local sub_widgets = type_table.sub_widgets

    if not table.is_empty(sub_widgets) then
        table.sort(sub_widgets, function(a, b)
            return a.setting_id < b.setting_id
        end)

        widgets[#widgets + 1] = {
            setting_id = "breed_" .. type,
            type = "group",
            sub_widgets = sub_widgets
        }
    end
end

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = widgets
    }
}

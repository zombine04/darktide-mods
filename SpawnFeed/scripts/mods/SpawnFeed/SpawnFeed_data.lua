local mod = get_mod("SpawnFeed")
local Breeds = require("scripts/settings/breed/breeds")

local widgets = {
    {
        setting_id = "enable_count_mode",
        type = "checkbox",
        default_value = true,
        tooltip = "tooltip_count_mode"
    },
    {
        setting_id = "notification_style",
        type = "group",
        sub_widgets = {
            {
                setting_id = "enable_combat_feed",
                type = "checkbox",
                default_value = true,
            },
            {
                setting_id = "enable_notification",
                type = "checkbox",
                default_value = false
            },
            {
                setting_id = "enable_chat",
                type = "checkbox",
                default_value = false
            }
        }
    }
}

local widgets_breed = {
    specialist = {},
    monster = {},
}

for breed_name, breed in pairs(Breeds) do
    local enemy_type = nil

    if breed_name ~= "chaos_plague_ogryn_sprayer" and
       breed.display_name ~= "loc_breed_display_name_undefined" then
        if not breed.ignore_detection_los_modifiers and not breed.boss_health_bar_disabled then
            if breed.tags.special then
                enemy_type = "specialist"
            elseif breed.tags.monster then
                enemy_type = "monster"
            end
        end

        if enemy_type and not string.match(breed_name, "_mutator$") then
            widgets_breed[enemy_type][#widgets_breed[enemy_type] + 1] = {
                setting_id = breed_name,
                type = "checkbox",
                default_value = true,
            }
        end
    end
end

for _type, sub_widgets in pairs(widgets_breed) do
    table.sort(sub_widgets, function(a, b)
        return a.setting_id < b.setting_id
    end)

    widgets[#widgets + 1] = {
        setting_id = "breed_" .. _type,
        type = "group",
        sub_widgets = sub_widgets
    }
end

widgets[#widgets + 1] = {
    setting_id = "debug",
    type = "group",
    sub_widgets = {
        {
            setting_id = "enable_debug_mode",
            type = "checkbox",
            default_value = false
        }
    }
}

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = widgets
    }
}
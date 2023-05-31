local mod = get_mod("book_finder")

local UISoundEvents = require("scripts/settings/ui/ui_sound_events")

local sound_events = {}
for k, v in pairs(UISoundEvents) do
    if not table.find_by_key(sound_events, "text", k) and
       not table.find_by_key(sound_events, "value", v)
    then
        sound_events[#sound_events + 1] = { text = k, value = v }
    end
end

table.sort(sound_events, function(a, b)
    return a.text < b.text
end)

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "search_distance",
                type = "numeric",
                default_value = 15,
                range = {1, 15},
            },
            {
                setting_id = "target",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "enable_grimoire",
                        type = "checkbox",
                        default_value = true,
                    },
                    {
                        setting_id = "enable_tome",
                        type = "checkbox",
                        default_value = true,
                    },
                }
            },
            {
                setting_id = "notifications",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "enable_chat_notif",
                        type = "checkbox",
                        default_value = true,
                    },
                    {
                        setting_id = "enable_popup_notif",
                        type = "checkbox",
                        default_value = false,
                    },
                    {
                        setting_id = "enable_pickup_notif",
                        type = "checkbox",
                        default_value = false,
                    },
                    {
                        setting_id = "enable_repeat_notif",
                        type = "checkbox",
                        default_value = false,
                        --[[sub_widgets = {
                            {
                                setting_id = "notif_delay",
                                type = "numeric",
                                default_value = 1000,
                                range = {0, 3000},
                            }
                        }]]
                    },
                    {
                        setting_id = "enable_sound_cue",
                        type = "checkbox",
                        default_value = true,
                        sub_widgets = {
                            {
                                setting_id = "sound_cue",
                                type = "dropdown",
                                default_value = "wwise/events/ui/play_ui_character_loadout_equip_armor",
                                options = sound_events
                            },
                        }
                    }
                }
            },
            {
                setting_id = "debug",
                type = "group",
                sub_widgets = {
                    {
                        setting_id = "enable_debug_mode",
                        type = "checkbox",
                        default_value = false,
                    },
                }
            },
        }
    }
}

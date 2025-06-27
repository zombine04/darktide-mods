local mod = get_mod("CollectibleFinder")

local UISoundEvents = require("scripts/settings/ui/ui_sound_events")

local _get_targets = function()
    local targets = {}

    for _, collectible_data in ipairs(mod._collectibles) do
        local name = collectible_data.name

        targets[#targets + 1] = {
            setting_id = "enable_" .. name,
            type = "checkbox",
            default_value = not collectible_data.disable_by_default,
        }
    end

    return targets
end

local _get_notif_action = function(collectible_data, loc)
    local actions = {}
    local name = collectible_data.name

    if collectible_data.is_destructible then
        actions[#actions + 1] = {
            setting_id = "enable_destruct_notif_" .. name,
            type = "checkbox",
            default_value = true,
        }
    else
        actions[#actions + 1] = {
            setting_id = "enable_pickup_notif_" .. name,
            type = "checkbox",
            default_value = true,
        }
    end

    if collectible_data.is_side_objective then
        actions[#actions + 1] = {
            setting_id = "enable_drop_notif_" .. name,
            type = "checkbox",
            default_value = true,
        }
        actions[#actions + 1] = {
            setting_id = "enable_give_notif_" .. name,
            type = "checkbox",
            default_value = true,
        }
    end

    return actions
end

local _get_sound_events = function()
    local sound_events = {}

    for k, v in pairs(UISoundEvents) do
        if not table.find_by_key(sound_events, "text", k) and
        not table.find_by_key(sound_events, "value", v) and
        not string.match(k, "start") and
        not string.match(k, "stoo") and
        not string.match(v, "start") and
        not string.match(v, "stoo")
        then
            sound_events[#sound_events + 1] = { text = k, value = v }
        end
    end

    table.sort(sound_events, function(a, b)
        return a.text < b.text
    end)

    return sound_events
end

local _get_color_options = function()
    local color_options = {}

    local _is_duplicated = function(a)
        local join = function(t)
            return string.format("%s,%s,%s", t[2], t[3], t[4])
        end

        for i, table in ipairs(color_options) do
            local b = Color[table.text](255, true)

            if join(a) == join(b) then
                return true
            end
        end

        return false
    end

    for i, name in ipairs(Color.list) do
        if not _is_duplicated(Color[name](255, true)) then
            color_options[#color_options + 1] = { text = name, value = name }
        end
    end

    table.sort(color_options, function(a, b)
        return a.text < b.text
    end)

    return color_options
end

local _get_detail_settings = function()
    local settings = {}

    for _, collectible_data in ipairs(mod._collectibles) do
        local name = collectible_data.name
        local loc = collectible_data.loc

        settings[#settings + 1] = {
            setting_id = name,
            type = "group",
            sub_widgets = {
                {
                    setting_id = "search_distance_" .. name,
                    type = "numeric",
                    default_value = 15,
                    range = { 1, 20 },
                },
                {
                    setting_id = "enable_icon_indicator_" .. name,
                    type = "checkbox",
                    default_value = true,
                    sub_widgets = {
                        {
                            setting_id = "icon_size_" .. name,
                            type = "numeric",
                            default_value = 60,
                            range = { 20, 100 }
                        },
                        {
                            setting_id = "icon_color_" .. name,
                            type = "dropdown",
                            default_value = "terminal_icon",
                            options = _get_color_options()
                        }
                    }
                },
                {
                    setting_id = "notif_type_" .. name,
                    type = "dropdown",
                    default_value = "type_chat",
                    options = {
                        { text = "type_chat", value = "type_chat" },
                        { text = "type_notif", value = "type_notif" },
                        { text = "type_both", value = "type_both" },
                    },
                    sub_widgets = _get_notif_action(collectible_data, loc)

                },
                {
                    setting_id = "enable_repeat_notif_" .. name,
                    type = "checkbox",
                    default_value = false,
                },
                {
                    setting_id = "enable_sound_cue_" .. name,
                    type = "checkbox",
                    default_value = true,
                    sub_widgets = {
                        {
                            setting_id = "sound_cue_" .. name,
                            type = "dropdown",
                            default_value = "wwise/events/ui/play_ui_character_loadout_equip_armor",
                            options = _get_sound_events()
                        },
                    }
                }
            },
        }
    end

    return settings
end

return {
    name = mod:localize("mod_name"),
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id = "toggle",
                type = "group",
                sub_widgets = _get_targets()
            },
            {
                setting_id = "details",
                type = "group",
                sub_widgets = _get_detail_settings()
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

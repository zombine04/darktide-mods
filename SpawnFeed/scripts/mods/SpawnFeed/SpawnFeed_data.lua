local mod = get_mod("SpawnFeed")
local Breeds = require("scripts/settings/breed/breeds")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")

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
    -- if not _is_duplicated(Color[name](255, true)) then
        color_options[#color_options + 1] = { text = name, value = name }
    -- end
end

table.sort(color_options, function(a, b)
    return a.text < b.text
end)

table.insert(color_options, 1, { text = "default", value = "default" })

local sound_options = {}

for k, v in pairs(UISoundEvents) do
    if not table.find_by_key(sound_options, "text", k) and
    not table.find_by_key(sound_options, "value", v) and
    not string.match(k, "start") and
    not string.match(k, "stop") and
    not string.match(v, "start") and
    not string.match(v, "stop")
    then
        sound_options[#sound_options + 1] = { text = k, value = v }
    end
end

table.sort(sound_options, function(a, b)
    return a.text < b.text
end)

table.insert(sound_options, 1, { text = "none", value = "none" })

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

local _sub_widget_template = function(breed_name, default_value)
    return {
        setting_id = breed_name,
        type = "checkbox",
        default_value = default_value,
        sub_widgets = {
            {
                setting_id = "color_" .. breed_name,
                type = "dropdown",
                default_value = "default",
                options = table.clone(color_options)
            },
            {
                setting_id = "sound_" .. breed_name,
                type = "dropdown",
                default_value = "none",
                options =  table.clone(sound_options)
            }
        }
    }
end

for breed_name, breed in pairs(Breeds) do
    local enemy_type = nil

    if breed_name ~= "chaos_plague_ogryn_sprayer" and
       breed.display_name ~= "loc_breed_display_name_undefined" then
        if breed.tags.special then
            enemy_type = "specialist"
        elseif breed.tags.monster then
            enemy_type = "monster"
        elseif breed.tags.captain or breed.tags.cultist_captain then
            enemy_type = "captain"
        end

        if enemy_type and not string.match(breed_name, "_mutator$") then
            local default_value = not breed.tags.sniper and not breed.tags.witch
            local index = table.find_by_key(widgets_breed, "type", enemy_type)
            local sub_widgets = widgets_breed[index].sub_widgets

            sub_widgets[#sub_widgets + 1] = _sub_widget_template(breed_name, default_value)

            if breed.tags.monster and not breed.tags.witch then
                sub_widgets[#sub_widgets + 1] = _sub_widget_template(breed_name .. "_weakened", default_value)
            end
        end
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
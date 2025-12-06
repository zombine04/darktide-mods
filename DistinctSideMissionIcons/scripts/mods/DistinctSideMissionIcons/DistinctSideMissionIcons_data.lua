local mod = get_mod("DistinctSideMissionIcons")
local MissionObjectiveTemplates = require("scripts/settings/mission_objective/mission_objective_templates")
local PresetSettings = require("scripts/ui/view_elements/view_element_profile_presets/view_element_profile_presets_settings")
local SideObjectives = MissionObjectiveTemplates.side_mission.objectives

local default_settings = {
    default = {
        icon = "content/ui/materials/icons/mission_types/mission_type_side",
        color = "default",
    },
    side_mission_tome = {
        icon = "content/ui/materials/icons/pocketables/hud/scripture",
        color = "light_yellow",
    },
    side_mission_grimoire = {
        icon = "content/ui/materials/icons/pocketables/hud/grimoire",
        color = "light_green",
    },
    side_mission_hack_communications = {
        icon = "content/ui/materials/icons/pocketables/hud/corrupted_auspex_scanner",
        color = "light_salmon",
    },
}
local options = {}

-- icons

local _get_preset_icons = function()
    local icons = {}

    for i, key in ipairs(PresetSettings.optional_preset_icon_reference_keys) do
        local suffix = i < 10 and "0" .. tostring(i) or tostring(i)
        local icon = PresetSettings.optional_preset_icons_lookup[key]

        icons[#icons + 1] = {
            text = "preset_" .. suffix,
            value = icon
        }
    end

    return icons
end

options.icon = {
    { text = "default", value = default_settings.default.icon },
    { text = "scripture", value = default_settings.side_mission_tome.icon },
    { text = "scripture_small", value = "content/ui/materials/icons/pocketables/hud/small/party_scripture" },
    { text = "grimoire", value = default_settings.side_mission_grimoire.icon },
    { text = "grimooire_small", value = "content/ui/materials/icons/pocketables/hud/small/party_grimoire" },
    { text = "auspex", value = default_settings.side_mission_hack_communications.icon },
    { text = "auspex_small", value = "content/ui/materials/icons/pocketables/hud/small/party_corrupted_auspex_scanner" },
}

table.append(options.icon, _get_preset_icons())

-- color

options.color = {}

local _is_duplicated = function(a)
    local join = function(t)
        return string.format("%s,%s,%s", t[2], t[3], t[4])
    end

    for i, table in ipairs(options.color) do
        local b = Color[table.text](255, true)

        if join(a) == join(b) then
            return true
        end
    end

    return false
end

for i, name in ipairs(Color.list) do
    -- if not _is_duplicated(Color[name](255, true)) then
        options.color[#options.color + 1] = { text = name, value = name }
    -- end
end

table.sort(options.color, function(a, b)
    return a.text < b.text
end)

table.insert(options.color, 1, { text = "default", value = "default" })

-- group

local _get_default_value = function(objective_name, key)
    return default_settings[objective_name] and default_settings[objective_name][key] or default_settings.default[key]
end

local _get_group = function(objective_name)
    return {
        setting_id = objective_name,
        type = "group",
        sub_widgets = {
            {
                setting_id = "icon_" .. objective_name,
                type = "dropdown",
                default_value = _get_default_value(objective_name, "icon"),
                options = table.clone(options.icon)
            },
            {
                setting_id = "color_" .. objective_name,
                type = "dropdown",
                default_value = _get_default_value(objective_name, "color"),
                options = table.clone(options.color)
            }
        }
    }
end

-- widgts

local widgets = {}

for objective_name, data in pairs(SideObjectives) do
    if data.is_testable and objective_name ~= "side_mission_consumable" then
        widgets[#widgets + 1] = _get_group(objective_name)
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

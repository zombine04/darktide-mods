--[[
    title: SpawnFeed
    author: Zombine
    date: 08/07/2023
    version: 1.0.0
]]
local mod = get_mod("SpawnFeed")
local FeedSettings = require("scripts/ui/hud/elements/combat_feed/hud_element_combat_feed_settings")
local TextUtils = require("scripts/utilities/ui/text")

local _color_by_enemy_tags = function(tags)
    local color = nil

    if tags then
		local colors_by_enemy_type = FeedSettings.colors_by_enemy_type

		for key, enemy_color in pairs(colors_by_enemy_type) do
			if tags[key] then
				color = enemy_color

				break
			end
		end
	end

	return color or Color.red(255, true)
end

local _get_unit_presentation_name = function(unit)
    local unit_data_extension = ScriptUnit.has_extension(unit, "unit_data_system")
    local breed = unit_data_extension and unit_data_extension:breed()

    if breed then
        if breed.ignore_detection_los_modifiers or breed.boss_health_bar_disabled then
            return
        end

        local display_name = breed.display_name
        local tags = breed.tags
        local color = _color_by_enemy_tags(tags)

        return display_name and TextUtils.apply_color_to_text(Localize(display_name), color)
    end
end

local _check_enemy_type = function(breed)
    local is_valid = false

    if breed then
        local tags = breed.tags

        if tags and tags.special or tags.monster then
            is_valid = true
        end
    end

    return is_valid
end

local on_enemy_spawned = function(_, _, unit)
    local unit_data_ext = ScriptUnit.extension(unit, "unit_data_system")
    local breed = unit_data_ext and unit_data_ext:breed()
    local is_sipecial_or_monster = _check_enemy_type(breed)

    if is_sipecial_or_monster and ALIVE[unit] then
        local display_name = _get_unit_presentation_name(unit)

        if display_name then
            local message = mod:localize("spawn_message", display_name)

            if mod:get("enable_combat_feed") then
                Managers.event:trigger("event_add_combat_feed_message", message)
            end

            if mod:get("enable_chat") then
                mod:echo(message)
            end

            if mod:get("enable_notification") then
                mod:notify(message)
            end
        end
    end
end

mod:hook_safe("HealthExtension", "init", on_enemy_spawned)
mod:hook_safe("HuskHealthExtension", "init", on_enemy_spawned)
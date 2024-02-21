--[[
    title: SpawnFeed
    author: Zombine
    date: 2024/02/22
    version: 1.1.2
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

local _on_enemy_spawned = function(_, _, unit)
    local unit_data_ext = ScriptUnit.extension(unit, "unit_data_system")
    local breed = unit_data_ext and unit_data_ext:breed()
    local is_sipecial_or_monster = _check_enemy_type(breed)

    if is_sipecial_or_monster and ALIVE[unit] then
        local breed_name = string.match(breed.name, "(.+)_mutator$") or breed.name

        if not mod:get(breed_name) then
            return
        end

        local display_name = _get_unit_presentation_name(unit)

        if display_name then
            local message = mod:localize("spawn_message", display_name)

            if mod:get("enable_combat_feed") then
                if mod:get("enable_count_mode") then
                    Managers.event:trigger("event_add_combat_feed_message", {
                        is_spawned = true,
                        breed = breed_name,
                        message = message
                    })
                else
                    Managers.event:trigger("event_add_combat_feed_message", message)
                end
            end

            if mod:get("enable_notification") then
                if mod:get("enable_count_mode") then
                    Managers.event:trigger("event_add_notification_message", "default", {
                        is_spawned = true,
                        breed = breed_name,
                        message = message
                    })
                else
                    Managers.event:trigger("event_add_notification_message", "default", message)
                end
            end

            if mod:get("enable_chat") then
                mod:echo(message)
            end

        end
    end
end

mod:hook_safe("HealthExtension", "init", _on_enemy_spawned)
mod:hook_safe("HuskHealthExtension", "init", _on_enemy_spawned)

mod:hook("HudElementCombatFeed", "_enabled", function(func, self)
    if mod:get("enable_debug_mode") then
        return true
    end

    return func(self)
end)

mod:hook("HudElementCombatFeed", "_add_combat_feed_message", function(func, self, data)
    if not self:_enabled() then
        return
    end

    local kfi = get_mod("KillfeedImprovements")
    local kfi_is_enabled = kfi and kfi:is_enabled()
    local notification, notification_id = self:_add_notification_message("default")

    if type(data) == "table" and data.is_spawned then
        for i, notification in ipairs(self._notifications) do
            if notification.is_spawned and notification.breed == data.breed then
                data.count = notification.count and notification.count + 1 or 1
                self:_remove_notification(notification.id)
                break
            end
        end

        local message = data.message

        if data.count and data.count > 1 then
            message = message .. " x" .. tostring(data.count)
        end

        notification.is_spawned = true
        notification.breed = data.breed
        notification.count = data.count or 1

        data = message
    end

    self:_set_text(notification_id, data)

    if kfi_is_enabled then
        return notification, notification_id
    end
end)

mod:hook("ConstantElementNotificationFeed", "_add_notification_message", function(func, self, message_type, data, ...)
    if message_type == "default" and type(data) == "table" and data.is_spawned then
        for i, notification in ipairs(self._notifications) do
            if notification.is_spawned and notification.breed == data.breed then
                data.count = notification.count and notification.count + 1 or 1
                self:event_remove_notification(notification.id)
                break
            end
        end

        local message = data.message

        if data.count and data.count > 1 then
            message = message .. " x" .. tostring(data.count)
        end

        local notification_data = self:_generate_notification_data(message_type, message)

        if notification_data then
            local notification = self:_create_notification_entry(notification_data)

            notification.is_spawned = true
            notification.breed = data.breed
            notification.count = data.count or 1

            if notification.animation_enter then
                self:_start_animation(notification.animation_enter, notification.widget)
            end
        end
    else
        func(self, message_type, data, ...)
    end
end)

mod:hook("UIHud", "init", function(func, self, elements, visibility_groups, params)
    if mod:get("enable_debug_mode") and not table.find_by_key(elements, "class_name", "HudElementCombatFeed") then
        table.insert(elements, {
            use_hud_scale = true,
            class_name = "HudElementCombatFeed",
            filename = "scripts/ui/hud/elements/combat_feed/hud_element_combat_feed",
            visibility_groups = {
                "dead",
                "alive",
                "communication_wheel",
                "tactical_overlay"
            }
        })
    end

    return func(self, elements, visibility_groups, params)
end)
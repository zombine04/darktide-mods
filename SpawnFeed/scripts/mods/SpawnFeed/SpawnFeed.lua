local mod = get_mod("SpawnFeed")
local FeedSettings = require("scripts/ui/hud/elements/combat_feed/hud_element_combat_feed_settings")
local TextUtils = require("scripts/utilities/ui/text")
local weakened_suffix = "_weakened"

mod._info = {
    title = "Spawn Feed",
    author = "Zombine",
    date = "2025/06/27",
    version = "1.2.4"
}
mod:info("Version " .. mod._info.version)

local _is_weakened = function(unit, breed)
    local is_weakened = false

    if not breed.is_boss or breed.ignore_weakened_boss_name then
        return is_weakened
    end

    local health_extension = ScriptUnit.extension(unit, "health_system")
    local max_health = health_extension:max_health()
    local initial_max_health = math.floor(Managers.state.difficulty:get_minion_max_health(breed.name))

    if max_health < initial_max_health then
        is_weakened = true
    else
        local havoc_mananger = Managers.state.havoc

        if havoc_mananger:is_havoc() then
            local havoc_health_override_value = havoc_mananger:get_modifier_value("modify_monster_health")

            if havoc_health_override_value then
                local multiplied_max_health = initial_max_health + initial_max_health * havoc_health_override_value

                if max_health < multiplied_max_health then
                    is_weakened = true
                end
            end
        end
    end

    return is_weakened
end

local _color_by_enemy_tags = function(tags, breed_name)
    local color = nil
    local mod_color = mod:get("color_" .. breed_name)

    if mod_color and mod_color ~= "default" and Color[mod_color] then
        color = Color[mod_color](255, true)
    elseif tags then
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

local _get_unit_presentation_name = function(breed, breed_name, is_weakened, boss_extension)
    local display_name = breed.display_name

    if boss_extension then
        display_name = boss_extension:display_name()
    end

    local tags = breed.tags
    local color = _color_by_enemy_tags(tags, breed_name)
    local localized_display_name = Localize(display_name)

    if is_weakened then
        localized_display_name = Localize("loc_weakened_monster_prefix", true, {
            breed = localized_display_name
        })
    end

    return localized_display_name and TextUtils.apply_color_to_text(localized_display_name, color)
end

local _get_base_name = function(breed_name)
    return breed_name:gsub("_mutator$", "")
end

local _on_enemy_spawned = function(unit, breed, breed_name)
    local boss_extension = ScriptUnit.extension(unit, "boss_system")
    local is_weakened = _is_weakened(unit, breed)

    if is_weakened then
        breed_name = breed_name .. weakened_suffix
    end

    if mod:get(breed_name) then
        local display_name = _get_unit_presentation_name(breed, breed_name, is_weakened, boss_extension)

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

            local sound_event = mod:get("sound_" .. breed_name)

            if sound_event and sound_event ~= "none" then
                Managers.ui:play_2d_sound(sound_event)
            end
        end
    end
end

-- ############################################################
-- Specialist
-- ############################################################

local _on_specialist_spawned = function(_, _, unit)
    if not ALIVE[unit] then
        return
    end

    local unit_data_ext = ScriptUnit.extension(unit, "unit_data_system")
    local breed = unit_data_ext and unit_data_ext:breed()
    local breed_name = breed and _get_base_name(breed.name)

    if not breed_name or breed.is_boss then
        return
    end

    _on_enemy_spawned(unit, breed, breed_name)
end

mod:hook_safe("HealthExtension", "init", _on_specialist_spawned)
mod:hook_safe("HuskHealthExtension", "init", _on_specialist_spawned)

-- ############################################################
-- Boss
-- ############################################################

mod:hook_safe("BossExtension", "extensions_ready", function(self)
    local unit = self._unit

    if not ALIVE[unit] then
        return
    end

    local breed = self._breed
    local breed_name = breed and _get_base_name(breed.name)

    if breed_name then
        _on_enemy_spawned(unit, breed, breed_name)
    end
end)

-- ############################################################
-- Modify Combat Feed
-- ############################################################

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

-- ############################################################
-- Modify Notification
-- ############################################################

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

-- ############################################################
-- Enable Combat Feed in Psykahnium (Debug)
-- ############################################################

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

mod.on_setting_changed = function(id)
    if id:match("^sound_") then
        local sound_event = mod:get(id)

        if sound_event ~= "none" then
            Managers.ui:play_2d_sound(sound_event)
        end
    end
end
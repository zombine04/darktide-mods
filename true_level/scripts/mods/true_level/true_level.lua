--[[
    title: true_level
    author: Zombine
    date: 2024/06/28
    version: 1.6.3
]]
local mod = get_mod("true_level")
local ProfileUtils = require("scripts/utilities/profile_utils")

mod._symbols = {
--  damage = "\xEE\x80\xA6",
--  exp = "\xEE\x80\xB2",
    level = "\xEE\x80\x86",
--  penance = "\xEE\x81\x81",
--  rating = "\xEE\x80\x9F",
--  skull = "\xEE\x80\x9E",
}
mod._self = mod:persistent_table("self")
mod._others = mod:persistent_table("others")
mod._queue = mod:persistent_table("queue")
mod._xp_settings = mod:persistent_table("xp_settings")
mod._xp_promise = nil
mod._synced = {}
mod._is_in_hub = false

mod._fetch_xp_settings = function()
    local xp_settings = mod._xp_settings

    if table.is_empty(xp_settings) and not mod._xp_promise then
        local backend_interface = Managers.backend.interfaces
        local xp_promise = backend_interface.progression:get_xp_table("character")

        mod._xp_promise = true
        mod:info("fetching xp settings...")

        xp_promise:next(function(xp_per_level_array)
            local max_level = #xp_per_level_array

            xp_settings.level_array = xp_per_level_array
            xp_settings.total_xp = xp_per_level_array[max_level]
            xp_settings.max_level = max_level
            mod.debug.dump(xp_settings, "xp_settings")

            local queue = mod._queue

            if not table.is_empty(queue) then
                for char_id, arg in pairs(queue) do
                    mod.cache_true_levels(arg[1], arg[2], arg[3])
                    queue[char_id] = nil
                end
            end

            mod._xp_promise = nil
            mod.desync_all()
        end):catch(function(e)
            mod:dump(e, "xp_settings", 3)
        end)
    end
end

local _populate_data = function(base_data)
    local xp_settings = mod._xp_settings
    local level_array = xp_settings.level_array
    local total_xp = xp_settings.total_xp
    local max_level = xp_settings.max_level
    local current_level = base_data.currentLevel
    local current_xp = base_data.currentXp
    local current_xp_in_level = base_data.currentXpInLevel
    local needed_xp_for_next = base_data.neededXpForNextLevel
    local true_levels = {
        current_xp = current_xp,
        current_level = current_level,
    }

    if current_level < max_level then
        true_levels.xp_per_level = level_array[current_level + 1] - level_array[current_level]
        true_levels.remaining_xp = current_xp_in_level
        true_levels.needed_xp = needed_xp_for_next
    else
        local xp_per_level = level_array[max_level] - level_array[max_level - 1] -- 11,100
        local xp_over_max_level = current_xp - total_xp
        local remaining_xp = xp_over_max_level % xp_per_level
        local additional_level = math.floor(xp_over_max_level / xp_per_level)
        local true_level = current_level + additional_level

        true_levels.xp_per_level = xp_per_level
        true_levels.remaining_xp = remaining_xp
        true_levels.needed_xp = xp_per_level - remaining_xp
        true_levels.additional_level = additional_level
        true_levels.true_level = true_level
        true_levels.prestige = math.floor(current_xp / total_xp)
    end

    return true_levels
end

mod.cache_true_levels = function(self_or_others, character_id, base_data)
    if table.is_empty(mod._xp_settings) then
        mod._fetch_xp_settings()

        local queue = mod._queue

        if not queue[character_id] then
            queue[character_id] = {
                self_or_others,
                character_id,
                base_data
            }
        end

        return
    end

    local true_levels = _populate_data(base_data)

    self_or_others[character_id] = true_levels
    mod.debug.dump(true_levels, character_id)
end

local _get_best_setting = function(base_id, reference)
    local setting_id = base_id .. "_" .. reference
    local setting = mod:get(setting_id)

    if setting == "use_global" then
        setting = mod:get(base_id)
    elseif base_id:match("enable_prestige") then
        setting = setting == "on" and true or false
    end

    return setting
end

mod.replace_level = function(text, true_levels, reference, need_adding)
    local display_style = _get_best_setting("display_style", reference)
    local show_prestige = _get_best_setting("enable_prestige_level", reference)
    local show_prestige_only = _get_best_setting("enable_prestige_only", reference)
    local prestige_color = _get_best_setting("prestige_level_color", reference)
    local current_level = true_levels.current_level
    local additional_level = true_levels.additional_level
    local true_level = true_levels.true_level
    local prestige = true_levels.prestige
    local suffix = " " .. mod.get_symbol()

    local _has_title = function (text)
        local t = {}

        for s in text:gmatch("[^\n]+") do
            t[#t + 1] = s
        end

        return #t > 1, t[1], t[2]
    end

    if need_adding then
        local has_title, player_name, title = _has_title(text)

        if has_title then
            text = player_name
        end

        text = text:gsub("\n", "") .. " - "

        if display_style == "total" and true_level then
            text = text .. true_level
        elseif display_style == "separate" and additional_level then
            text = text .. current_level .. " (+" .. additional_level .. ")"
        else -- default
            text = text .. current_level
        end

        text = text .. suffix

        if title then
            text = text .. "\n" .. title
        end
    else
        if display_style == "total" and true_level then
            text = text:gsub("%d+" .. suffix, true_level .. suffix)
        elseif display_style == "separate" and additional_level then
            text = text:gsub(suffix, " (+" .. additional_level .. ")" .. suffix)
        end
    end

    if show_prestige and prestige then
        local suffix_with_prestige = suffix .. prestige

        text = text:gsub(suffix .. "[^\n%s]*", suffix)

        if prestige_color ~= "default" then
            local c = Color[prestige_color](255, true)
            local color_prefix = string.format("{#color(%s,%s,%s)}", c[2], c[3], c[4])

            suffix_with_prestige = color_prefix .. suffix_with_prestige .. "{#reset()}"
        end

        if show_prestige_only then
            text = text:gsub("%s?%d+" .. suffix, suffix_with_prestige) -- total
            text = text:gsub("%s?%d+ %(%+%d+%)" .. suffix, suffix_with_prestige) -- separate
        else
            text = text:gsub(suffix, suffix_with_prestige)
        end
    end

    return text
end

mod.get_true_levels = function(character_id)
    if character_id then
        if mod._self[character_id] then
            return mod._self[character_id], true
        elseif mod._others[character_id] then
            return mod._others[character_id], false
        end
    end

    return nil
end

mod.get_symbol = function(key)
    key = key or "level"

    return mod._symbols[key]
end

mod.is_enabled_feature = function(ref)
    return mod:is_enabled() and mod:get("enable_" .. ref)
end

mod.should_replace = function(ref)
    if mod.is_enabled_feature(ref) and not mod._synced[ref] then
        return true
    end

    return false
end

mod.is_ready = function(target, key)
    local wru = get_mod("who_are_you")
    local can_replace = false

    if wru and wru:is_enabled() and wru:get("enable_" .. key) then
        can_replace = target.wru_modified and not target.tl_modified
    else
        can_replace = not target.tl_modified
    end

    return can_replace
end

mod.clear_cache = function ()
    table.clear(mod._others)
end

mod.synced = function(ref)
    mod._synced[ref] = true
end

mod.desynced = function(ref)
    mod._synced[ref] = false
end

mod.desync_all = function()
    for _, element in ipairs(mod._elements) do
        mod._synced[element] = false
    end
end

mod.desync_all()

-- ############################################################
-- Load Files
-- ############################################################

for _, element in ipairs(mod._elements) do
    local path = "true_level/scripts/mods/true_level/elements/" .. element

    mod:io_dofile(path)
end

mod:io_dofile("true_level/scripts/mods/true_level/true_level_debug")

-- ############################################################
-- Get Character Progression
-- ############################################################

mod:hook_safe(CLASS.PresenceEntryImmaterium, "_process_character_profile_convert", function(self, new_entry)
    local key_values = new_entry.key_values
    local character_profile = key_values and key_values.character_profile
    local character_id = key_values and key_values.character_id and key_values.character_id.value
    local cache = mod._others

    if character_profile and character_id and not cache[character_id] then
        local backend_profile_data = ProfileUtils.process_backend_body(cjson.decode(character_profile.value))
        local backend_progression = backend_profile_data.progression

        mod.cache_true_levels(cache, character_id, backend_progression)
    end
end)

-- ############################################################
-- Remove Cached Progression
-- ############################################################

local _is_in_hub = function()
    local game_mode_manager = Managers.state.game_mode
    local game_mode_name = game_mode_manager and game_mode_manager:game_mode_name()

    return game_mode_name == "hub"
end

mod:hook_safe("UIHud", "init", function(self)
    mod._is_in_hub = _is_in_hub()
end)

mod.on_game_state_changed = function(status, state_name)
    if state_name == "StateGameplay" and status == "exit" and mod._is_in_hub then
        mod.clear_cache()
        mod._is_in_hub = false
        mod.debug.echo("Cache Cleared")
    end
end

mod.on_setting_changed = function(id)
    mod._debug_mode = mod:get("enable_debug_mode")
    mod._is_in_hub = _is_in_hub()

    for _, element in pairs(mod._elements) do
        mod.desynced(element)
    end
end
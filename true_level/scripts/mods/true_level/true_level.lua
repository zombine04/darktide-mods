local mod = get_mod("true_level")

mod._info = {
    title = "True Level",
    author = "Zombine",
    date = "2025/12/03",
    version = "1.9.4",
}
mod:info("Version " .. mod._info.version)

local ProfileUtils = require("scripts/utilities/profile_utils")

mod._self = mod:persistent_table("self")
mod._others = mod:persistent_table("others")
mod._queue = mod:persistent_table("queue")
mod._havoc_promises = mod:persistent_table("havoc")
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
                for char_id, args in pairs(queue) do
                    mod.cache_true_levels(unpack(args))
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

local _populate_data = function(base_data, havoc_rank_cadence_high)
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
        true_levels.havoc_rank = havoc_rank_cadence_high
    end

    return true_levels
end

mod.cache_true_levels = function(self_or_others, character_id, base_data, havoc_rank_cadence_high, account_id)
    if table.is_empty(mod._xp_settings) then
        mod._fetch_xp_settings()

        local queue = mod._queue

        if not queue[character_id] then
            queue[character_id] = {
                self_or_others,
                character_id,
                base_data,
                havoc_rank_cadence_high,
                account_id
            }
        end

        return
    end

    local true_levels = _populate_data(base_data, havoc_rank_cadence_high)

    true_levels.account_id = account_id
    self_or_others[character_id] = true_levels
    mod.debug.dump(true_levels, character_id)
end

local _get_best_setting = function(base_id, reference)
    local setting_id = base_id .. "_" .. reference
    local setting = mod:get(setting_id)
    local global_setting = mod:get(base_id)

    if setting == "use_global" then
        setting = global_setting
    elseif type(global_setting) == "boolean" then
        setting = setting == "on" and true or false
    end

    return setting
end

local t = {}

local _has_title = function(text)
    t = {}

    for s in text:gmatch("[^\n]+") do
        t[#t + 1] = s
    end

    return #t > 1, t[1], t[2]
end

local _apply_color_to_text = function(color_code, text)
    local c = Color[color_code](255, true)
    local color_prefix = string.format("{#color(%s,%s,%s)}", c[2], c[3], c[4])

    return color_prefix .. text .. "{#reset()}"
end

local levels = {
    {
        key = "level",
        val = ""
    },
    {
        key = "prestige_level",
        val = ""
    },
    {
        key = "havoc_rank",
        val = ""
    }
}

local _init_levels = function()
    for i = 1, #levels do
        local level = levels[i]

        level.val = ""
    end
end

local _concat_levels = function(ref)
    local result = ""
    local len = #levels

    for i = 1, len do
        local level = levels[i]
        if level.val ~= "" then
            local level_text = level.val .. " " .. mod.get_symbol(level.key .. "_custom")
            local color_code =  _get_best_setting(level.key .. "_color", ref)

            if color_code and color_code ~= "default" and Color[color_code]then
                level_text = _apply_color_to_text(color_code, level_text)
            end

            if result ~= "" then
                result = result .. " "
            end

            result = result .. level_text
        end
    end

    return result
end

mod.replace_level = function(text, true_levels, reference, need_adding)
    _init_levels()

    mod._symbols.level_custom = _get_best_setting("level_icon", reference)
    mod._symbols.prestige_level_custom = _get_best_setting("prestige_level_icon", reference)
    mod._symbols.havoc_rank_custom = _get_best_setting("havoc_rank_icon", reference)

    local display_style = _get_best_setting("display_style", reference)
    local show_prestige = _get_best_setting("enable_prestige_level", reference)
    local show_havoc_rank = _get_best_setting("enable_havoc_rank", reference)
    local disable_normal_level = _get_best_setting("prioritize_other_levels", reference)
    local current_level = true_levels.current_level
    local additional_level = true_levels.additional_level
    local true_level = true_levels.true_level
    local prestige = true_levels.prestige
    local havoc_rank = true_levels.havoc_rank
    local level_icon = mod.get_symbol()
    local suffix = " " .. level_icon
    local has_title, player_name, title = _has_title(text)

    if has_title then
        text = player_name
    else
        text = text:gsub("\n", "")
    end

    if need_adding then
        text = text:gsub("%s+%-%s+%d.+", "")
    end

    if display_style ~= "none" then
        if display_style == "total" and true_level then
            levels[1].val = true_level
        elseif display_style == "separate" and additional_level then
            levels[1].val = current_level .. " (+" .. additional_level .. ")"
        else -- default
            levels[1].val = current_level
        end
    end

    if show_prestige and prestige then
        levels[2].val = prestige
    end

    if show_havoc_rank then
        local account_id = true_levels.account_id

        if havoc_rank then
            levels[3].val = havoc_rank
        elseif account_id and true_level and not mod._havoc_promises[account_id] then
            local promise = Managers.data_service.havoc:havoc_rank_cadence_high(account_id)

            promise:next(function(rank)
                mod._havoc_promises[account_id] = nil
                true_levels.havoc_rank = rank
            end)

            mod._havoc_promises[account_id] = true
        end
    end

    if (levels[2].val ~= "" or levels[3].val ~= "") and disable_normal_level then
        levels[1].val = ""
    end

    local levels_text = _concat_levels(reference)

    if need_adding and levels_text ~= "" then
        text = text .. " - " ..  _concat_levels(reference)
    else
        text = text:gsub("%d+" .. suffix, levels_text)
    end

    if title then
        text = text .. "\n" .. title
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
    local is_waiting = false

    if wru and wru:is_enabled() and wru:get("enable_" .. key) then
        is_waiting = target.wru_modified and not target.tl_modified
    else
        is_waiting = not target.tl_modified
    end

    return is_waiting
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

mod:hook_safe(CLASS.PresenceEntryImmaterium, "update_with", function(self, new_entry)
    local key_values = new_entry.key_values
    local character_profile = key_values and key_values.character_profile
    local character_id = key_values and key_values.character_id and key_values.character_id.value
    local cache = mod._others

    if character_profile and character_id and not cache[character_id] then
        local backend_profile_data = ProfileUtils.process_backend_body(cjson.decode(character_profile.value))
        local backend_progression = backend_profile_data.progression
        local havoc_rank_cadence_high = self:havoc_rank_cadence_high()

        mod.cache_true_levels(cache, character_id, backend_progression, havoc_rank_cadence_high, new_entry.account_id)
        mod.debug.echo(backend_profile_data.character.name .. ": " .. character_id)
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
    mod.desync_all()
end
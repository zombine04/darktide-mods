local mod = get_mod("true_level")

mod._info = {
    title = "True Level",
    author = "Zombine",
    date = "2026/08/17",
    version = "1.10.3",
}
mod:info("Version " .. mod._info.version)

local ProfileUtils = require("scripts/utilities/profile_utils")

mod._self = mod:persistent_table("self")
mod._others = mod:persistent_table("others")
mod._queue = mod:persistent_table("queue")
mod._havoc_promises = mod:persistent_table("havoc")
mod._havoc_assignments = mod:persistent_table("havoc_assignment_cache")
mod._havoc_assignment_pending = {}
mod._havoc_assignment_queue = {}
mod._havoc_assignment_active = 0
mod._havoc_assignment_refs = {}
mod._havoc_assignment_changed = false
mod._havoc_assignment_shared = mod:persistent_table("havoc_assignment_shared")
mod._havoc_assignment_shared_raw = mod:persistent_table("havoc_assignment_shared_raw")
mod._havoc_assignment_local = nil
mod._havoc_assignment_published = nil
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

-- ############################################################
-- Havoc Assignment
-- ############################################################

local HAVOC_CHARGE_SYMBOLS = {
    "\xEE\x80\x91",
    "\xEE\x80\x92",
    "\xEE\x80\x93",
}
local SHARE_KEY = "true_level_havoc_assignment"
local SHARE_MAX_BYTES = 8
local SHARE_MAX_RANK = 99
local HAVOC_ASSIGNMENT_TTL = 600
local HAVOC_ASSIGNMENT_MAX_REQUESTS = 2
local EXPIRED = -math.huge

local _now = function()
    local time_manager = Managers.time

    return time_manager and time_manager:has_timer("main") and time_manager:time("main") or 0
end

local _can_fetch_havoc_assignment = function()
    local state_managers = Managers.state
    local game_mode_manager = state_managers and state_managers.game_mode
    local game_mode_name = game_mode_manager and game_mode_manager:game_mode_name()

    return not game_mode_name or game_mode_name == "hub" or game_mode_name == "prologue_hub"
end

local _fetch_local_havoc_assignment = function()
    local havoc_service = Managers.data_service.havoc

    return havoc_service:available_orders():next(function(orders)
        local current_order = nil
        local max_rank = 0

        if type(orders) == "table" then
            for i = 1, #orders do
                local order = orders[i]
                local rank = order.data and tonumber(order.data.rank)

                if rank and max_rank < rank then
                    max_rank = rank
                    current_order = order
                end
            end
        end

        if current_order then
            return {
                rank = max_rank,
                charges = tonumber(current_order.charges),
            }
        end

        return havoc_service:summary():next(function(summary)
            local summary_order = summary and summary.current_order
            local rank = summary_order and tonumber(summary_order.rank)

            return rank and { rank = rank } or nil
        end)
    end)
end

local _fetch_other_havoc_assignment = function(account_id)
    local backend = Managers.backend

    return backend:authenticate():next(function()
        local path = "/data/" .. account_id .. "/havoc/summary"

        return backend:title_request(path, { method = "GET" })
    end):next(function(data)
        local body = data and data.status == 200 and data.body
        local current_order = body and (body.currentOrder or body.current_order)
        local rank = current_order and tonumber(current_order.rank)

        return rank and { rank = rank } or nil
    end)
end

local _is_local_account = function(account_id)
    local player = Managers.player:local_player_safe(1)

    return player and player:account_id() == account_id
end

local _publish_havoc_assignment = function(clear)
    local value = ""
    local assignment = mod._havoc_assignment_local

    if not clear and assignment and mod:get("share_havoc_assignment") then
        value = assignment.rank .. ":" .. (assignment.charges or "")
    end

    local published = mod._havoc_assignment_published

    if value == published or (value == "" and published == nil) then
        return
    end

    mod._havoc_assignment_published = value

    local presence_manager = Managers.presence

    if presence_manager and type(presence_manager._update_my_presence) == "function" then
        pcall(presence_manager._update_my_presence, presence_manager, { [SHARE_KEY] = true })
    end
end

local _decode_shared_havoc_assignment = function(raw)
    if type(raw) ~= "string" or raw == "" or #raw > SHARE_MAX_BYTES then
        return nil
    end

    local rank, charges = raw:match("^(%d+):(%d?)$")

    rank = tonumber(rank)

    if not rank or rank < 1 or rank > SHARE_MAX_RANK then
        return nil
    end

    return {
        rank = rank,
        charges = tonumber(charges),
    }
end

local _is_same_havoc_assignment = function(a, b)
    if a == b then
        return true
    elseif not a or not b then
        return false
    end

    return a.rank == b.rank and a.charges == b.charges
end

local _update_shared_havoc_assignment = function(presence, account_id)
    if not account_id then
        return
    end

    local raw = presence:_key_value_string(SHARE_KEY)
    local shared_raw = mod._havoc_assignment_shared_raw

    if raw == shared_raw[account_id] then
        return
    end

    shared_raw[account_id] = raw

    local shared = mod._havoc_assignment_shared
    local previous = shared[account_id]
    local assignment = _decode_shared_havoc_assignment(raw)

    shared[account_id] = assignment

    if _is_same_havoc_assignment(previous, assignment) then
        return
    end

    if previous or mod._havoc_assignments[account_id] or mod._havoc_assignment_pending[account_id] then
        mod.desync_all()
    end
end

local _store_havoc_assignment = function(account_id, rank, charges)
    local assignments = mod._havoc_assignments
    local entry = assignments[account_id]
    local changed = false

    if entry then
        changed = entry.rank ~= rank or entry.charges ~= charges
    else
        entry = {}
        assignments[account_id] = entry
        changed = rank ~= nil
    end

    entry.rank = rank
    entry.charges = charges
    entry.fetched_at = _now()

    if _is_local_account(account_id) then
        mod._havoc_assignment_local = rank and entry or nil
        _publish_havoc_assignment()
    end

    if changed then
        mod.debug.dump(entry, "havoc_assignment: " .. account_id)
    end

    return changed
end

local _finish_havoc_assignment_batch = function()
    if next(mod._havoc_assignment_pending) ~= nil then
        return
    end

    local refs = mod._havoc_assignment_refs

    if mod._havoc_assignment_changed then
        for ref in pairs(refs) do
            mod.desynced(ref)
        end
    end

    table.clear(refs)
    mod._havoc_assignment_changed = false
end

local _request_next_havoc_assignment = nil

local _settle_havoc_assignment = function(account_id, assignment, failed)
    local pending = mod._havoc_assignment_pending

    if not pending[account_id] then
        return
    end

    pending[account_id] = nil
    mod._havoc_assignment_active = mod._havoc_assignment_active - 1

    if failed then
        local entry = mod._havoc_assignments[account_id]

        if entry then
            entry.fetched_at = _now()
        else
            mod._havoc_assignments[account_id] = { fetched_at = _now() }
        end
    elseif _store_havoc_assignment(account_id, assignment and assignment.rank, assignment and assignment.charges) then
        mod._havoc_assignment_changed = true
    end

    _request_next_havoc_assignment()
    _finish_havoc_assignment_batch()
end

local _start_havoc_assignment_request = function(account_id)
    mod._havoc_assignment_active = mod._havoc_assignment_active + 1

    local fetch = _is_local_account(account_id) and _fetch_local_havoc_assignment or _fetch_other_havoc_assignment
    local ok, promise = pcall(fetch, account_id)

    if not ok then
        mod.debug.echo("havoc assignment request failed: " .. tostring(promise))
        _settle_havoc_assignment(account_id, nil, true)

        return
    end

    promise:next(function(result)
        _settle_havoc_assignment(account_id, result)
    end):catch(function(e)
        mod.debug.dump(e, "havoc_assignment", 3)
        _settle_havoc_assignment(account_id, nil, true)
    end)
end

_request_next_havoc_assignment = function()
    local queue = mod._havoc_assignment_queue

    while mod._havoc_assignment_active < HAVOC_ASSIGNMENT_MAX_REQUESTS and queue[1] do
        local account_id = table.remove(queue, 1)

        if _can_fetch_havoc_assignment() then
            _start_havoc_assignment_request(account_id)
        else
            mod._havoc_assignment_pending[account_id] = nil
        end
    end
end

local _request_havoc_assignment = function(account_id, ref)
    local pending = mod._havoc_assignment_pending

    if not pending[account_id] then
        if not _can_fetch_havoc_assignment() then
            return
        end

        if not GameParameters.prod_like_backend or not math.is_uuid(account_id) then
            _store_havoc_assignment(account_id, nil, nil)

            return
        end

        local queue = mod._havoc_assignment_queue

        pending[account_id] = true

        if _is_local_account(account_id) then
            table.insert(queue, 1, account_id)
        else
            queue[#queue + 1] = account_id
        end

        _request_next_havoc_assignment()
    end

    if ref and pending[account_id] then
        mod._havoc_assignment_refs[ref] = true
    end
end

local _get_havoc_assignment = function(account_id, ref)
    local shared = mod._havoc_assignment_shared[account_id]

    if shared then
        return shared
    end

    local entry = mod._havoc_assignments[account_id]

    if not entry or _now() - entry.fetched_at >= HAVOC_ASSIGNMENT_TTL then
        _request_havoc_assignment(account_id, ref)
        entry = mod._havoc_assignments[account_id]
    end

    return entry and entry.rank and entry or nil
end

mod.request_local_havoc_assignment = function()
    if not mod:get("share_havoc_assignment") then
        return
    end

    local player = Managers.player:local_player_safe(1)
    local account_id = player and player:account_id()

    if account_id then
        _get_havoc_assignment(account_id)
    end
end

mod.set_local_havoc_assignment = function(rank, charges)
    local player = Managers.player:local_player_safe(1)
    local account_id = player and player:account_id()

    if account_id and rank then
        _store_havoc_assignment(account_id, rank, charges)
    end
end

mod.expire_havoc_assignment = function(account_id)
    local entry = mod._havoc_assignments[account_id]

    if entry then
        entry.fetched_at = EXPIRED
    end
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
    },
    {
        key = "havoc_assignment",
        val = ""
    }
}

local _init_levels = function()
    for i = 1, #levels do
        local level = levels[i]

        level.val = ""
    end
end

local level_texts = {}

local _concat_levels = function(ref)
    local result = ""
    local len = #levels

    table.clear(level_texts)

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
            level_texts[#level_texts + 1] = level_text
        end
    end

    return result
end

mod.get_level_texts = function()
    return level_texts
end

local _trim_added_levels = function(text)
    -- Color markup can make the appended level suffix start with "{#color...}"
    -- instead of a digit, so strip both plain and colored variants.
    text = text:gsub("%s+%-%s+%d.+", "")
    text = text:gsub("%s+%-%s+{#.-}%d.+", "")

    return text
end

mod.replace_level = function(text, true_levels, reference, need_adding)
    _init_levels()

    mod._symbols.level_custom = _get_best_setting("level_icon", reference)
    mod._symbols.prestige_level_custom = _get_best_setting("prestige_level_icon", reference)
    mod._symbols.havoc_rank_custom = _get_best_setting("havoc_rank_icon", reference)

    local display_style = _get_best_setting("display_style", reference)
    local show_prestige = _get_best_setting("enable_prestige_level", reference)
    local show_havoc_rank = _get_best_setting("enable_havoc_rank", reference)
    local show_havoc_assignment = _get_best_setting("enable_havoc_assignment", reference)
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
        text = _trim_added_levels(text)
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

    if show_havoc_assignment and true_level then
        local account_id = true_levels.account_id
        local assignment = account_id and _get_havoc_assignment(account_id, reference)

        if assignment then
            local assignment_text = assignment.rank

            if _get_best_setting("enable_havoc_assignment_charges", reference) then
                local charges_symbol = HAVOC_CHARGE_SYMBOLS[assignment.charges]

                if charges_symbol then
                    assignment_text = assignment_text .. " " .. charges_symbol
                end
            end

            mod._symbols.havoc_assignment_custom = _get_best_setting("havoc_assignment_icon", reference)
            levels[4].val = assignment_text
        end
    end

    if (levels[2].val ~= "" or levels[3].val ~= "" or levels[4].val ~= "") and disable_normal_level then
        levels[1].val = ""
    end

    local levels_text = _concat_levels(reference)

    if need_adding and levels_text ~= "" then
        text = text .. " - " .. levels_text
    elseif levels_text == "" or not string.find(text, levels_text, 1, true) then
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

-- players publish their new havoc clearance only after entering the hub,
-- so keep the clearance of already cached characters in sync with presence
local _refresh_havoc_clearance = function(presence, true_levels)
    if not true_levels.true_level then
        return
    end

    local havoc_rank_cadence_high = presence:havoc_rank_cadence_high()

    if havoc_rank_cadence_high and havoc_rank_cadence_high ~= true_levels.havoc_rank then
        true_levels.havoc_rank = havoc_rank_cadence_high
        mod.desync_all()
    end
end

mod:hook_safe(CLASS.PresenceEntryImmaterium, "update_with", function(self, new_entry)
    local key_values = new_entry.key_values
    local character_profile = key_values and key_values.character_profile
    local character_id = key_values and key_values.character_id and key_values.character_id.value
    local cache = mod._others
    local cached_levels = character_id and cache[character_id]

    if cached_levels then
        _refresh_havoc_clearance(self, cached_levels)
    end

    if character_profile and character_id and not cache[character_id] then
        local backend_profile_data = ProfileUtils.process_backend_body(cjson.decode(character_profile.value))
        local backend_progression = backend_profile_data.progression
        local havoc_rank_cadence_high = self:havoc_rank_cadence_high()

        mod.cache_true_levels(cache, character_id, backend_progression, havoc_rank_cadence_high, new_entry.account_id)
        mod.debug.echo(backend_profile_data.character.name .. ": " .. character_id)
    end

    if key_values then
        _update_shared_havoc_assignment(self, new_entry.account_id)
    end
end)

-- ############################################################
-- Share Havoc Assignment
-- ############################################################

mod:hook(CLASS.PresenceEntryMyself, "create_key_values", function(func, self, white_list)
    local key_values = func(self, white_list)
    local published = mod._havoc_assignment_published

    if published and (not white_list or white_list[SHARE_KEY]) then
        key_values[SHARE_KEY] = published
    end

    return key_values
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
    mod.request_local_havoc_assignment()
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

    if id == "share_havoc_assignment" then
        mod.request_local_havoc_assignment()
        _publish_havoc_assignment()
    end
end

mod.on_enabled = function()
    _publish_havoc_assignment()
end

mod.on_disabled = function()
    _publish_havoc_assignment(true)
end

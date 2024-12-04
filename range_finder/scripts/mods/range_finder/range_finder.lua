--[[
    title: range_finder
    author: Zombine
    date: 2024/12/04
    version: 1.2.0
]]
local mod = get_mod("range_finder")

mod:io_dofile("range_finder/scripts/mods/range_finder/range_finder_utils")

local element = {
    use_hud_scale = true,
    class_name = "HudElementRangeFinder",
    filename = "range_finder/scripts/mods/range_finder/range_finder_elements",
    visibility_groups = {
        "alive"
    }
}

mod:register_hud_element(element)

local INDEX_DISTANCE = 2
local INDEX_ACTOR = 4
local MAX_DISTANCE = 100

mod:hook_safe(CLASS.PlayerUnitSmartTargetingExtension, "fixed_update", function(self, unit, dt, t, fixed_frame)
    local first_person_component = self._first_person_component
    local look_pos = first_person_component.position
    local look_rot = first_person_component.rotation
    local look_forward = Quaternion.forward(look_rot)
    local physics_world = self._physics_world
    local hits, num_hits = PhysicsWorld.raycast(physics_world, look_pos, look_forward, MAX_DISTANCE, "all", "collision_filter", "filter_debug_unit_selector")
    local distance

    if hits then
        for i = 1, num_hits do
            local hit = hits[i]
            local actor_unit = Actor.unit(hit[INDEX_ACTOR])

            if actor_unit and actor_unit ~= unit then
                distance = hit[INDEX_DISTANCE]
                break
            end
        end
    end

    mod._distance = distance or 0
end)

mod.on_enabled = function ()
    mod._is_enabled = true
end

mod.on_disabled = function ()
    mod._is_enabled = false
end

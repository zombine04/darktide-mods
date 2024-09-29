--[[
    name: EmpowerUntilLimit
    author: Zombine
    date: 2024/09/30
    version: 1.0.0
]]
local mod = get_mod("EmpowerUntilLimit")
local NotifSettings = require("scripts/ui/constant_elements/elements/notification_feed/constant_element_notification_feed_settings")

-- ##################################################
-- Decrease hold timer
-- ##################################################

mod:hook_safe(CLASS.ViewElementCraftingRecipe, "init", function(self)
    local widget = self._widgets_by_name.continue_button_hold

    widget.content.timer = 0.01
    mod._do_upgrade = false
end)

-- ##################################################
-- Countinuous upgrade
-- ##################################################

local _clear_notifications = function(force_clear)
    local constant_elements = Managers.ui._ui_constant_elements
    local elements = constant_elements._elements
    local notification = elements.ConstantElementNotificationFeed
    local num_notifications = #notification._notifications

    if force_clear or NotifSettings.max_visible_notifications <= num_notifications then
        Managers.event:trigger("event_clear_notifications")
    end
end

mod:hook_safe(CLASS.ViewElementCraftingRecipe, "set_continue_button_force_disabled", function(self, is_disabled)
    if not mod._do_upgrade and not is_disabled then
        mod._do_upgrade = true
        _clear_notifications()
    end
end)

mod:hook_safe(CLASS.CraftingMechanicusUpgradeExpertiseView, "update", function(self)
    if mod._do_upgrade and not self._craft_promise and self._crafting_recipe and self._crafting_recipe:can_craft() then
        mod._do_upgrade = false
        self:cb_on_main_button_pressed()
    end
end)
local mod = get_mod("modular_menu_buttons")

mod._content_list = {
    {
        name = "credits_vendor_background_view",
        text = "loc_vendor_view_title",
        type = "button",
        icon = "content/ui/materials/hud/interactions/icons/credits_store",
    },
    {
        name = "contracts_background_view",
        text = "loc_marks_vendor_view_title",
        type = "button",
        icon = "content/ui/materials/hud/interactions/icons/contracts",
    },
    {
        name = "crafting_view",
        text = "loc_crafting_view",
        type = "button",
        icon = "content/ui/materials/hud/interactions/icons/forge",
    },
    {
        name = "mission_board_view",
        text = "loc_mission_board_view",
        type = "button",
        icon = "content/ui/materials/hud/interactions/icons/mission_board",
    },
    {
        name = "training_grounds_view",
        text = "loc_training_ground_view",
        type = "button",
        icon = "content/ui/materials/hud/interactions/icons/training_grounds",
    },
    {
        name = "barber_vendor_background_view",
        text = "loc_body_shop_view_display_name",
        type = "button",
        icon = "content/ui/materials/hud/interactions/icons/barber",
    },
    {
        name = "store_view",
        text = "loc_store_view_display_name",
        type = "button",
        icon = "content/ui/materials/icons/system/escape/premium_store",
    },
}

mod._content_list_default = {
    {
        name = "inventory_background_view",
        text = "loc_character_view_display_name",
    },
    {
        name = "account_profile_view",
        text = "loc_achievements_view_display_name",
    },
    {
        name = "social_menu_view",
        text = "loc_social_view_display_name",
    },
}

mod._content_list_main_menu = {
    {
        name = "credits_view",
        text = "loc_credits_view_title",
    },
    {
        name = "main_menu_view",
        text = "loc_exit_to_main_menu_display_name",
    },
}

local default = table.clone(mod._content_list_default)
local main_menu = table.clone(mod._content_list_main_menu)

mod._content_list_existed = table.append(default, main_menu)

local loc = {
    mod_name = {
        en = "Modular Menu Buttons",
    },
    mod_description = {
        en = "Allows to customize the buttons displayed in the esc menu.",
        ja = "エスケープメニューに表示されるボタンをカスタマイズできるようにします。"
    },
    enable_ingame = {
        en = "Enable During Missions",
        ja = "ミッション中も有効にする",
    },
    menu = {
        en = Localize("loc_system_view_display_name")
    }
}

local _add_loc = function(t)
    for i, setting in ipairs(t) do
        loc[setting.name] = {}
        loc[setting.name].en = Localize(setting.text)
    end
end

_add_loc(mod._content_list)
_add_loc(mod._content_list_existed)

return loc
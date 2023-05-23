local mod = get_mod("modular_menu_buttons")

mod:io_dofile("modular_menu_buttons/scripts/mods/modular_menu_buttons/modular_menu_buttons_settings")

local loc = {
    mod_name = {
        en = "Modular Menu Buttons",
    },
    mod_description = {
        en = "Allows to customize the buttons displayed in the esc menu.",
        ja = "エスケープメニューに表示されるボタンをカスタマイズできるようにします。"
    },
    main_menu = {
        en = Localize("loc_hud_presence_main_menu")
    },
    hub = {
        en = Localize("loc_hud_presence_hub")
    },
    shooting_range = {
        en = Localize("loc_hud_presence_training_grounds")
    },
    lobby = {
        en = Localize("loc_hud_presence_matchmaking")
    },
    coop_complete_objective = {
        en = Localize("loc_hud_presence_mission")
    },
}

local _add_loc = function(t)
    for _, setting in ipairs(t) do
        for _, state in ipairs(mod._state) do
            local key = setting.name .. "_" .. state
            loc[key] = { en = Localize(setting.text) }
        end
    end
end

_add_loc(mod._content_list)
_add_loc(mod._content_list_existed)

return loc
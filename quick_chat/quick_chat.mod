return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`quick_chat` encountered an error loading the Darktide Mod Framework.")

        new_mod("quick_chat", {
            mod_script       = "quick_chat/scripts/mods/quick_chat/quick_chat",
            mod_data         = "quick_chat/scripts/mods/quick_chat/quick_chat_data",
            mod_localization = "quick_chat/scripts/mods/quick_chat/quick_chat_localization",
        })
    end,
    packages = {},
}

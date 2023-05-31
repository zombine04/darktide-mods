return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`who_are_you` encountered an error loading the Darktide Mod Framework.")

        new_mod("who_are_you", {
            mod_script       = "who_are_you/scripts/mods/who_are_you/who_are_you",
            mod_data         = "who_are_you/scripts/mods/who_are_you/who_are_you_data",
            mod_localization = "who_are_you/scripts/mods/who_are_you/who_are_you_localization",
        })
    end,
    packages = {},
}

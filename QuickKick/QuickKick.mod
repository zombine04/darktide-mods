return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`QuickKick` encountered an error loading the Darktide Mod Framework.")

        new_mod("QuickKick", {
            mod_script       = "QuickKick/scripts/mods/QuickKick/QuickKick",
            mod_data         = "QuickKick/scripts/mods/QuickKick/QuickKick_data",
            mod_localization = "QuickKick/scripts/mods/QuickKick/QuickKick_localization",
        })
    end,
    packages = {},
}

return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`ime_enabler` encountered an error loading the Darktide Mod Framework.")

        new_mod("ime_enabler", {
            mod_script       = "ime_enabler/scripts/mods/ime_enabler/ime_enabler",
            mod_data         = "ime_enabler/scripts/mods/ime_enabler/ime_enabler_data",
            mod_localization = "ime_enabler/scripts/mods/ime_enabler/ime_enabler_localization",
        })
    end,
    packages = {},
}

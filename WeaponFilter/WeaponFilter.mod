return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`WeaponFilter` encountered an error loading the Darktide Mod Framework.")

        new_mod("WeaponFilter", {
            mod_script       = "WeaponFilter/scripts/mods/WeaponFilter/WeaponFilter",
            mod_data         = "WeaponFilter/scripts/mods/WeaponFilter/WeaponFilter_data",
            mod_localization = "WeaponFilter/scripts/mods/WeaponFilter/WeaponFilter_localization",
        })
    end,
    packages = {},
}

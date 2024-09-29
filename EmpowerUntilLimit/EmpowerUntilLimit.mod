return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`EmpowerUntilLimit` encountered an error loading the Darktide Mod Framework.")

        new_mod("EmpowerUntilLimit", {
            mod_script       = "EmpowerUntilLimit/scripts/mods/EmpowerUntilLimit/EmpowerUntilLimit",
            mod_data         = "EmpowerUntilLimit/scripts/mods/EmpowerUntilLimit/EmpowerUntilLimit_data",
            mod_localization = "EmpowerUntilLimit/scripts/mods/EmpowerUntilLimit/EmpowerUntilLimit_localization",
        })
    end,
    packages = {},
}

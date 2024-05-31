return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`PenancesForTheMission` encountered an error loading the Darktide Mod Framework.")

        new_mod("PenancesForTheMission", {
            mod_script       = "PenancesForTheMission/scripts/mods/PenancesForTheMission/PenancesForTheMission",
            mod_data         = "PenancesForTheMission/scripts/mods/PenancesForTheMission/PenancesForTheMission_data",
            mod_localization = "PenancesForTheMission/scripts/mods/PenancesForTheMission/PenancesForTheMission_localization",
        })
    end,
    packages = {},
}

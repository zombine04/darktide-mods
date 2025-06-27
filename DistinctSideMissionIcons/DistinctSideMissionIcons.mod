return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`DistinctSideMissionIcons` encountered an error loading the Darktide Mod Framework.")

        new_mod("DistinctSideMissionIcons", {
            mod_script       = "DistinctSideMissionIcons/scripts/mods/DistinctSideMissionIcons/DistinctSideMissionIcons",
            mod_data         = "DistinctSideMissionIcons/scripts/mods/DistinctSideMissionIcons/DistinctSideMissionIcons_data",
            mod_localization = "DistinctSideMissionIcons/scripts/mods/DistinctSideMissionIcons/DistinctSideMissionIcons_localization",
        })
    end,
    packages = {},
}

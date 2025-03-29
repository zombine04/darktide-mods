return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`TeamBuildOverlay` encountered an error loading the Darktide Mod Framework.")

        new_mod("TeamBuildOverlay", {
            mod_script       = "TeamBuildOverlay/scripts/mods/TeamBuildOverlay/TeamBuildOverlay",
            mod_data         = "TeamBuildOverlay/scripts/mods/TeamBuildOverlay/TeamBuildOverlay_data",
            mod_localization = "TeamBuildOverlay/scripts/mods/TeamBuildOverlay/TeamBuildOverlay_localization",
        })
    end,
    packages = {},
}

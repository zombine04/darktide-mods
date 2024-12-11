return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`InspectFromPartyFinder` encountered an error loading the Darktide Mod Framework.")

        new_mod("InspectFromPartyFinder", {
            mod_script       = "InspectFromPartyFinder/scripts/mods/InspectFromPartyFinder/InspectFromPartyFinder",
            mod_data         = "InspectFromPartyFinder/scripts/mods/InspectFromPartyFinder/InspectFromPartyFinder_data",
            mod_localization = "InspectFromPartyFinder/scripts/mods/InspectFromPartyFinder/InspectFromPartyFinder_localization",
        })
    end,
    packages = {},
}

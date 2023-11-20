return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`InspectFromSocial` encountered an error loading the Darktide Mod Framework.")

        new_mod("InspectFromSocial", {
            mod_script       = "InspectFromSocial/scripts/mods/InspectFromSocial/InspectFromSocial",
            mod_data         = "InspectFromSocial/scripts/mods/InspectFromSocial/InspectFromSocial_data",
            mod_localization = "InspectFromSocial/scripts/mods/InspectFromSocial/InspectFromSocial_localization",
        })
    end,
    packages = {},
}

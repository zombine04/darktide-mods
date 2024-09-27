return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`FilterSacrifice` encountered an error loading the Darktide Mod Framework.")

        new_mod("FilterSacrifice", {
            mod_script       = "FilterSacrifice/scripts/mods/FilterSacrifice/FilterSacrifice",
            mod_data         = "FilterSacrifice/scripts/mods/FilterSacrifice/FilterSacrifice_data",
            mod_localization = "FilterSacrifice/scripts/mods/FilterSacrifice/FilterSacrifice_localization",
        })
    end,
    packages = {},
}

return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`range_finder` encountered an error loading the Darktide Mod Framework.")

        new_mod("range_finder", {
            mod_script       = "range_finder/scripts/mods/range_finder/range_finder",
            mod_data         = "range_finder/scripts/mods/range_finder/range_finder_data",
            mod_localization = "range_finder/scripts/mods/range_finder/range_finder_localization",
        })
    end,
    packages = {},
}

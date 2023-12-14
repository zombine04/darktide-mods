return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`ShowInsignias` encountered an error loading the Darktide Mod Framework.")

        new_mod("ShowInsignias", {
            mod_script       = "ShowInsignias/scripts/mods/ShowInsignias/ShowInsignias",
            mod_data         = "ShowInsignias/scripts/mods/ShowInsignias/ShowInsignias_data",
            mod_localization = "ShowInsignias/scripts/mods/ShowInsignias/ShowInsignias_localization",
        })
    end,
    packages = {},
}

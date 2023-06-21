return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`kill_sound` encountered an error loading the Darktide Mod Framework.")

        new_mod("kill_sound", {
            mod_script       = "kill_sound/scripts/mods/kill_sound/kill_sound",
            mod_data         = "kill_sound/scripts/mods/kill_sound/kill_sound_data",
            mod_localization = "kill_sound/scripts/mods/kill_sound/kill_sound_localization",
        })
    end,
    packages = {},
}

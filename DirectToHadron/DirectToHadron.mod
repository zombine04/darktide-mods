return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`DirectToHadron` encountered an error loading the Darktide Mod Framework.")

        new_mod("DirectToHadron", {
            mod_script       = "DirectToHadron/scripts/mods/DirectToHadron/DirectToHadron",
            mod_data         = "DirectToHadron/scripts/mods/DirectToHadron/DirectToHadron_data",
            mod_localization = "DirectToHadron/scripts/mods/DirectToHadron/DirectToHadron_localization",
        })
    end,
    packages = {},
}

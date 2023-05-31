return {
    run = function()
        fassert(rawget(_G, "new_mod"), "`which_book` encountered an error loading the Darktide Mod Framework.")

        new_mod("which_book", {
            mod_script       = "which_book/scripts/mods/which_book/which_book",
            mod_data         = "which_book/scripts/mods/which_book/which_book_data",
            mod_localization = "which_book/scripts/mods/which_book/which_book_localization",
        })
    end,
    packages = {},
}

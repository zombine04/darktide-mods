local mod = get_mod("DirectToHadron")
local speak_to_hadron = Localize("loc_crafting_view_option_modify")

return {
    mod_name = {
        en = "Direct to Hadron",
    },
    mod_description = {
        en = "Directly open the craft menu from inventory, and preview the item which you selected.",
        ja = "インベントリから直接クラフトメニューを開き、選択したアイテムをプレビューします。",
    },
    enable_skip_hadron = {
        en = "Skip \"" .. speak_to_hadron .. "\"",
        ja = "「" .. speak_to_hadron .. "」をスキップする",
    }
}

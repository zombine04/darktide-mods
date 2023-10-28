local mod = get_mod("DirectToHadron")
local speak_to_hadron = Localize("loc_crafting_view_option_modify")

return {
    mod_name = {
        en = "Direct to Hadron",
        ["zh-cn"] = "一键跳转到锻造",
    },
    mod_description = {
        en = "Directly open the craft menu from inventory, and preview the item which you selected.",
        ja = "インベントリから直接クラフトメニューを開き、選択したアイテムをプレビューします。",
        ["zh-cn"] = "在库存界面直接打开锻造菜单，并预览当前所选的物品。",
    },
    enable_skip_hadron = {
        en = "Skip \"" .. speak_to_hadron .. "\"",
        ja = "「" .. speak_to_hadron .. "」をスキップする",
        ["zh-cn"] = "跳过“" .. speak_to_hadron .. "”界面",
    }
}

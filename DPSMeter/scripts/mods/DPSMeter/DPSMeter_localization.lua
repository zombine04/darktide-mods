return {
    mod_name = {
        en = "DPS Meter",
        ["zh-cn"] = "DPS 指示器",
    },
    mod_description = {
        en = "Displays DPS.",
        ja = "DPSを表示します。",
        ["zh-cn"] = "显示 DPS（每秒造成伤害）。",
    },
    group_calc_settings = {
        en = "Calculation Settings",
        ja = "計算の設定",
        ["zh-cn"] = "计算设置",
    },
    group_display_settings = {
        en = "Display Settings",
        ja = "表示設定",
        ["zh-cn"] = "显示设置",
    },
    group_keybinds = {
        en = "Keybinds",
        ja = "キーバインド",
        ["zh-cn"] = "快捷键",
        ru = "Горячая клавиша",
    },
    group_font_settings = {
        en = "Font Settings",
        ja = "フォント設定",
        ["zh-cn"] = "字体设置",
    },
    group_misc = {
        en = "Misc",
        ja = "その他",
        ["zh-cn"] = "杂项",
    },
    calc_method = {
        en = "Calculation Method",
        ja = "計算方式",
        ["zh-cn"] = "计算方式",
    },
    calc_method_tooltip = {
        en = "Average: Displays average damage per second and resets after a certain amount of time since the last attack.\n\n" ..
             "Sum: Displays the total damage dealt within 1 second.",
        ja = "平均：1秒あたりの平均ダメージを表示し、最後の攻撃から一定時間が経過するとリセットされます。\n\n"..
             "加算：1秒間で与えたダメージの合計を表示します。",
        ["zh-cn"] = "平均：显示每秒的平均伤害，并在上次攻击后经过一定秒数后重置。\n\n" .. -- provisional translation
             "总和：显示 1 秒内造成的总伤害。",
    },
    calc_method_average = {
        en = "Average",
        ja = "平均",
        ["zh-cn"] = "平均",
    },
    calc_method_sum = {
        en = "Sum",
        ja = "加算",
        ["zh-cn"] = "总和",
    },
    reset_timer = {
        en = "Reset Timer (for Average Moethod)",
        ja = "リセットタイマー（平均用）",
        ["zh-cn"] = "重置计时器（平均时）",
    },
    ignore_overkill_damage = {
        en = "Ignore Overkill Damage",
        ja = "キル時の超過ダメージを無視する",
        ["zh-cn"] = "忽略溢出伤害",
    },
    ignore_overkill_damage_tooltip = {
        en = "If the damage is higher than the remaining health, the health value is counted as damage.",
        ja = "ダメージが残りのヘルスよりも高かった場合、ヘルスの値をダメージとしてカウントします。",
        ["zh-cn"] = "如果伤害超过剩余生命值，则以生命值作为伤害值。",
    },
    decimals = {
        en = "Decimal Places",
        ja = "少数点以下の桁数",
        ["zh-cn"] = "小数位数",
        ru = "Количество десятичных знаков",
    },
    hotkey_reset_meter = {
        en = "Reset Meter",
        ja = "メーターのリセット",
        ["zh-cn"] = "重置指示器",
    },
    shooting_range_only = {
        en = "Display only within the Psykhanium",
        ja = "サイカニウムにいる時のみ表示する",
        ["zh-cn"] = "仅在灵能室内显示",
    },
    enable_auto_hide = {
        en = "Auto-hide",
        ja = "自動非表示",
        ["zh-cn"] = "自动隐藏",
    },
    hide_timer = {
        en = "Auto-hide Timer",
        ja = "自動非表示タイマー",
        ["zh-cn"] = "自动隐藏计时器",
    },
    font_size = {
        en = "Size",
        ja = "大きさ",
        ["zh-cn"] = "大小",
        ru = "Размер",
    },
    font_opacity = {
        en = "Opacity",
        ja = "不透明度",
        ["zh-cn"] = "不透明度",
        ru = "Прозрачность",
    },
    enable_debug_mode = {
        en = "Debug Mode",
        ja = "デバッグモード",
        ["zh-cn"] = "调试模式",
        ru = "режим отладки",
    }
}

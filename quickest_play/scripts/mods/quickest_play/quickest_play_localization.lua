local loc = {
    mod_name = {
        en = "Quickest Play",
        ["zh-cn"] = "快速游戏",
        ru = "Быстрейшая игра",
    },
    mod_description = {
        en = "Add hotkey to start quickplay.",
        ja = "クイックプレイを開始するホットキーを追加します。",
        ["zh-cn"] = "添加开始快速游戏的快捷键。",
        ru = "Quickest Play - Добавьте горячую клавишу для запуска Быстрой игры из любого места.",
    },
    keybind = {
        en = "Keybind",
        ja = "キーバインド",
        ["zh-cn"] = "快捷键",
        ru = "Клавиша",
    },
    difficulty_settings = {
        en = "Difficulty Settings",
        ja = "難易度設定",
        ["zh-cn"] = "难度设置",
        ru = "Настройки сложности",
    },
    enable_override = {
        en = "Override current difficulty",
        ja = "現在の難易度設定を上書きする",
        ["zh-cn"] = "覆盖当前的难度",
        ru = "Заменить текущую сложность",
    },
    diff_level = {
        en = "Difficulty",
        ja = "難易度",
        ["zh-cn"] = "难度",
        ru = "Сложность",
    },
    err_locked = {
        en = "You have not met the required level.\nRequirement: ",
        ja = "必要レベルを満たしていません。\n必要レベル: ",
        ["zh-cn"] = "你没有达到所需的等级。\n需要等级：",
        ru = "Вы не достигли требуемого уровня.\nТребуется:",
    },
    err_locked_pj = {
        en = "The selected difficulty or quickplay is not unlocked",
        ja = "選択した難易度もしくはクイックプレイがアンロックされていません。",
    },
    auto_queue = {
        en = "Auto Queue",
        ja = "自動キュー",
        ["zh-cn"] = "自动匹配",
        ru = "Автоподбор",
    },
    enable_auto_queue = {
        en = "Enable Auto Queue",
        ja = "自動キューを有効にする",
        ["zh-cn"] = "启用自动匹配",
        ru = "Включить автоподбор",
    },
    auto_queue_desc = {
        en = "If enabled, automatically start queuing as soon as you entered the hub.",
        ja = "有効にすると、ハブに接続後自動的にキューを開始します。",
        ["zh-cn"] = "启用时，进入大厅时自动开始匹配。",
        ru = "Если включено, при входе в Хаб, автоматически подключается в очередь подбора миссии.",
    },
    key_cancel_auto_queue = {
        en = "Keybind for Canceling",
        ja = "キャンセル用キーバインド",
        ["zh-cn"] = "取消快捷键",
        ru = "Клавиша для отмены",
    },
    notif_canceled = {
        en = "Auto Queue Canceled.",
        ja = "自動キューがキャンセルされました。",
        ["zh-cn"] = "自动匹配已取消。",
        ru = "Автоподбор отменен.",
    },
    auto_restart = {
        en = "Auto Restart",
        ja = "自動リスタート",
        ["zh-cn"] = "自动重试",
        ru = "Автоматический перезапуск",
    },
    enable_auto_restart = {
        en = "Enable Auto Restart",
        ja = "自動リスタートを有効にする",
        ["zh-cn"] = "启用自动重试",
        ru = "Включить автоперезапуск",
    },
    auto_restart_desc = {
        en = "If enabled, automatically restart queuing when you can't find any matches.",
        ja = "有効にすると、マッチが見つからなかった際に自動的にキューをリスタートします。",
        ["zh-cn"] = "启用时，在无法找到合适的小队时自动重新匹配。",
        ru = "Если включено, автоматически переподключается в очередь подбора миссии, когда игра не смогла найти совпадений.",
    },
    enable_for_quickplay_only = {
        en = "Enable for Quickplay Only",
        ja = "クイックプレイのみで有効にする",
        ["zh-cn"] = "仅为快速游戏启用",
        ru = "Только для быстрой игры",
    },
    mission_type = {
        en = Localize("loc_hud_presence_mission"),
    },
    normal = {
        en = Localize("loc_mission_board_type_normal"),
    },
    auric = {
        en = Localize("loc_mission_board_type_auric"),
    },
    quickplay = {
        en = Localize("loc_mission_board_quickplay_header"),
    }
}

loc.key_start = { en = loc.quickplay.en }

return loc


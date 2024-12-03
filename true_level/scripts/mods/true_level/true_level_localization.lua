local mod = get_mod("true_level")

mod._elements = {
    "end_view",
    "inventory",
    "lobby",
    "nameplate",
    "main_menu",
    "inspect_player",
    "team_panel",
    "social_menu",
    "group_finder",
}

mod._styles = {
    "separate",
    "total",
    "default",
}

local loc = {
    mod_name = {
        en = "True Level",
        ["zh-cn"] = "真实等级",
        ru = "Настоящий уровень",
    },
    mod_description = {
        en = "Reads recorded exp earned after you hit the max level, and displays the actual level you can reach.",
        ja = "最大レベル到達後に獲得し記録された経験値を読み取り、実際に到達できるであろうレベルを表示します。",
        ["zh-cn"] = "读取玩家达到最高等级后获取的经验值，显示玩家的真实等级。",
        ru = "True Level - Считывает опыт, полученный после достижения максимального уровня, и отображает ваш фактический уровень, которого вы достигли.",
    },
    enable_level_up_notif = {
        en = "Enable Level Up Notification",
        ja = "レベルアップ通知を有効にする",
        ["zh-cn"] = "启用升级通知",
        ru = "Включить уведомление о повышении уровня",
    },
    global = {
        en = "Global",
        ja = "グローバル",
        ["zh-cn"] = "全局",
        ru = "Глобально",
    },
    display_style = {
        en = "Display Style",
        ja = "表示スタイル",
        ["zh-cn"] = "显示样式",
        ru = "Стиль отображения",
    },
    display_style_desc = {
        en = "Separate: 30 (+100) \n" ..
             "Total: 130 \n" ..
             "Default: 30 ",
        ja = "別々: 30 (+100) \n" ..
             "合算: 130 \n" ..
             "デフォルト: 30 ",
        ["zh-cn"] = "分开: 30 (+100) \n" ..
             "合并: 130 \n" ..
             "默认: 30 ",
        ru = "Раздельно: 30 (+100) \n" ..
             "Вместе: 130 \n" ..
             "По умолчанию: 30 ",
    },
    use_global = {
        en = "Use Global Setting",
        ja = "グローバル設定を使用する",
        ["zh-cn"] = "使用全局设置",
        ru = "Использовать глобальную настройку",
    },
    separate = {
        en = "Separate",
        ja = "別々",
        ["zh-cn"] = "分开",
        ru = "Раздельно",
    },
    total = {
        en = "Total",
        ja = "合算",
        ["zh-cn"] = "合并",
        ru = "Вместе",
    },
    prestige = {
        en = "Prestige",
        ja = "プレステージ",
        ["zh-cn"] = "声望",
        ru = "Престиж",
    },
    default = {
        en = "Default",
        ja = "デフォルト",
        ["zh-cn"] = "默认",
        ru = "По умолчанию",
    },
    enable_prestige_level = {
        en = "Show Prestige Level",
        ja = "プレステージレベルを表示する",
        ["zh-cn"] = "显示声望等级",
        ru = "Показывать уровень престижа",
    },
    prestige_level_desc = {
        en = "Show how many times the character passed from level 1 to 30.",
        ja = "そのキャラクターが何回レベル1から30までを繰り返したか表示します。",
        ["zh-cn"] = "显示等同于玩家从 1 级升到 30 级的总次数。",
        ru = "Показывать, сколько раз персонаж прошел с 1 по 30 уровень",
    },
    enable_prestige_only = {
        en = "Show Prestige Level Only",
        ja = "プレステージレベルのみを表示する",
        ["zh-cn"] = "仅显示声望等级",
        ru = "Показывать только уровень престижа",
    },
    prestige_level_color = {
        en = "Prestige Level Color",
        ja = "プレステージレベルの色",
        ["zh-cn"] = "声望等级颜色",
        ru = "Цвет уровня престижа",
    },
    enable_havoc_rank = {
        en = "Show Havoc Rank",
        ja = "ハヴォックランクを表示する",
    },
    havoc_rank_color = {
        en = "Havoc Rank Color",
        ja = "ハヴォックランクの色",
    },
    level_up = {
        en = "Level Up!",
        ja = "レベルアップ！",
        ["zh-cn"] = "等级上升！",
        ru = "Уровень повышен!",
    },
    toggle = {
        en = "Toggle",
        ja = "切り替え",
        ["zh-cn"] = "开关",
        ru = "Переключатели",
    },
    end_view = {
        en = "Results Screen",
        ja = "リザルト画面",
        ["zh-cn"] = "结算界面",
        ru = "Экран результатов",
    },
    inventory = {
        en = "Inventory",
        ja = "インベントリ",
        ["zh-cn"] = "库存",
        ru = "Инвентарь",
    },
    lobby = {
        en = "Lobby",
        ja = "ロビー",
        ["zh-cn"] = "小队大厅",
        ru = "Лобби",
    },
    main_menu = {
        en = "Character Select Screen",
        ja = "キャラクター選択画面",
        ["zh-cn"] = "角色选择界面",
        ru = "Экран выбора персонажей",
    },
    nameplate = {
        en = "Nameplate",
        ja = "ネームプレート",
        ["zh-cn"] = "名称标签",
        ru = "Табличка с именем",
    },
    inspect_player = {
        en = Localize("loc_lobby_entry_inspect"),
    },
    team_panel = {
        en = "Team HUD",
        ja = "チームHUD",
        ["zh-cn"] = "团队 HUD",
        ru = "Интерфейс команды",
    },
    social_menu = {
        en = "Social Menu",
        ja = "ソーシャルメニュー",
        ["zh-cn"] = "社交菜单",
        ru = "Социальное меню",
    },
    group_finder = {
        en = Localize("loc_group_finder_menu_title")
    },
    debug_mode = {
        en = "Debug",
        ja = "デバッグ",
        ["zh-cn"] = "调试",
        ru = "Отладка",
    },
    enable_debug_mode = {
        en = "Enable Debug Mode",
        ja = "デバッグモードを有効にする",
        ["zh-cn"] = "启用调试模式",
        ru = "Включить режим отладки",
    },
    on = {
        en = Localize("loc_settings_menu_on"),
    },
    off = {
        en = Localize("loc_settings_menu_off")
    },
    account_level = {
        en = "Account Level: %s",
        ja = "アカウントレベル：%s",
        ["zh-cn"] = "账户等级：%s",
        ru = "Уровень аккаунта: %s",
    },
}

local _add_child_loc = function(parent, ele)
    local child = parent .. "_" .. ele
    loc[child] = {}
    for lang, text in pairs(loc[parent]) do
        loc[child][lang] = text
    end
end

for i, ele in pairs(mod._elements) do
    local toggle = "enable_" .. ele
    loc[toggle] = {}

    for lang, text in pairs(loc.toggle) do
        loc[toggle][lang] = text
    end

    _add_child_loc("display_style", ele)
    _add_child_loc("enable_prestige_level", ele)
    _add_child_loc("enable_prestige_only", ele)
    _add_child_loc("prestige_level_color", ele)
end

for i, name in ipairs(Color.list) do
    local c = Color[name](255, true)
    local text = string.format("{#color(%s,%s,%s)}%s{#reset()}", c[2], c[3], c[4], string.gsub(name, "_", " "))

    loc[name] = {}
    loc[name].en = text
end

return loc

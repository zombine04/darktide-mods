local mod = get_mod("who_are_you")

mod.modified_elements = {
    "_chat",
    "_lobby",
    "_nameplate",
    "_team_hud",
}

mod.sub_name_options = {
    "color_r",
    "color_g",
    "color_b",
    "enable_custom_color",
    "enable_custom_size",
    "enable_override",
    "sub_name_size",
}

local locres = {
    mod_name = {
        en = "Who Are You",
        ru = "Кто ты",
        ["zh-cn"] = "到底是谁",
    },
    mod_description = {
        en = "Display players' account name next to their character name.",
        ja = "キャラクター名の横にプレイヤーのアカウントネームを表示します。",
        ru = "Who Are You - Отображет имя учётной записи игрока рядом с именем его персонажа.",
        ["zh-cn"] = "在玩家的角色名字旁边显示账户名字。",
    },
    display_style = {
        en = "Display style",
        ja = "表示スタイル",
        ru = "Стиль отображения",
        ["zh-cn"] = "显示样式",
    },
    character_first = {
        en = "Character Name (Account Name)",
        ja = "キャラクター名 (アカウント名)",
        ru = "Имя персонажа (Учётная запись)",
        ["zh-cn"] = "角色名字（账户名字）",
    },
    account_first = {
        en = "Account Name (Character Name)",
        ja = "アカウント名 (キャラクター名)",
        ru = "Учётная запись (Имя персонажа)",
        ["zh-cn"] = "账户名字（角色名字）",
    },
    character_only = {
        en = "Character Name",
        ja = "キャラクター名",
        ru = "Имя персонажа",
        ["zh-cn"] = "角色名字",
    },
    account_only = {
        en = "Account Name",
        ja = "アカウント名",
        ru = "Учётная запись",
        ["zh-cn"] = "账户名字",
    },
    cycle_style = {
        en = "Cycle Style",
        ja = "スタイルの切り替え",
        ru = "Переключение стилей",
        ["zh-cn"] = "循环切换样式",
    },
    key_cycle_style = {
        en = "Keybind: Next style",
        ja = "キーバインド：次のスタイル",
        ru = "Клавиша: следующий стиль",
        ["zh-cn"] = "快捷键：下一个样式",
    },
    enable_cycle_notif = {
        en = "Notify current style",
        ja = "現在のスタイルを通知する",
        ru = "Уведомление о выбранном стиле",
        ["zh-cn"] = "通知提醒当前的样式",
    },
    current_style = {
        en = "current style: ",
        ja = "現在のスタイル: ",
        ru = "текущий стиль: ",
        ["zh-cn"] = "当前样式：",
    },
    enable_display_self = {
        en = "Display your own account name",
        ja = "自身のアカウント名も表示する",
        ru = "Видимость имени вашей учётной записи",
        ["zh-cn"] = "显示你自己的账户名字",
    },
    modify_target = {
        en = "Applied to",
        ja = "変更対象",
        ru = "К каким частям интерфейса применяется",
        ["zh-cn"] = "应用到",
    },
    global = {
        en = "Global",
        ja = "グローバル",
        ru = "Глобально",
        ["zh-cn"] = "全局",
    },
    enable_team_hud = {
        en = "Team HUD",
        ja = "チームHUD",
        ru = "Интерфейс команды",
        ["zh-cn"] = "团队 HUD",
    },
    enable_chat = {
        en = "Chat",
        ja = "チャット",
        ru = "Чат",
        ["zh-cn"] = "聊天栏",
    },
    enable_lobby = {
        en = "Lobby",
        ja = "ロビー",
        ru = "Лобби",
        ["zh-cn"] = "小队",
    },
    enable_nameplate = {
        en = "Nameplate",
        ja = "ネームプレート",
        ru = "Табличка с именем",
        ["zh-cn"] = "名称标签",
    },
    sub_name_settings = {
        en = "Sub name settings",
        ja = "サブネーム設定",
        ru = "Настройки дополнительной части имени",
        ["zh-cn"] = "附加名字设置",
    },
    tooltip_sub_name = {
        en = "This doesn't affect to chat name.",
        ja = "この設定はチャット欄には反映されません。",
        ru = "Это не влияет на имя в чате.",
        ["zh-cn"] = "这不会影响聊天名字。",
    },
    enable_override = {
        en = "Override global settings",
        ja = "グローバル設定を上書きする",
        ru = "Заменить глобальные настройки",
        ["zh-cn"] = "覆盖全局设置",
    },
    enable_custom_size = {
        en = "Change sub name size",
        ja = "サブネームの大きさを変更する",
        ru = "Изменить размер доп. имени",
        ["zh-cn"] = "更改附加名字大小",
    },
    sub_name_size = {
        en = "Size",
        ja = "大きさ",
        ru = "Размер",
        ["zh-cn"] = "大小",
    },
    enable_custom_color = {
        en = "Change sub name color",
        ja = "サブネームの色を変更する",
        ru = "Изменить цвет доп. имени",
        ["zh-cn"] = "更改附加名字颜色",
    },
    color_r = {
        en = "R",
        ru = "Красный",
        ["zh-cn"] = "红",
    },
    color_g = {
        en = "G",
        ru = "Зелёный",
        ["zh-cn"] = "绿",
    },
    color_b = {
        en = "B",
        ru = "Синий",
        ["zh-cn"] = "蓝",
    },
}

for _, element in ipairs(mod.modified_elements) do
    local local_name = "sub_name_settings" .. element
    locres[local_name] = {}
    for lang, text in pairs(locres.sub_name_settings) do
        if (locres["enable" .. element][lang]) then
            locres[local_name][lang] = text .. " (" .. locres["enable" .. element][lang] .. ")"
        end
    end
end
for lang, text in pairs(locres.sub_name_settings) do
    if locres.global[lang] then
        locres.sub_name_settings[lang] = text .. " (" .. locres.global[lang] .. ")"
    end
end

for _, element in ipairs(mod.modified_elements) do
    for _, option in ipairs(mod.sub_name_options) do
        locres[option .. element] = locres[option]
    end
end

return locres

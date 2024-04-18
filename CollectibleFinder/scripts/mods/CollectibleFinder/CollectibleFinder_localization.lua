local mod = get_mod("CollectibleFinder")

mod._collectibles = {
    {
        name = "grimoire",
        loc = "loc_pickup_side_mission_pocketable_01"
    },
    {
        name = "tome",
        loc = "loc_pickup_side_mission_pocketable_02"
    },
    {
        name = "collectible_01_pickup", -- Martyr's Skull
        loc = "loc_pickup_collectible"
    },
    {
        name = "idol",
        loc = "loc_destructible_01"
    },
}

mod:add_global_localize_strings({
    loc_destructible_01 = {
        en = "Heretical Idol",
        ja = "異端の偶像",
        ["zh-cn"] = "异端雕像",
    }
})

local loc = {
    mod_name = {
        en = "Collectible Finder",
        ["zh-cn"] = "收集物搜寻",
    },
    mod_description = {
        en = "Displays a notification once you are within a certain distance from the collectibles.",
        ja = "コレクタブルから一定距離内に入った際に通知を表示します。",
        ["zh-cn"] = "进入收集物一定范围内时，显示一条通知。",
    },
    toggle = {
        en = "Toggle",
        ja = "切り替え",
        ["zh-cn"] = "开关",
        ru = "Переключатели",
    },
    details = {
        en = "Detailed Settings",
        ja = "詳細設定",
        ["zh-cn"] = "详细设置",
    },
    type_notif = {
        en = "Notification",
        ja = "通知",
        ["zh-cn"] = "通知",
        ru = "Уведомления",
    },
    type_chat = {
        en = "Chat",
        ja = "チャット",
        ru = "Чат",
        ["zh-cn"] = "聊天栏",
    },
    type_both = {
        en = "Both",
        ja = "両方",
        ["zh-cn"] = "全部",
        ru = "Всё",
    },
    collectible_sensed = {
        en = "Feel the presence of a %s%s nearby...",
        ja = "%s%sの気配を近くに感じる...",
        ["zh-cn"] = "感应到附近有%s%s的存在...",
        ru = "Чувствую, что где-то рядом %s%s...",
    },
    collectible_picked_up = {
        en = "%s picked up a %s.",
        ja = "%sが%sを拾った。",
        ["zh-cn"] = "%s拾取了%s。",
        ru = "%s подбирает %s.",
    },
    collectible_dropped = {
        en = "%s dropped a %s.",
        ja = "%sが%sを落とした。",
        ["zh-cn"] = "%s丢弃了%s。",
        ru = "%s выбрасывает %s.",
    },
    collectible_given = {
        en = "%s passed %s to %s.",
        ja = "%sが%sを%sに渡した。",
        ["zh-cn"] = "%s将%s赠送给了%s",
        ru = "%s передаёт %s %s.",
    },
    debug = {
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
}

local settings = {
    search_distance = {
        en = "Search Distance",
        ja = "感知範囲",
        ["zh-cn"] = "感应范围",
        ru = "Расстояние поиска",
    },
    notif_type = {
        en = "Notification Type",
        ja = "通知方法",
        ["zh-cn"] = "通知方式",
        ru = "Стиль уведомлений",
    },
    enable_pickup_notif = {
        en = "Pick Up",
        ja = "拾う",
        ["zh-cn"] = "拾取",
        ru = "Подбор",
    },
    enable_drop_notif = {
        en = "Drop / Discard",
        ja = "落とす / 破棄",
        ["zh-cn"] = "丢弃 / 摧毁",
        ru = "Сброс",
    },
    enable_give_notif = {
        en = "Give",
        ja = "渡す",
        ["zh-cn"] = "赠送",
        ru = "Передача",
    },
    enable_repeat_notif = {
        en = "Repeat Notification",
        ja = "繰り返し通知",
        ["zh-cn"] = "重复通知",
    },
    enable_sound_cue = {
        en = "Additional Notification Sound",
        ja = "追加の通知音",
        ["zh-cn"] = "额外通知音效",
    },
    sound_cue = {
        en = "Notification Sound",
        ja = "通知音",
        ["zh-cn"] = "通知音效",
        ru = "Звук уведомления",
    },
}

for _, collectible in ipairs(mod._collectibles) do
    loc[collectible.name] = {
        en = "    " .. Localize(collectible.loc)
    }
    loc["enable_" .. collectible.name] = {
        en = Localize(collectible.loc)
    }

    for key, vals in pairs(settings) do
        loc[key .. "_" .. collectible.name] = vals
    end
end

return loc

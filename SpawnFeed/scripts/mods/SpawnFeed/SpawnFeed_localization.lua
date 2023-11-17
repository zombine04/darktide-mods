local mod = get_mod("SpawnFeed")
local Breeds = require("scripts/settings/breed/breeds")

local loc = {
    mod_name = {
        en = "Spawn Feed",
        ["zh-cn"] = "敌人生成通知",
    },
    mod_description = {
        en = "Shows a message on the combat feed when the specialist/monstorosity spawn sound is played.",
        ja = "スペシャリストやバケモノの出現音が再生された際、戦闘フィードにメッセージを表示します。",
        ["zh-cn"] = "在播放专家/怪物生成音效时，在击杀通知中显示一条消息。",
    },
    enable_combat_feed = {
        en = "Combat Feed",
        ja = "戦闘フィード",
        ["zh-cn"] = "击杀通知栏",
    },
    enable_chat = {
        en = "Chat",
        ja = "チャット",
        ["zh-cn"] = "聊天",
    },
    enable_notification = {
        en  = "Notification",
        ja = "通知",
        ["zh-cn"] = "通知",
    },
    spawn_message = {
        en = "%s Spawned",
        ja = "%sが出現した",
        ["zh-cn"] = "%s出现了",
    },
    notification_style = {
        en = "Notification Style",
        ja = "通知方法",
        ["zh-cn"] = "通知方式",
    },
    enable_count_mode = {
        en = "Enable Count Up Mode",
        ja = "カウントアップモードを有効にする",
        ["zh-cn"] = "启用计数模式",
    },
    tooltip_count_mode = {
        en = "\nShow spawn counts instead of duplicate feeds.\n\n" ..
             "Note: This feature does not apply to chat.",
        ja = "\n重複したフィードを表示する代わりに出現数を表示します。\n\n" ..
             "注意: この機能はチャットには適用されません。",
        ["zh-cn"] = "\n显示刷怪数量而不是重复发送消息。\n\n" ..
             "注意：此功能不支持聊天。",
    },
    breed_specialist = {
        en = "Specialists",
        ja = "スペシャリスト",
        ["zh-cn"] = "专家",
        ru = "Специалисты",
    },
    breed_monster = {
        en = "Monstrosities",
        ja = "バケモノ",
        ["zh-cn"] = "怪物",
        ru = "Монстры",
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
    }
}

for breed_name, breed in pairs(Breeds) do
    if breed_name ~= "human" and breed_name ~= "ogryn" and breed.display_name then
        loc[breed_name] = {
            en = Localize(breed.display_name)
        }
    end
end

return loc

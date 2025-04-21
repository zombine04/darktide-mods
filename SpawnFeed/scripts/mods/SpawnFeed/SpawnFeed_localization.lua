local mod = get_mod("SpawnFeed")
local Breeds = require("scripts/settings/breed/breeds")
local UISoundEvents = require("scripts/settings/ui/ui_sound_events")

mod.mutators = {
    chaos_hound_mutator = "chaos_hound",
    chaos_mutator_daemonhost = "chaos_daemonhost",
    cultist_mutant_mutator = "cultist_mutant",
}

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
    breed_captain = {
        en = "Captains",
        ja = "キャプテン",
    },
    default = {
        en = "Default",
        ja = "デフォルト",
        ["zh-cn"] = "默认",
        ["zh-tw"] = "預設",
        ru = "По умолчанию",
    },
    none = {
        en = "None",
        ja = "なし",
        ["zh-cn"] = "无",
        ["zh-tw"] = "無",
        ru = "Не показывать",
    },
    color = {
        en = "Color",
        ja = "色",
        ["zh-cn"] = "颜色",
        ru = "цвета",
    },
    sound = {
        en = "Sound Effect",
        ja = "効果音",
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

local c = Color.terminal_text_key_value(255, true)

local _add_child = function(breed_name, key)
    for lang, text in pairs(loc[key]) do
        local key_child = key .. "_" .. breed_name

        loc[key_child] = loc[key_child] or {}
        loc[key_child][lang] = text
    end
end

local _add_breed_localization = function(breed_name, localized_display_name)
    loc[breed_name] = {
        en = string.format("{#color(%s,%s,%s)}", c[2], c[3], c[4]) .. localized_display_name .. "{#reset()}"
    }

    _add_child(breed_name, "color")
    _add_child(breed_name, "sound")
end

for breed_name, breed in pairs(Breeds) do
    if breed_name ~= "human" and breed_name ~= "ogryn" and breed.display_name then
        local localized_display_name = Localize(breed.display_name)

        if breed_name == "chaos_mutator_daemonhost" then
            localized_display_name = Localize("loc_mutator_daemonhost_name")
        end

        _add_breed_localization(breed_name, localized_display_name)

        if breed.tags.monster and not breed.tags.witch then
            breed_name = breed_name .. "_weakened"
            localized_display_name = Localize("loc_weakened_monster_prefix", true, {
                breed = localized_display_name
            })

            _add_breed_localization(breed_name, localized_display_name)
        end
    end
end

for i, name in ipairs(Color.list) do
    local c = Color[name](255, true)
    local text = string.format("{#color(%s,%s,%s)}%s{#reset()}", c[2], c[3], c[4], name:gsub("_", " "))

    loc[name] = { en = text }
end

for event, _ in pairs(UISoundEvents) do
    loc[event] = { en = event:gsub("_", " ") }
end

return loc

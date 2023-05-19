local mod = get_mod("quick_chat")

mod._messages = mod:io_dofile("quick_chat/scripts/mods/quick_chat/chat_settings")
mod._cooldown = {
    hotkey = 5,
    cinematic = 0,
    join = 0,
    tag_book = 15,
    tag_crate = 15,
    deploy_med = 3,
    deploy_ammo = 3,
}
mod._events = {
    "mission_started",
    "mission_completed",
    "mission_failed",
    "late_joined",
    "player_joined",
    "tagged_grimoire",
    "tagged_tome",
    "tagged_medical_crate_pocketable",
    --"tagged_medical_crate_deployable",
    "tagged_ammo_cache_pocketable",
    "tagged_ammo_cache_deployable",
    "deployed_medical_crate_deployable_self",
    "deployed_medical_crate_deployable_others",
    "deployed_ammo_cache_deployable_self",
    "deployed_ammo_cache_deployable_others",
}

local loc = {
    mod_name = {
        en = "Quick Chat",
    },
    mod_description = {
        en = "Send preset messeges with hotkeys, and automatically send messages when certain events are triggered.\n" ..
             "Note: Sending a message by using a hotkey is allowed only once every " .. mod._cooldown.hotkey .. " seconds.",
        ja = "ホットキーでメッセージを送ったり、特定のイベントが発生した際に自動的にメッセージを送ることができます。\n" ..
             "注意：ホットキーを使ってメッセージを送信できるのは" .. mod._cooldown.hotkey .. "秒に1回のみです。",
    },
    enable_check_mode = {
        en = "Enable Check Mode",
        ja = "確認モードを有効にする",
    },
    check_mode_desc = {
        en = "If enabled, the messages you send will be visible only to yourself.",
        ja = "有効にした場合、メッセージは自分にのみ見えるようになります。",
    },
    none = {
        en = "None",
        ja = "なし",
    },
    events = {
        en = "Events",
        ja = "イベント",
    },
    auto_mission_started = {
        en = "Mission Started",
        ja = "ミッション開始時",
    },
    auto_mission_started_desc = {
        en = "Triggered when a mission into cinematic is played.",
        ja = "ミッションイントロの再生時に発動します。",
    },
    auto_mission_completed = {
        en = "Mission Completed",
        ja = "ミッション完了時",
    },
    auto_mission_completed_desc = {
        en = "Triggered when you successfully completed a mission and an outro cinematic is played.",
        ja = "ミッションをクリアしてアウトロが再生されたときに発動します。",
    },
    auto_mission_failed = {
        en = "Mission Failed",
        ja = "ミッション失敗時",
    },
    auto_mission_failed_desc = {
        en = "Triggered when you failed a mission and outro cinematic is played.",
        ja = "ミッションを失敗してアウトロが再生されたときに発動します。",
    },
    auto_late_joined = {
        en = "Joined a Strike Team",
        ja = "ストライクチーム参加時",
    },
    auto_late_joined_desc = {
        en = "Triggered when you joined a Strike Team.",
        ja = "ストライクチームに参加した際に発動します。",
    },
    auto_player_joined = {
        en = "Player Joined",
        ja = "プレイヤー参加時",
    },
    auto_player_joined_desc = {
        en = "Triggered when someone joined your Strike Team.",
        ja = "誰かがストライクチームに参加してきたときに発動します。",
    },
    auto_tagged_grimoire = {
        en = "Tagged Grimoires",
        ja = "魔術書のタグ時",
    },
    auto_tagged_grimoire_desc = {
        en = "Triggered when you tagged Grimoires.\n" ..
             "Cooldown: " .. mod._cooldown.tag_book .. "s",
        ja = "魔術書をタグ付けした際に発動します。\n" ..
             "クールダウン：" .. mod._cooldown.tag_book .. "秒",
    },
    auto_tagged_tome = {
        en = "Tagged Scriptures",
        ja = "聖書のタグ時",
    },
    auto_tagged_tome_desc = {
        en = "Triggered when you tagged Scriptures.\n" ..
             "Cooldown: " .. mod._cooldown.tag_book .. "s",
        ja = "聖書をタグ付けした際に発動します。\n" ..
             "クールダウン：" .. mod._cooldown.tag_book .. "秒",
    },
    auto_tagged_medical_crate_pocketable = {
        en = "Tagged Medical Crates",
        ja = "メディカルクレートタグ時",
    },
    auto_tagged_medical_crate_pocketable_desc = {
        en = "Triggered when you tagged medical crates.\n" ..
             "Cooldown: " .. mod._cooldown.tag_crate .. "s",
        ja = "メディカルクレートをタグ付けした際に発動します。\n" ..
             "クールダウン：" .. mod._cooldown.tag_crate .. "秒",
    },
    auto_tagged_medical_crate_deployable = {
        en = "Tagged Medical Crates (Deployed)",
        ja = "メディカルクレートタグ時 (設置済み)",
    },
    auto_tagged_medical_crate_deployable_desc = {
        en = "Triggered when you tagged deployed medical crates.\n" ..
             "Cooldown: " .. mod._cooldown.tag_crate .. "s",
        ja = "設置済みのメディカルクレートをタグ付けした際に発動します。\n" ..
             "クールダウン：" .. mod._cooldown.tag_crate .. "秒",
    },
    auto_tagged_ammo_cache_pocketable = {
        en = "Tagged Ammo Crates",
        ja = "弾薬クレートタグ時",
    },
    auto_tagged_ammo_cache_pocketable_desc = {
        en = "Triggered when you tagged ammo crates.\n" ..
             "Cooldown: " .. mod._cooldown.tag_crate .. "s",
        ja = "弾薬クレートをタグ付けした際に発動します。\n" ..
             "クールダウン：" .. mod._cooldown.tag_crate .. "秒",
    },
    auto_tagged_ammo_cache_deployable = {
        en = "Tagged Ammo Crates (Deployed)",
        ja = "弾薬クレートタグ時 (設置済み)",
    },
    auto_tagged_ammo_cache_deployable_desc = {
        en = "Triggered when you tagged deployed ammo crates.\n" ..
             "Cooldown: " .. mod._cooldown.tag_crate .. "s",
        ja = "設置済みの弾薬クレートをタグ付けした際に発動します。\n" ..
             "クールダウン：" .. mod._cooldown.tag_crate .. "秒",
    },
    auto_deployed_medical_crate_deployable_self = {
        en = "Deployed Medical Crates (You)",
        ja = "メディカルクレート設置時 (自分)",
    },
    auto_deployed_medical_crate_deployable_self_desc = {
        en = "Triggered when you deployed medical crates.\n" ..
             "Cooldown: " .. mod._cooldown.deploy_med .. "s",
        ja = "メディカルクレートを設置した際に発動します。\n" ..
             "クールダウン：" .. mod._cooldown.deploy_med .. "秒",
    },
    auto_deployed_medical_crate_deployable_others = {
        en = "Deployed Medical Crates (Anyone)",
        ja = "メディカルクレート設置時 (誰でも)",
    },
    auto_deployed_medical_crate_deployable_others_desc = {
        en = "Triggered when someone (includes yourself) deployed medical crates.\n" ..
             "Cooldown: " .. mod._cooldown.deploy_med .. "s\n" ..
             "Note: Currently not compatible with any placeholders.",
        ja = "誰か (自分を含む) がメディカルクレートを設置した際に発動します。\n" ..
             "クールダウン：" .. mod._cooldown.deploy_med .. "秒\n" ..
             "注意：現時点ではプレースホルダーに対応していません。",
    },
    auto_deployed_ammo_cache_deployable_self = {
        en = "Deployed Ammo Crates (You)",
        ja = "弾薬クレート設置時 (自分)",
    },
    auto_deployed_ammo_cache_deployable_self_desc = {
        en = "Triggered when you deployed ammo crates.\n" ..
             "Cooldown: " .. mod._cooldown.deploy_ammo .. "s",
        ja = "弾薬クレートを設置した際に発動します。\n" ..
             "クールダウン：" .. mod._cooldown.deploy_ammo .. "秒",
    },
    auto_deployed_ammo_cache_deployable_others = {
        en = "Deployed Ammo Crates (Anyone)",
        ja = "弾薬クレート設置時 (誰でも)",
    },
    auto_deployed_ammo_cache_deployable_others_desc = {
        en = "Triggered when someone (includes yourself) deployed ammo crates.\n" ..
             "Cooldown: " .. mod._cooldown.deploy_ammo .. "s\n" ..
             "Note: Currently not compatible with any placeholders.",
        ja = "誰か (自分を含む) が弾薬クレートを設置した際に発動します。\n" ..
             "クールダウン：" .. mod._cooldown.deploy_ammo .. "秒\n" ..
             "注意：現時点ではプレースホルダーに対応していません。",
    },
    auto_player_downed = {
        en = "Player Downed",
        ja = "プレイヤーダウン時",
    },
    auto_player_downed_desc = {
        en = "Triggered when someone downed.",
        ja = "誰かがダウンした際に発動します。",
    },
    auto_player_died = {
        en = "Player Died",
        ja = "プレイヤー死亡時",
    },
    auto_player_died_desc = {
        en = "Triggered when someone died.",
        ja = "誰かが死亡した際に発動します。",
    },
    hotkeys = {
        en = "Hotkeys",
        ja = "ホットキー",
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
}

for _, setting in pairs(mod._messages) do
    local id = setting.id
    local tooltip = "tooltip_" .. id

    loc[id] = {}
    loc[tooltip] = {}
    loc[id].en = setting.title
    loc[tooltip].en = setting.message
end

return loc
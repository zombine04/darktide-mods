local mod = get_mod("quick_chat")

mod._messages = mod:io_dofile("quick_chat/scripts/mods/quick_chat/chat_settings")
mod._interval = 5
mod._events = {
    "mission_started",
    "mission_completed",
    "mission_failed",
    "late_joined",
    "player_joined",
    --"player_downed",
    --"player_died",
}

local loc = {
    mod_name = {
        en = "Quick Chat",
    },
    mod_description = {
        en = "Send preset messeges with hotkeys, and automatically send messages when certain events are triggered.\n" ..
             "Note: Sending a message by using a hotkey is allowed only once every " .. mod._interval .. " seconds.",
        ja = "ホットキーでメッセージを送ったり、特定のイベントが発生した際に自動的にメッセージを送ることができます。\n" ..
             "注意：ホットキーを使ってメッセージを送信できるのは" .. mod._interval .. "秒に1回のみです。",
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
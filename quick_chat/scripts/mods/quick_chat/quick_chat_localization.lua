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
        ["zh-cn"] = "快速聊天",
    },
    mod_description = {
        en = "Send preset messeges with hotkeys, and automatically send messages when certain events are triggered.\n" ..
             "Note: Sending a message by using a hotkey is allowed only once every " .. mod._cooldown.hotkey .. " seconds.",
        ja = "ホットキーでメッセージを送ったり、特定のイベントが発生した際に自動的にメッセージを送ることができます。\n" ..
             "注意：ホットキーを使ってメッセージを送信できるのは" .. mod._cooldown.hotkey .. "秒に1回のみです。",
        ["zh-cn"] = "通过快捷键，或在特定情况下自动发送预先设定的消息。\n" ..
             "注意：通过快捷键发送消息仅允许每" .. mod._cooldown.hotkey .. "秒发送一次。",
    },
    enable_check_mode = {
        en = "Enable Check Mode",
        ja = "確認モードを有効にする",
        ["zh-cn"] = "启用检查模式",
    },
    enable_in_hub = {
        en = "Enable in the Mourningstar",
        ja = "モーニングスター内でも有効にする",
        ["zh-cn"] = "在哀星号上启用",
    },
    check_mode_desc = {
        en = "If enabled, the messages you send will be visible only to yourself.",
        ja = "有効にした場合、メッセージは自分にのみ見えるようになります。",
        ["zh-cn"] = "如果启用，则你发送的消息仅对自己可见。",
    },
    none = {
        en = "None",
        ja = "なし",
        ["zh-cn"] = "无",
    },
    events = {
        en = "Events",
        ja = "イベント",
        ["zh-cn"] = "事件",
    },
    auto_mission_started = {
        en = "Mission Started",
        ja = "ミッション開始時",
        ["zh-cn"] = "任务开始时",
    },
    auto_mission_started_desc = {
        en = "Triggered when a mission into cinematic is played.",
        ja = "ミッションイントロの再生時に発動します。",
        ["zh-cn"] = "在播放任务开始过场动画时触发。",
    },
    auto_mission_completed = {
        en = "Mission Completed",
        ja = "ミッション完了時",
        ["zh-cn"] = "任务完成时",
    },
    auto_mission_completed_desc = {
        en = "Triggered when you successfully completed a mission and an outro cinematic is played.",
        ja = "ミッションをクリアしてアウトロが再生されたときに発動します。",
        ["zh-cn"] = "在任务成功完成，并播放任务开始过场动画时触发。",
    },
    auto_mission_failed = {
        en = "Mission Failed",
        ja = "ミッション失敗時",
        ["zh-cn"] = "任务失败时",
    },
    auto_mission_failed_desc = {
        en = "Triggered when you failed a mission and outro cinematic is played.",
        ja = "ミッションを失敗してアウトロが再生されたときに発動します。",
        ["zh-cn"] = "在任务失败，并播放任务开始过场动画时触发。",
    },
    auto_late_joined = {
        en = "Joined a Strike Team",
        ja = "ストライクチーム参加時",
        ["zh-cn"] = "加入打击小队时",
    },
    auto_late_joined_desc = {
        en = "Triggered when you joined a Strike Team.",
        ja = "ストライクチームに参加した際に発動します。",
        ["zh-cn"] = "在你加入打击小队时触发。",
    },
    auto_player_joined = {
        en = "Player Joined",
        ja = "プレイヤー参加時",
        ["zh-cn"] = "玩家加入时",
    },
    auto_player_joined_desc = {
        en = "Triggered when someone joined your Strike Team.",
        ja = "誰かがストライクチームに参加してきたときに発動します。",
        ["zh-cn"] = "在有人加入打击小队时触发。",
    },
    auto_tagged_grimoire = {
        en = "Tagged Grimoires",
        ja = "魔術書のタグ時",
        ["zh-cn"] = "标记魔法书",
    },
    auto_tagged_grimoire_desc = {
        en = "Triggered when you tagged Grimoires.\n" ..
             "Cooldown: " .. mod._cooldown.tag_book .. "s",
        ja = "魔術書をタグ付けした際に発動します。\n" ..
             "クールダウン：" .. mod._cooldown.tag_book .. "秒",
        ["zh-cn"] = "在你标记魔法书时触发。\n" ..
             "冷却：" .. mod._cooldown.tag_book .. " 秒",
    },
    auto_tagged_tome = {
        en = "Tagged Scriptures",
        ja = "聖書のタグ時",
        ["zh-cn"] = "标记圣经",
    },
    auto_tagged_tome_desc = {
        en = "Triggered when you tagged Scriptures.\n" ..
             "Cooldown: " .. mod._cooldown.tag_book .. "s",
        ja = "聖書をタグ付けした際に発動します。\n" ..
             "クールダウン：" .. mod._cooldown.tag_book .. "秒",
        ["zh-cn"] = "在你标记圣经时触发。\n" ..
             "冷却：" .. mod._cooldown.tag_book .. " 秒",
    },
    auto_tagged_medical_crate_pocketable = {
        en = "Tagged Medical Crates",
        ja = "メディカルクレートタグ時",
        ["zh-cn"] = "标记医疗箱",
    },
    auto_tagged_medical_crate_pocketable_desc = {
        en = "Triggered when you tagged medical crates.\n" ..
             "Cooldown: " .. mod._cooldown.tag_crate .. "s",
        ja = "メディカルクレートをタグ付けした際に発動します。\n" ..
             "クールダウン：" .. mod._cooldown.tag_crate .. "秒",
        ["zh-cn"] = "在你标记医疗箱时触发。\n" ..
             "冷却：" .. mod._cooldown.tag_crate .. " 秒",
    },
    auto_tagged_medical_crate_deployable = {
        en = "Tagged Medical Crates (Deployed)",
        ja = "メディカルクレートタグ時 (設置済み)",
        ["zh-cn"] = "标记医疗箱（已部署的）",
    },
    auto_tagged_medical_crate_deployable_desc = {
        en = "Triggered when you tagged deployed medical crates.\n" ..
             "Cooldown: " .. mod._cooldown.tag_crate .. "s",
        ja = "設置済みのメディカルクレートをタグ付けした際に発動します。\n" ..
             "クールダウン：" .. mod._cooldown.tag_crate .. "秒",
        ["zh-cn"] = "在你标记已部署的医疗箱时触发。\n" ..
             "冷却：" .. mod._cooldown.tag_crate .. " 秒",
    },
    auto_tagged_ammo_cache_pocketable = {
        en = "Tagged Ammo Crates",
        ja = "弾薬クレートタグ時",
        ["zh-cn"] = "标记弹药箱",
    },
    auto_tagged_ammo_cache_pocketable_desc = {
        en = "Triggered when you tagged ammo crates.\n" ..
             "Cooldown: " .. mod._cooldown.tag_crate .. "s",
        ja = "弾薬クレートをタグ付けした際に発動します。\n" ..
             "クールダウン：" .. mod._cooldown.tag_crate .. "秒",
        ["zh-cn"] = "在你标记弹药箱时触发。\n" ..
             "冷却：" .. mod._cooldown.tag_crate .. " 秒",
    },
    auto_tagged_ammo_cache_deployable = {
        en = "Tagged Ammo Crates (Deployed)",
        ja = "弾薬クレートタグ時 (設置済み)",
        ["zh-cn"] = "标记弹药箱（已部署的）",
    },
    auto_tagged_ammo_cache_deployable_desc = {
        en = "Triggered when you tagged deployed ammo crates.\n" ..
             "Cooldown: " .. mod._cooldown.tag_crate .. "s",
        ja = "設置済みの弾薬クレートをタグ付けした際に発動します。\n" ..
             "クールダウン：" .. mod._cooldown.tag_crate .. "秒",
        ["zh-cn"] = "在你标记已部署的弹药箱时触发。\n" ..
             "冷却：" .. mod._cooldown.tag_crate .. " 秒",
    },
    auto_deployed_medical_crate_deployable_self = {
        en = "Deployed Medical Crates (You)",
        ja = "メディカルクレート設置時 (自分)",
        ["zh-cn"] = "部署医疗箱（自己）",
    },
    auto_deployed_medical_crate_deployable_self_desc = {
        en = "Triggered when you deployed medical crates.\n" ..
             "Cooldown: " .. mod._cooldown.deploy_med .. "s",
        ja = "メディカルクレートを設置した際に発動します。\n" ..
             "クールダウン：" .. mod._cooldown.deploy_med .. "秒",
        ["zh-cn"] = "在你部署医疗箱时触发。\n" ..
             "冷却：" .. mod._cooldown.deploy_med .. " 秒",
    },
    auto_deployed_medical_crate_deployable_others = {
        en = "Deployed Medical Crates (Anyone)",
        ja = "メディカルクレート設置時 (誰でも)",
        ["zh-cn"] = "部署医疗箱（所有人）",
    },
    auto_deployed_medical_crate_deployable_others_desc = {
        en = "Triggered when someone (includes yourself) deployed medical crates.\n" ..
             "Cooldown: " .. mod._cooldown.deploy_med .. "s\n" ..
             "Note: Currently not compatible with any placeholders.",
        ja = "誰か (自分を含む) がメディカルクレートを設置した際に発動します。\n" ..
             "クールダウン：" .. mod._cooldown.deploy_med .. "秒\n" ..
             "注意：現時点ではプレースホルダーに対応していません。",
        ["zh-cn"] = "在有人（包括你自己）部署医疗箱时触发。\n" ..
             "冷却：" .. mod._cooldown.deploy_med .. " 秒\n" ..
             "注意：当前不兼容任何占位符。",
    },
    auto_deployed_ammo_cache_deployable_self = {
        en = "Deployed Ammo Crates (You)",
        ja = "弾薬クレート設置時 (自分)",
        ["zh-cn"] = "部署弹药箱（自己）",
    },
    auto_deployed_ammo_cache_deployable_self_desc = {
        en = "Triggered when you deployed ammo crates.\n" ..
             "Cooldown: " .. mod._cooldown.deploy_ammo .. "s",
        ja = "弾薬クレートを設置した際に発動します。\n" ..
             "クールダウン：" .. mod._cooldown.deploy_ammo .. "秒",
        ["zh-cn"] = "在你部署弹药箱时触发。\n" ..
             "冷却：" .. mod._cooldown.deploy_ammo .. " 秒",
    },
    auto_deployed_ammo_cache_deployable_others = {
        en = "Deployed Ammo Crates (Anyone)",
        ja = "弾薬クレート設置時 (誰でも)",
        ["zh-cn"] = "部署弹药箱（所有人）",
    },
    auto_deployed_ammo_cache_deployable_others_desc = {
        en = "Triggered when someone (includes yourself) deployed ammo crates.\n" ..
             "Cooldown: " .. mod._cooldown.deploy_ammo .. "s\n" ..
             "Note: Currently not compatible with any placeholders.",
        ja = "誰か (自分を含む) が弾薬クレートを設置した際に発動します。\n" ..
             "クールダウン：" .. mod._cooldown.deploy_ammo .. "秒\n" ..
             "注意：現時点ではプレースホルダーに対応していません。",
        ["zh-cn"] = "在有人（包括你自己）部署弹药箱时触发。\n" ..
             "冷却：" .. mod._cooldown.deploy_ammo .. " 秒\n" ..
             "注意：当前不兼容任何占位符。",
    },
    auto_player_downed = {
        en = "Player Downed",
        ja = "プレイヤーダウン時",
        ["zh-cn"] = "玩家倒地时",
    },
    auto_player_downed_desc = {
        en = "Triggered when someone downed.",
        ja = "誰かがダウンした際に発動します。",
        ["zh-cn"] = "在玩家倒地时触发。",
    },
    auto_player_died = {
        en = "Player Died",
        ja = "プレイヤー死亡時",
        ["zh-cn"] = "玩家死亡时",
    },
    auto_player_died_desc = {
        en = "Triggered when someone died.",
        ja = "誰かが死亡した際に発動します。",
        ["zh-cn"] = "在玩家死亡时触发。",
    },
    hotkeys = {
        en = "Hotkeys",
        ja = "ホットキー",
        ["zh-cn"] = "快捷键",
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
    local message = ""

    if type(setting.message) == "table" then
        for i, v in ipairs(setting.message) do
            local prefix = i == 1 and "- " or "\n- "
            message = message .. prefix .. v
        end
    else
        message = "- " .. setting.message
    end

    loc[id] = {}
    loc[tooltip] = {}
    loc[id].en = setting.title
    loc[tooltip].en = message
end

return loc

local mod = get_mod("QuickKick")

mod._num_max_player = 3

local loc = {
    mod_name = {
        en = "Quick Kick",
    },
    mod_description = {
        en = "Provides a new UI for quicker access to initiate a kick vote.",
        ja = "より素早くキック投票を始められる新しいUIを提供します。",
    },
    enable_cursor = {
        en = "Use Cursor",
        ja = "カーソルを使用する",
    },
    tooltip_enable_cursor = {
        en = "Disable In-game inputs while the player list is displayed, and allow using cursor to select a player.",
        ja = "プレイヤー一覧が表示されている間はゲーム内入力を無効にし、カーソルでプレイヤーを選択できるようにします。",
    },
    enable_hide_bots = {
        en = "Hide Bots in the List",
        ja = "ボットをリストに表示しない",
    },
    auto_close_time = {
        en = "Auto Close Duration (sec)",
        ja = "自動非表示までの長さ（秒）",
    },
    tooltip_auto_close_time = {
        en = "0 = Disable Auto Close",
        ja = "0 = 自動非表示を無効にする",
    },
    keybind = {
        en = "Keybind",
        ja = "キーバインド",
        ["zh-cn"] = "快捷键",
    },
    keybind_players = {
        en = "Toggle Player List",
        ja = "プレイヤー一覧の切り替え",
    },
    keybind_player = {
        en = "Select Player ",
        ja = "選択：プレイヤー",
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
    kick_vote_initiated = {
        en = "Kick vote initiated:\n%s",
        ja = "キック投票を開始しました：\n%s",
    },
    failed_initiate_kick_vote = {
        en = "Failed to initiate kick vote.",
        ja = "キック投票の開始に失敗しました。",
    },
    not_in_mission = {
        en = "Not in mission.",
        ja = "ミッション中ではありません。",
    },
    not_enough_players = {
        en = "Not enough players.",
        ja = "プレイヤーが足りません。",
    },
    reached_max_num_votings = {
        en = "Other kick vote is currently ongoing.",
        ja = "現在他のキック投票が進行中です。",
    },
    must_wait_cooldown = {
        en  = "Must wait %s seconds before starting a new vote.",
        ja = "新しく投票を始めるには%s秒待つ必要があります。",
    },
    cannot_kick_bot = {
        en = "Bots cannot be kicked.",
        ja = "ボットをキックすることはできません。"
    }
}

for i = 1, mod._num_max_player do
    local key = "keybind_player_" .. i

    loc[key] = {}

    for lang, text in pairs(loc.keybind_player) do
        loc[key][lang] = text .. i
    end
end

return loc
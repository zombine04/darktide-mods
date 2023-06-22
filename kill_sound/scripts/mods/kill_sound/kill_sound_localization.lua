
local mod = get_mod("kill_sound")

mod._sound_events = mod:io_dofile("kill_sound/scripts/mods/kill_sound/sound_events")
mod._events = {
    "kill",
    "teammate_kill",
    "weakspot_kill",
    "instant_kill",
    "bleeding_kill",
    "burning_kill",
    "warpfire_kill",
    "warp_kill"
}
mod._enemy_types = {
    "roamer",
    "elite",
    "special",
    --"monster"
}

local loc = {
    mod_name = {
        en = "Kill Sound",
    },
    mod_description = {
        en = "Change or add sound effecs when enemies died.",
    },
    enable_default_sound = {
        en = "Play default sounds too",
        ja = "デフォルトのサウンドも再生する",
    },
    roamer = {
        en = "Roamers",
        ja = "通常敵",
        ["zh-cn"] = "普通敌人",
        ru = "Бродяги",
    },
    elite = {
        en = "Elites",
        ja = "上位者",
        ["zh-cn"] = "精英",
        ru = "Элита",
    },
    special = {
        en = "Specialists",
        ja = "スペシャリスト",
        ["zh-cn"] = "专家",
        ru = "Специалисты",
    },
    monster = {
        en = "Monstrosities",
        ja = "バケモノ",
        ["zh-cn"] = "怪物",
        ru = "Чудовища",
    },
    event_kill = {
        en = "Kill",
        ja = "キル",
    },
    event_teammate_kill = {
        en = "Kill (Teammates)",
        ja = "キル (チームメイト)",
    },
    event_weakspot_kill = {
        en = "Weakspot Kill",
        ja = "弱点キル",
    },
    event_instant_kill = {
        en = "Instant Kill",
        ja = "即死キル",
    },
    event_bleeding_kill = {
        en = "Bleeding Kill",
        ja = "出血キル",
    },
    event_burning_kill = {
        en = "Burning Kill",
        ja = "炎上キル",
    },
    event_warpfire_kill = {
        en = "Soulblaze Kill",
        ja = "ソウルファイアキル",
    },
    event_warp_kill = {
        en = "Warp Attack Kill",
        ja = "ワープ攻撃キル",
    },
    none = {
        en = "None",
        ja = "なし",
    }
}

for _, enemy_type in ipairs(mod._enemy_types) do
    for _, event in ipairs(mod._events) do
        event = "event_" .. event
        if loc[event] then
            for lang, val in pairs(loc[event]) do
                local key = event .. "_" .. enemy_type

                loc[key] = loc[key] or {}
                loc[key][lang] = val
            end
        end
    end
end

for event, _ in pairs(mod._sound_events) do
    loc[event] = { en = event }
end

return loc
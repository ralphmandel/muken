bald_1__power_rank_11 = class ({})
bald_1__power_rank_12 = class ({})
bald_1__power_rank_21 = class ({})
bald_1__power_rank_22 = class ({})
bald_1__power_rank_31 = class ({})
bald_1__power_rank_32 = class ({})
bald_1__power_rank_41 = class ({})
bald_1__power_rank_42 = class ({})

bald_2__bash_rank_11 = class ({})
bald_2__bash_rank_12 = class ({})
bald_2__bash_rank_21 = class ({})
bald_2__bash_rank_22 = class ({})
bald_2__bash_rank_31 = class ({})
bald_2__bash_rank_32 = class ({})
bald_2__bash_rank_41 = class ({})
bald_2__bash_rank_42 = class ({})

bald_3__inner_rank_11 = class ({})
bald_3__inner_rank_12 = class ({})
bald_3__inner_rank_21 = class ({})
bald_3__inner_rank_22 = class ({})
bald_3__inner_rank_31 = class ({})
bald_3__inner_rank_32 = class ({})
bald_3__inner_rank_41 = class ({})
bald_3__inner_rank_42 = class ({})

bald_4__clean_rank_11 = class ({})
bald_4__clean_rank_12 = class ({})
bald_4__clean_rank_21 = class ({})
bald_4__clean_rank_22 = class ({})
bald_4__clean_rank_31 = class ({})
bald_4__clean_rank_32 = class ({})
bald_4__clean_rank_41 = class ({})
bald_4__clean_rank_42 = class ({})

bald_5__spike_rank_11 = class ({})
bald_5__spike_rank_12 = class ({})
bald_5__spike_rank_21 = class ({})
bald_5__spike_rank_22 = class ({})
bald_5__spike_rank_31 = class ({})
bald_5__spike_rank_32 = class ({})
bald_5__spike_rank_41 = class ({})
bald_5__spike_rank_42 = class ({})

bald_u__vitality_rank_11 = class ({})
bald_u__vitality_rank_12 = class ({})
bald_u__vitality_rank_21 = class ({})
bald_u__vitality_rank_22 = class ({})
bald_u__vitality_rank_31 = class ({})
bald_u__vitality_rank_32 = class ({})
bald_u__vitality_rank_41 = class ({})
bald_u__vitality_rank_42 = class ({})

bald__precache = class ({})
LinkLuaModifier("bald__special_values", "heroes/bald/bald__special_values", LUA_MODIFIER_MOTION_NONE)

function bald__precache:GetIntrinsicModifierName()
    return "bald__special_values"
end

function bald__precache:Spawn()
    if self:IsTrained() == false then
        self:UpgradeAbility(true)
        self:SetLevel(100)
    end
end

function bald__precache:Precache(context)
    PrecacheResource("soundfile", "soundevents/soundevent_bald.vsndevts", context)

    PrecacheResource("particle", "particles/econ/items/spirit_breaker/spirit_breaker_weapon_ti8/spirit_breaker_bash_ti8.vpcf", context)
    PrecacheResource("particle", "particles/bald/bald_dash/bald_dash.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_timer.vpcf", context)
    PrecacheResource("particle", "particles/bald/bald_inner/bald_inner_owner.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_oracle/oracle_false_promise.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_oracle/oracle_false_promise_attacked.vpcf", context)
    PrecacheResource("particle", "particles/bald/bald_zap/bald_zap_attack_heavy_ti_5.vpcf", context)
    PrecacheResource("particle", "particles/bald/bald_ion/bald_ion.vpcf", context)
    PrecacheResource("particle", "particles/bald/bald_quill/bald_quill_spray.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_bristleback/bristleback_quill_spray_impact.vpcf", context)
    PrecacheResource("particle", "particles/items3_fx/star_emblem_friend_shield.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/dark_seer/dark_seer_ti8_immortal_arms/dark_seer_ti8_immortal_ion_shell_dmg_golden.vpcf", context)
    PrecacheResource("particle", "particles/bald/bald_vitality/bald_vitality_status_efx.vpcf", context)
    PrecacheResource("particle", "particles/bald/bald_vitality/bald_vitality_buff.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/bristleback/bristleback_warrior_of_arena/bristleback_warrior_of_arena_arms.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/bristleback/bristleback_warrior_of_arena/bristleback_warrior_of_arena_back.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/bristleback/bristleback_warrior_of_arena/bristleback_warrior_of_arena_head.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/bristleback/bristleback_warrior_of_arena/bristleback_warrior_of_arena_weapon.vpcf", context)

    PrecacheResource("model", "models/items/bristleback/bristleback_warrior_of_arena_arms/bristleback_warrior_of_arena_arms.vmdl", context)
    PrecacheResource("model", "models/items/bristleback/bristleback_warrior_of_arena_back/bristleback_warrior_of_arena_back.vmdl", context)
    PrecacheResource("model", "models/items/bristleback/bristleback_warrior_of_arena_head/bristleback_warrior_of_arena_head.vmdl", context)
    PrecacheResource("model", "models/items/bristleback/bristleback_warrior_of_arena_neck/bristleback_warrior_of_arena_neck.vmdl", context)
    PrecacheResource("model", "models/items/bristleback/bristleback_warrior_of_arena_weapon/bristleback_warrior_of_arena_weapon.vmdl", context)
end
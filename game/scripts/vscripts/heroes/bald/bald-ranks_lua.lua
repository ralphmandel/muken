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
end
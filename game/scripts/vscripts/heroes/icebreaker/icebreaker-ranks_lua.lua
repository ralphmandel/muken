icebreaker_1__frost_rank_11 = class ({})
icebreaker_1__frost_rank_12 = class ({})
icebreaker_1__frost_rank_21 = class ({})
icebreaker_1__frost_rank_22 = class ({})
icebreaker_1__frost_rank_31 = class ({})
icebreaker_1__frost_rank_32 = class ({})
icebreaker_1__frost_rank_41 = class ({})
icebreaker_1__frost_rank_42 = class ({})

icebreaker_2__wave_rank_11 = class ({})
icebreaker_2__wave_rank_12 = class ({})
icebreaker_2__wave_rank_21 = class ({})
icebreaker_2__wave_rank_22 = class ({})
icebreaker_2__wave_rank_31 = class ({})
icebreaker_2__wave_rank_32 = class ({})
icebreaker_2__wave_rank_41 = class ({})
icebreaker_2__wave_rank_42 = class ({})

icebreaker_3__shard_rank_11 = class ({})
icebreaker_3__shard_rank_12 = class ({})
icebreaker_3__shard_rank_21 = class ({})
icebreaker_3__shard_rank_22 = class ({})
icebreaker_3__shard_rank_31 = class ({})
icebreaker_3__shard_rank_32 = class ({})
icebreaker_3__shard_rank_41 = class ({})
icebreaker_3__shard_rank_42 = class ({})

icebreaker_4__mirror_rank_11 = class ({})
icebreaker_4__mirror_rank_12 = class ({})
icebreaker_4__mirror_rank_21 = class ({})
icebreaker_4__mirror_rank_22 = class ({})
icebreaker_4__mirror_rank_31 = class ({})
icebreaker_4__mirror_rank_32 = class ({})
icebreaker_4__mirror_rank_41 = class ({})
icebreaker_4__mirror_rank_42 = class ({})

icebreaker_5__shivas_rank_11 = class ({})
icebreaker_5__shivas_rank_12 = class ({})
icebreaker_5__shivas_rank_21 = class ({})
icebreaker_5__shivas_rank_22 = class ({})
icebreaker_5__shivas_rank_31 = class ({})
icebreaker_5__shivas_rank_32 = class ({})
icebreaker_5__shivas_rank_41 = class ({})
icebreaker_5__shivas_rank_42 = class ({})

icebreaker_u__blink_rank_11 = class ({})
icebreaker_u__blink_rank_12 = class ({})
icebreaker_u__blink_rank_21 = class ({})
icebreaker_u__blink_rank_22 = class ({})
icebreaker_u__blink_rank_31 = class ({})
icebreaker_u__blink_rank_32 = class ({})
icebreaker_u__blink_rank_41 = class ({})
icebreaker_u__blink_rank_42 = class ({})

icebreaker__precache = class ({})
LinkLuaModifier("icebreaker__special_values", "heroes/icebreaker/icebreaker__special_values", LUA_MODIFIER_MOTION_NONE)

function icebreaker__precache:GetIntrinsicModifierName()
    return "icebreaker__special_values"
end

function icebreaker__precache:Spawn()
    if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function icebreaker__precache:Precache(context)
    --PrecacheResource("soundfile", "soundevents/soundevent_icebreaker.vsndevts", context)
end
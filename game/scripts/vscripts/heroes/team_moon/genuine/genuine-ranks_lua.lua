genuine_1__shooting_rank_11 = class ({})
genuine_1__shooting_rank_12 = class ({})
genuine_1__shooting_rank_21 = class ({})
genuine_1__shooting_rank_22 = class ({})
genuine_1__shooting_rank_31 = class ({})
genuine_1__shooting_rank_32 = class ({})
genuine_1__shooting_rank_41 = class ({})
genuine_1__shooting_rank_42 = class ({})

genuine_2__fallen_rank_11 = class ({})
genuine_2__fallen_rank_12 = class ({})
genuine_2__fallen_rank_21 = class ({})
genuine_2__fallen_rank_22 = class ({})
genuine_2__fallen_rank_31 = class ({})
genuine_2__fallen_rank_32 = class ({})
genuine_2__fallen_rank_41 = class ({})
genuine_2__fallen_rank_42 = class ({})

genuine_3__morning_rank_11 = class ({})
genuine_3__morning_rank_12 = class ({})
genuine_3__morning_rank_21 = class ({})
genuine_3__morning_rank_22 = class ({})
genuine_3__morning_rank_31 = class ({})
genuine_3__morning_rank_32 = class ({})
genuine_3__morning_rank_41 = class ({})
genuine_3__morning_rank_42 = class ({})

genuine_4__awakening_rank_11 = class ({})
genuine_4__awakening_rank_12 = class ({})
genuine_4__awakening_rank_21 = class ({})
genuine_4__awakening_rank_22 = class ({})
genuine_4__awakening_rank_31 = class ({})
genuine_4__awakening_rank_32 = class ({})
genuine_4__awakening_rank_41 = class ({})
genuine_4__awakening_rank_42 = class ({})

genuine_5__nightfall_rank_11 = class ({})
genuine_5__nightfall_rank_12 = class ({})
genuine_5__nightfall_rank_21 = class ({})
genuine_5__nightfall_rank_22 = class ({})
genuine_5__nightfall_rank_31 = class ({})
genuine_5__nightfall_rank_32 = class ({})
genuine_5__nightfall_rank_41 = class ({})
genuine_5__nightfall_rank_42 = class ({})

genuine_u__star_rank_11 = class ({})
genuine_u__star_rank_12 = class ({})
genuine_u__star_rank_21 = class ({})
genuine_u__star_rank_22 = class ({})
genuine_u__star_rank_31 = class ({})
genuine_u__star_rank_32 = class ({})
genuine_u__star_rank_41 = class ({})
genuine_u__star_rank_42 = class ({})

genuine__precache = class ({})
LinkLuaModifier("genuine_special_values", "heroes/team_moon/genuine/genuine-special_values", LUA_MODIFIER_MOTION_NONE)

function genuine__precache:GetIntrinsicModifierName()
  return "genuine_special_values"
end

function genuine__precache:Spawn()
	if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function genuine__precache:Precache(context)
  --PrecacheResource("soundfile", "soundevents/soundevent_genuine.vsndevts", context)
end
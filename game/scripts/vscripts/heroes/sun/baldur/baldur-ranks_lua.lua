baldur_1__power_rank_11 = class ({})
baldur_1__power_rank_12 = class ({})
baldur_1__power_rank_21 = class ({})
baldur_1__power_rank_22 = class ({})
baldur_1__power_rank_31 = class ({})
baldur_1__power_rank_32 = class ({})
baldur_1__power_rank_41 = class ({})
baldur_1__power_rank_42 = class ({})

baldur_2__dash_rank_11 = class ({})
baldur_2__dash_rank_12 = class ({})
baldur_2__dash_rank_21 = class ({})
baldur_2__dash_rank_22 = class ({})
baldur_2__dash_rank_31 = class ({})
baldur_2__dash_rank_32 = class ({})
baldur_2__dash_rank_41 = class ({})
baldur_2__dash_rank_42 = class ({})

baldur_3__barrier_rank_11 = class ({})
baldur_3__barrier_rank_12 = class ({})
baldur_3__barrier_rank_21 = class ({})
baldur_3__barrier_rank_22 = class ({})
baldur_3__barrier_rank_31 = class ({})
baldur_3__barrier_rank_32 = class ({})
baldur_3__barrier_rank_41 = class ({})
baldur_3__barrier_rank_42 = class ({})

baldur_4__rear_rank_11 = class ({})
baldur_4__rear_rank_12 = class ({})
baldur_4__rear_rank_21 = class ({})
baldur_4__rear_rank_22 = class ({})
baldur_4__rear_rank_31 = class ({})
baldur_4__rear_rank_32 = class ({})
baldur_4__rear_rank_41 = class ({})
baldur_4__rear_rank_42 = class ({})

baldur_5__fire_rank_11 = class ({})
baldur_5__fire_rank_12 = class ({})
baldur_5__fire_rank_21 = class ({})
baldur_5__fire_rank_22 = class ({})
baldur_5__fire_rank_31 = class ({})
baldur_5__fire_rank_32 = class ({})
baldur_5__fire_rank_41 = class ({})
baldur_5__fire_rank_42 = class ({})

baldur_u__endurance_rank_11 = class ({})
baldur_u__endurance_rank_12 = class ({})
baldur_u__endurance_rank_21 = class ({})
baldur_u__endurance_rank_22 = class ({})
baldur_u__endurance_rank_31 = class ({})
baldur_u__endurance_rank_32 = class ({})
baldur_u__endurance_rank_41 = class ({})
baldur_u__endurance_rank_42 = class ({})

baldur__precache = class ({})
LinkLuaModifier("baldur_special_values", "heroes/sun/baldur/baldur-special_values", LUA_MODIFIER_MOTION_NONE)

function baldur__precache:GetIntrinsicModifierName()
  return "baldur_special_values"
end

function baldur__precache:Spawn()
	if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function baldur__precache:Precache(context)
end
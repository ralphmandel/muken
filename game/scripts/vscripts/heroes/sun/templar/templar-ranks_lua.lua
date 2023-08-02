templar_1__shield_rank_11 = class ({})
templar_1__shield_rank_12 = class ({})
templar_1__shield_rank_21 = class ({})
templar_1__shield_rank_22 = class ({})
templar_1__shield_rank_31 = class ({})
templar_1__shield_rank_32 = class ({})
templar_1__shield_rank_41 = class ({})
templar_1__shield_rank_42 = class ({})

templar_2__barrier_rank_11 = class ({})
templar_2__barrier_rank_12 = class ({})
templar_2__barrier_rank_21 = class ({})
templar_2__barrier_rank_22 = class ({})
templar_2__barrier_rank_31 = class ({})
templar_2__barrier_rank_32 = class ({})
templar_2__barrier_rank_41 = class ({})
templar_2__barrier_rank_42 = class ({})

templar_3__circle_rank_11 = class ({})
templar_3__circle_rank_12 = class ({})
templar_3__circle_rank_21 = class ({})
templar_3__circle_rank_22 = class ({})
templar_3__circle_rank_31 = class ({})
templar_3__circle_rank_32 = class ({})
templar_3__circle_rank_41 = class ({})
templar_3__circle_rank_42 = class ({})

templar_4__hammer_rank_11 = class ({})
templar_4__hammer_rank_12 = class ({})
templar_4__hammer_rank_21 = class ({})
templar_4__hammer_rank_22 = class ({})
templar_4__hammer_rank_31 = class ({})
templar_4__hammer_rank_32 = class ({})
templar_4__hammer_rank_41 = class ({})
templar_4__hammer_rank_42 = class ({})

templar_5__reborn_rank_11 = class ({})
templar_5__reborn_rank_12 = class ({})
templar_5__reborn_rank_21 = class ({})
templar_5__reborn_rank_22 = class ({})
templar_5__reborn_rank_31 = class ({})
templar_5__reborn_rank_32 = class ({})
templar_5__reborn_rank_41 = class ({})
templar_5__reborn_rank_42 = class ({})

templar_u__praise_rank_11 = class ({})
templar_u__praise_rank_12 = class ({})
templar_u__praise_rank_21 = class ({})
templar_u__praise_rank_22 = class ({})
templar_u__praise_rank_31 = class ({})
templar_u__praise_rank_32 = class ({})
templar_u__praise_rank_41 = class ({})
templar_u__praise_rank_42 = class ({})

templar__precache = class ({})
LinkLuaModifier("templar_special_values", "heroes/sun/templar/templar-special_values", LUA_MODIFIER_MOTION_NONE)

function templar__precache:GetIntrinsicModifierName()
  return "templar_special_values"
end

function templar__precache:Spawn()
	if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function templar__precache:Precache(context)
end
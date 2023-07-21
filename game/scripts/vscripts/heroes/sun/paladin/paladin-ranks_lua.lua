paladin_1__link_rank_11 = class ({})
paladin_1__link_rank_12 = class ({})
paladin_1__link_rank_21 = class ({})
paladin_1__link_rank_22 = class ({})
paladin_1__link_rank_31 = class ({})
paladin_1__link_rank_32 = class ({})
paladin_1__link_rank_41 = class ({})
paladin_1__link_rank_42 = class ({})

paladin_2__shield_rank_11 = class ({})
paladin_2__shield_rank_12 = class ({})
paladin_2__shield_rank_21 = class ({})
paladin_2__shield_rank_22 = class ({})
paladin_2__shield_rank_31 = class ({})
paladin_2__shield_rank_32 = class ({})
paladin_2__shield_rank_41 = class ({})
paladin_2__shield_rank_42 = class ({})

paladin_3__hammer_rank_11 = class ({})
paladin_3__hammer_rank_12 = class ({})
paladin_3__hammer_rank_21 = class ({})
paladin_3__hammer_rank_22 = class ({})
paladin_3__hammer_rank_31 = class ({})
paladin_3__hammer_rank_32 = class ({})
paladin_3__hammer_rank_41 = class ({})
paladin_3__hammer_rank_42 = class ({})

paladin_4__magnus_rank_11 = class ({})
paladin_4__magnus_rank_12 = class ({})
paladin_4__magnus_rank_21 = class ({})
paladin_4__magnus_rank_22 = class ({})
paladin_4__magnus_rank_31 = class ({})
paladin_4__magnus_rank_32 = class ({})
paladin_4__magnus_rank_41 = class ({})
paladin_4__magnus_rank_42 = class ({})

paladin_5__reborn_rank_11 = class ({})
paladin_5__reborn_rank_12 = class ({})
paladin_5__reborn_rank_21 = class ({})
paladin_5__reborn_rank_22 = class ({})
paladin_5__reborn_rank_31 = class ({})
paladin_5__reborn_rank_32 = class ({})
paladin_5__reborn_rank_41 = class ({})
paladin_5__reborn_rank_42 = class ({})

paladin_u__faith_rank_11 = class ({})
paladin_u__faith_rank_12 = class ({})
paladin_u__faith_rank_21 = class ({})
paladin_u__faith_rank_22 = class ({})
paladin_u__faith_rank_31 = class ({})
paladin_u__faith_rank_32 = class ({})
paladin_u__faith_rank_41 = class ({})
paladin_u__faith_rank_42 = class ({})

paladin__precache = class ({})
LinkLuaModifier("paladin_special_values", "heroes/sun/paladin/paladin-special_values", LUA_MODIFIER_MOTION_NONE)

function paladin__precache:GetIntrinsicModifierName()
  return "paladin_special_values"
end

function paladin__precache:Spawn()
	if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function paladin__precache:Precache(context)
end
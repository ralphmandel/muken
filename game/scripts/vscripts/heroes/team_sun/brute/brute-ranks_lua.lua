brute_1__spin_rank_11 = class ({})
brute_1__spin_rank_12 = class ({})
brute_1__spin_rank_21 = class ({})
brute_1__spin_rank_22 = class ({})
brute_1__spin_rank_31 = class ({})
brute_1__spin_rank_32 = class ({})
brute_1__spin_rank_41 = class ({})
brute_1__spin_rank_42 = class ({})

brute_2__rage_rank_11 = class ({})
brute_2__rage_rank_12 = class ({})
brute_2__rage_rank_21 = class ({})
brute_2__rage_rank_22 = class ({})
brute_2__rage_rank_31 = class ({})
brute_2__rage_rank_32 = class ({})
brute_2__rage_rank_41 = class ({})
brute_2__rage_rank_42 = class ({})

brute_3__xcution_rank_11 = class ({})
brute_3__xcution_rank_12 = class ({})
brute_3__xcution_rank_21 = class ({})
brute_3__xcution_rank_22 = class ({})
brute_3__xcution_rank_31 = class ({})
brute_3__xcution_rank_32 = class ({})
brute_3__xcution_rank_41 = class ({})
brute_3__xcution_rank_42 = class ({})

brute_4__sk4_rank_11 = class ({})
brute_4__sk4_rank_12 = class ({})
brute_4__sk4_rank_21 = class ({})
brute_4__sk4_rank_22 = class ({})
brute_4__sk4_rank_31 = class ({})
brute_4__sk4_rank_32 = class ({})
brute_4__sk4_rank_41 = class ({})
brute_4__sk4_rank_42 = class ({})

brute_5__sk5_rank_11 = class ({})
brute_5__sk5_rank_12 = class ({})
brute_5__sk5_rank_21 = class ({})
brute_5__sk5_rank_22 = class ({})
brute_5__sk5_rank_31 = class ({})
brute_5__sk5_rank_32 = class ({})
brute_5__sk5_rank_41 = class ({})
brute_5__sk5_rank_42 = class ({})

brute_u__mark_rank_11 = class ({})
brute_u__mark_rank_12 = class ({})
brute_u__mark_rank_21 = class ({})
brute_u__mark_rank_22 = class ({})
brute_u__mark_rank_31 = class ({})
brute_u__mark_rank_32 = class ({})
brute_u__mark_rank_41 = class ({})
brute_u__mark_rank_42 = class ({})

brute__precache = class ({})
LinkLuaModifier("brute_special_values", "heroes/team_sun/brute/brute-special_values", LUA_MODIFIER_MOTION_NONE)

function brute__precache:GetIntrinsicModifierName()
  return "brute_special_values"
end

function brute__precache:Spawn()
	if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function brute__precache:Precache(context)
end
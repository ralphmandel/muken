hunter_1__shot_rank_11 = class ({})
hunter_1__shot_rank_12 = class ({})
hunter_1__shot_rank_21 = class ({})
hunter_1__shot_rank_22 = class ({})
hunter_1__shot_rank_31 = class ({})
hunter_1__shot_rank_32 = class ({})
hunter_1__shot_rank_41 = class ({})
hunter_1__shot_rank_42 = class ({})

hunter_2__camouflage_rank_11 = class ({})
hunter_2__camouflage_rank_12 = class ({})
hunter_2__camouflage_rank_21 = class ({})
hunter_2__camouflage_rank_22 = class ({})
hunter_2__camouflage_rank_31 = class ({})
hunter_2__camouflage_rank_32 = class ({})
hunter_2__camouflage_rank_41 = class ({})
hunter_2__camouflage_rank_42 = class ({})

hunter_3__radar_rank_11 = class ({})
hunter_3__radar_rank_12 = class ({})
hunter_3__radar_rank_21 = class ({})
hunter_3__radar_rank_22 = class ({})
hunter_3__radar_rank_31 = class ({})
hunter_3__radar_rank_32 = class ({})
hunter_3__radar_rank_41 = class ({})
hunter_3__radar_rank_42 = class ({})

hunter_4__bandage_rank_11 = class ({})
hunter_4__bandage_rank_12 = class ({})
hunter_4__bandage_rank_21 = class ({})
hunter_4__bandage_rank_22 = class ({})
hunter_4__bandage_rank_31 = class ({})
hunter_4__bandage_rank_32 = class ({})
hunter_4__bandage_rank_41 = class ({})
hunter_4__bandage_rank_42 = class ({})

hunter_5__trap_rank_11 = class ({})
hunter_5__trap_rank_12 = class ({})
hunter_5__trap_rank_21 = class ({})
hunter_5__trap_rank_22 = class ({})
hunter_5__trap_rank_31 = class ({})
hunter_5__trap_rank_32 = class ({})
hunter_5__trap_rank_41 = class ({})
hunter_5__trap_rank_42 = class ({})

hunter_u__aim_rank_11 = class ({})
hunter_u__aim_rank_12 = class ({})
hunter_u__aim_rank_21 = class ({})
hunter_u__aim_rank_22 = class ({})
hunter_u__aim_rank_31 = class ({})
hunter_u__aim_rank_32 = class ({})
hunter_u__aim_rank_41 = class ({})
hunter_u__aim_rank_42 = class ({})

hunter__precache = class ({})
LinkLuaModifier("hunter_special_values", "heroes/nature/hunter/hunter-special_values", LUA_MODIFIER_MOTION_NONE)

function hunter__precache:GetIntrinsicModifierName()
  return "hunter_special_values"
end

function hunter__precache:Spawn()
	if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function hunter__precache:Precache(context)
end
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
  PrecacheResource("model", "models/items/sniper/machine_gun_charlie/machine_gun_charlie.vmdl", context)
  PrecacheResource("model", "models/items/sniper/spring2021_ambush_sniper_arms/spring2021_ambush_sniper_arms.vmdl", context)
  PrecacheResource("model", "models/items/sniper/spring2021_ambush_sniper_cape/spring2021_ambush_sniper_cape.vmdl", context)
  PrecacheResource("model", "models/items/sniper/spring2021_ambush_sniper_nest_cap/spring2021_ambush_sniper_nest_cap.vmdl", context)
  PrecacheResource("model", "models/items/sniper/spring2021_ambush_sniper_shoulders/spring2021_ambush_sniper_shoulders.vmdl", context)

  PrecacheResource("particle", "particles/econ/items/sniper/sniper_charlie/sniper_assassinate_charlie.vpcf", context)
  PrecacheResource("particle", "particles/econ/items/juggernaut/jugg_arcana/juggernaut_arcana_counter.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_hoodwink/hoodwink_scurry_passive.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_mars/mars_arena_of_blood_heal.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_skywrath_mage/skywrath_mage_ancient_seal_debuff_rune.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_bounty_hunter/bounty_hunter_lookout.vpcf", context)
end
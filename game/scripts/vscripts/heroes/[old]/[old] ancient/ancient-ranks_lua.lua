ancient_1__power_rank_11 = class ({})
ancient_1__power_rank_12 = class ({})
ancient_1__power_rank_21 = class ({})
ancient_1__power_rank_22 = class ({})
ancient_1__power_rank_31 = class ({})
ancient_1__power_rank_32 = class ({})
ancient_1__power_rank_41 = class ({})
ancient_1__power_rank_42 = class ({})

ancient_2__leap_rank_11 = class ({})
ancient_2__leap_rank_12 = class ({})
ancient_2__leap_rank_21 = class ({})
ancient_2__leap_rank_22 = class ({})
ancient_2__leap_rank_31 = class ({})
ancient_2__leap_rank_32 = class ({})
ancient_2__leap_rank_41 = class ({})
ancient_2__leap_rank_42 = class ({})

ancient_3__walk_rank_11 = class ({})
ancient_3__walk_rank_12 = class ({})
ancient_3__walk_rank_21 = class ({})
ancient_3__walk_rank_22 = class ({})
ancient_3__walk_rank_31 = class ({})
ancient_3__walk_rank_32 = class ({})
ancient_3__walk_rank_41 = class ({})
ancient_3__walk_rank_42 = class ({})

ancient_4__flesh_rank_11 = class ({})
ancient_4__flesh_rank_12 = class ({})
ancient_4__flesh_rank_21 = class ({})
ancient_4__flesh_rank_22 = class ({})
ancient_4__flesh_rank_31 = class ({})
ancient_4__flesh_rank_32 = class ({})
ancient_4__flesh_rank_41 = class ({})
ancient_4__flesh_rank_42 = class ({})

ancient_5__petrify_rank_11 = class ({})
ancient_5__petrify_rank_12 = class ({})
ancient_5__petrify_rank_21 = class ({})
ancient_5__petrify_rank_22 = class ({})
ancient_5__petrify_rank_31 = class ({})
ancient_5__petrify_rank_32 = class ({})
ancient_5__petrify_rank_41 = class ({})
ancient_5__petrify_rank_42 = class ({})

ancient_u__final_rank_11 = class ({})
ancient_u__final_rank_12 = class ({})
ancient_u__final_rank_21 = class ({})
ancient_u__final_rank_22 = class ({})
ancient_u__final_rank_31 = class ({})
ancient_u__final_rank_32 = class ({})
ancient_u__final_rank_41 = class ({})
ancient_u__final_rank_42 = class ({})

ancient__precache = class ({})
LinkLuaModifier("ancient_special_values", "heroes/sun/ancient/ancient-special_values", LUA_MODIFIER_MOTION_NONE)

function ancient__precache:GetIntrinsicModifierName()
  return "ancient_special_values"
end

function ancient__precache:Spawn()
	if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function ancient__precache:Precache(context)
  PrecacheResource("model", "models/items/elder_titan/harness_of_the_soulforged_arms/harness_of_the_soulforged_arms.vmdl", context)
  PrecacheResource("model", "models/items/elder_titan/ti9_cache_et_monuments_head/ti9_cache_et_monuments_head.vmdl", context)
  PrecacheResource("model", "models/items/elder_titan/harness_of_the_soulforged_shoulder/harness_of_the_soulforged_shoulder.vmdl", context)
  PrecacheResource("model", "models/items/elder_titan/harness_of_the_soulforged_weapon/harness_of_the_soulforged_weapon.vmdl", context)
  PrecacheResource("model", "models/items/elder_titan/elder_titan_immortal_back/elder_titan_immortal_back.vmdl", context)

  PrecacheResource("particle", "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_screen.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_tiny/tiny_toss_blur.vpcf", context)
  PrecacheResource("particle", "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_v2.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_chen/chen_penitence_debuff.vpcf", context)
  PrecacheResource("particle", "particles/ancient/ancient_aura_hands.vpcf", context)
  PrecacheResource("particle", "particles/econ/items/pugna/pugna_ward_golden_nether_lord/pugna_gold_ambient.vpcf", context)
  PrecacheResource("particle", "particles/ancient/ancient_aura_pulses.vpcf", context)
  PrecacheResource("particle", "particles/ancient/flesh/ancient_flesh_lvl2.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_chen/chen_holy_persuasion.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_chen/chen_penitence.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_magnataur/magnataur_shockwave_cast.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_elder_titan/elder_titan_earth_splitter.vpcf", context)
  PrecacheResource("particle", "particles/ancient/ancient_aura_alt.vpcf", context)
  PrecacheResource("particle", "particles/ancient/ancient_back.vpcf", context)
  PrecacheResource("particle", "particles/ancient/ancient_weapon.vpcf", context)
end

ancient__jump = class ({})

function ancient__jump:Spawn()
	if self:IsTrained() == false then self:UpgradeAbility(true) end
end
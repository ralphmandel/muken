druid_1__root_rank_11 = class ({})
druid_1__root_rank_12 = class ({})
druid_1__root_rank_21 = class ({})
druid_1__root_rank_22 = class ({})
druid_1__root_rank_31 = class ({})
druid_1__root_rank_32 = class ({})
druid_1__root_rank_41 = class ({})
druid_1__root_rank_42 = class ({})

druid_2__armor_rank_11 = class ({})
druid_2__armor_rank_12 = class ({})
druid_2__armor_rank_21 = class ({})
druid_2__armor_rank_22 = class ({})
druid_2__armor_rank_31 = class ({})
druid_2__armor_rank_32 = class ({})
druid_2__armor_rank_41 = class ({})
druid_2__armor_rank_42 = class ({})

druid_3__totem_rank_11 = class ({})
druid_3__totem_rank_12 = class ({})
druid_3__totem_rank_21 = class ({})
druid_3__totem_rank_22 = class ({})
druid_3__totem_rank_31 = class ({})
druid_3__totem_rank_32 = class ({})
druid_3__totem_rank_41 = class ({})
druid_3__totem_rank_42 = class ({})

druid_4__form_rank_11 = class ({})
druid_4__form_rank_12 = class ({})
druid_4__form_rank_21 = class ({})
druid_4__form_rank_22 = class ({})
druid_4__form_rank_31 = class ({})
druid_4__form_rank_32 = class ({})
druid_4__form_rank_41 = class ({})
druid_4__form_rank_42 = class ({})

druid_5__seed_rank_11 = class ({})
druid_5__seed_rank_12 = class ({})
druid_5__seed_rank_21 = class ({})
druid_5__seed_rank_22 = class ({})
druid_5__seed_rank_31 = class ({})
druid_5__seed_rank_32 = class ({})
druid_5__seed_rank_41 = class ({})
druid_5__seed_rank_42 = class ({})

druid_u__conversion_rank_11 = class ({})
druid_u__conversion_rank_12 = class ({})
druid_u__conversion_rank_21 = class ({})
druid_u__conversion_rank_22 = class ({})
druid_u__conversion_rank_31 = class ({})
druid_u__conversion_rank_32 = class ({})
druid_u__conversion_rank_41 = class ({})
druid_u__conversion_rank_42 = class ({})

druid__precache = class ({})
LinkLuaModifier("druid_special_values", "heroes/nature/druid/druid-special_values", LUA_MODIFIER_MOTION_NONE)

function druid__precache:GetIntrinsicModifierName()
  return "druid_special_values"
end

function druid__precache:Spawn()
  if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function druid__precache:Precache(context)
	PrecacheResource("particle", "particles/druid/druid_skill2_overgrowth.vpcf", context)
	PrecacheResource("particle", "particles/econ/items/treant_protector/treant_ti10_immortal_head/treant_ti10_immortal_overgrowth_cast.vpcf", context)
	PrecacheResource("particle", "particles/druid/druid_bush.vpcf", context)
	PrecacheResource("particle", "particles/druid/druid_skill2_ground_root.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_treant/treant_livingarmor.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf", context)
	PrecacheResource("particle", "particles/econ/items/juggernaut/bladekeeper_healing_ward/juggernaut_healing_ward_eruption_dc.vpcf", context)
	PrecacheResource("particle", "particles/econ/items/juggernaut/jugg_fall20_immortal/jugg_fall20_immortal_healing_ward.vpcf", context)
	PrecacheResource("particle", "particles/econ/items/phoenix/eye_of_the_sun/phoenix_supernova_egg_eye_sun_loadout.vpcf", context)
	PrecacheResource("particle", "particles/druid/druid_lotus/lotus_quill.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_bristleback/bristleback_quill_spray_impact.vpcf", context)
	PrecacheResource("particle", "particles/druid/flame_flower/druid_flame_flower_wave.vpcf", context)
	PrecacheResource("particle", "particles/status_fx/status_effect_lone_druid_savage_roar.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_lone_druid/lone_druid_savage_roar_debuff.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf", context)
	PrecacheResource("particle", "particles/osiris/poison_alt/osiris_poison_splash_shake.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_lone_druid/lone_druid_savage_roar.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_lycan/lycan_shapeshift_revert.vpcf", context)
	PrecacheResource("particle", "particles/druid/druid_ult_projectile.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_treant/treant_leech_seed_damage_pulse.vpcf", context)
	PrecacheResource("particle", "particles/neutral_fx/neutral_item_drop_lvl1.vpcf", context)
	PrecacheResource("particle", "particles/druid/druid_ult_passive.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_lycan/lycan_howl_buff.vpcf", context)
	PrecacheResource("particle", "particles/units/heroes/hero_enchantress/enchantress_enchant_slow.vpcf", context)
	PrecacheResource("particle", "particles/druid/druid_skill1_channeling.vpcf", context)
	PrecacheResource("particle", "particles/druid/druid_skill1_convert.vpcf", context)

	PrecacheResource("model", "models/items/furion/supreme_gardener_neck/supreme_gardener_neck.vmdl", context)
	PrecacheResource("model", "models/items/furion/fluttering_staff/fluttering_staff.vmdl", context)
	PrecacheResource("model", "models/items/furion/defender_of_the_jungle_arms/defender_of_the_jungle_arms.vmdl", context)
	PrecacheResource("model", "models/items/furion/primeval_back/primeval_back.vmdl", context)
	PrecacheResource("model", "models/items/furion/primeval_head/primeval_head.vmdl", context)
	PrecacheResource("model", "models/items/furion/the_ancient_guardian_shoulder/the_ancient_guardian_shoulder.vmdl", context)
	PrecacheResource("particle", "particles/econ/items/natures_prophet/natures_prophet_weapon_fluttering/natures_prophet_fluttering_ambient.vpc", context)
	PrecacheResource("particle", "particles/econ/items/natures_prophet/natures_prophet_shoulder_ancient_guardian/natures_prophet_ancient_guardian_ambient.vpcf", context)
end
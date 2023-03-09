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

druid_4__metamorphosis_rank_11 = class ({})
druid_4__metamorphosis_rank_12 = class ({})
druid_4__metamorphosis_rank_21 = class ({})
druid_4__metamorphosis_rank_22 = class ({})
druid_4__metamorphosis_rank_31 = class ({})
druid_4__metamorphosis_rank_32 = class ({})
druid_4__metamorphosis_rank_41 = class ({})
druid_4__metamorphosis_rank_42 = class ({})

druid_5__entangled_rank_11 = class ({})
druid_5__entangled_rank_12 = class ({})
druid_5__entangled_rank_21 = class ({})
druid_5__entangled_rank_22 = class ({})
druid_5__entangled_rank_31 = class ({})
druid_5__entangled_rank_32 = class ({})
druid_5__entangled_rank_41 = class ({})
druid_5__entangled_rank_42 = class ({})

druid_u__conversion_rank_11 = class ({})
druid_u__conversion_rank_12 = class ({})
druid_u__conversion_rank_21 = class ({})
druid_u__conversion_rank_22 = class ({})
druid_u__conversion_rank_31 = class ({})
druid_u__conversion_rank_32 = class ({})
druid_u__conversion_rank_41 = class ({})
druid_u__conversion_rank_42 = class ({})

druid__precache = class ({})

function druid__precache:Spawn()
    if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function druid__precache:Precache(context)
    PrecacheResource("soundfile", "soundevents/soundevent_druid.vsndevts", context)

    PrecacheResource("particle", "particles/druid/druid_skill2_overgrowth.vpcf", context)
    PrecacheResource("particle", "particles/druid/druid_bush.vpcf", context)
    PrecacheResource("particle", "particles/druid/druid_skill2_ground_root.vpcf", context)
    PrecacheResource("particle", "particles/druid/druid_ult_projectile.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_treant/treant_livingarmor.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_bristleback/bristleback_quill_spray_hit_creep.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/juggernaut/jugg_fortunes_tout/jugg_healling_ward_fortunes_tout_hero_heal.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/juggernaut/bladekeeper_healing_ward/juggernaut_healing_ward_eruption_dc.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/juggernaut/jugg_fall20_immortal/jugg_fall20_immortal_healing_ward.vpcf", context)
    PrecacheResource("particle", "particles/druid/druid_lotus/lotus_quill.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_bristleback/bristleback_quill_spray_impact.vpcf", context)
    PrecacheResource("particle", "particles/druid/druid_ult_projectile.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/treant_protector/treant_ti10_immortal_head/treant_ti10_immortal_overgrowth_cast.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/lone_druid/lone_druid_cauldron_retro/lone_druid_bear_entangle_retro_cauldron.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_treant/treant_leech_seed_damage_pulse.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_enchantress/enchantress_enchant_slow.vpcf", context)
    PrecacheResource("particle", "particles/druid/druid_skill1_channeling.vpcf", context)
    PrecacheResource("particle", "particles/druid/druid_skill1_convert.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_lycan/lycan_howl_buff.vpcf", context)
    PrecacheResource("particle", "particles/status_fx/status_effect_lone_druid_savage_roar.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_lone_druid/lone_druid_savage_roar_debuff.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_lycan/lycan_shapeshift_cast.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_lone_druid/lone_druid_savage_roar.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_lycan/lycan_shapeshift_revert.vpcf", context)
    PrecacheResource("particle", "particles/druid/druid_ult_passive.vpcf", context)

    PrecacheResource("model", "models/items/furion/supreme_gardener_neck/supreme_gardener_neck.vmdl", context)
    PrecacheResource("model", "models/items/furion/fluttering_staff/fluttering_staff.vmdl", context)
    PrecacheResource("model", "models/items/furion/defender_of_the_jungle_arms/defender_of_the_jungle_arms.vmdl", context)
    PrecacheResource("model", "models/items/furion/primeval_back/primeval_back.vmdl", context)
    PrecacheResource("model", "models/items/furion/primeval_head/primeval_head.vmdl", context)
    PrecacheResource("model", "models/items/furion/the_ancient_guardian_shoulder/the_ancient_guardian_shoulder.vmdl", context)
    PrecacheResource("particle", "particles/econ/items/natures_prophet/natures_prophet_weapon_fluttering/natures_prophet_fluttering_ambient.vpc", context)
    PrecacheResource("particle", "particles/econ/items/natures_prophet/natures_prophet_shoulder_ancient_guardian/natures_prophet_ancient_guardian_ambient.vpcf", context)
end
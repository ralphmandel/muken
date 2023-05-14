ancient_1__berserk_rank_11 = class ({})
ancient_1__berserk_rank_12 = class ({})
ancient_1__berserk_rank_21 = class ({})
ancient_1__berserk_rank_22 = class ({})
ancient_1__berserk_rank_31 = class ({})
ancient_1__berserk_rank_32 = class ({})
ancient_1__berserk_rank_41 = class ({})
ancient_1__berserk_rank_42 = class ({})

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

ancient_4__lotus_rank_11 = class ({})
ancient_4__lotus_rank_12 = class ({})
ancient_4__lotus_rank_21 = class ({})
ancient_4__lotus_rank_22 = class ({})
ancient_4__lotus_rank_31 = class ({})
ancient_4__lotus_rank_32 = class ({})
ancient_4__lotus_rank_41 = class ({})
ancient_4__lotus_rank_42 = class ({})

ancient_5__heal_rank_11 = class ({})
ancient_5__heal_rank_12 = class ({})
ancient_5__heal_rank_21 = class ({})
ancient_5__heal_rank_22 = class ({})
ancient_5__heal_rank_31 = class ({})
ancient_5__heal_rank_32 = class ({})
ancient_5__heal_rank_41 = class ({})
ancient_5__heal_rank_42 = class ({})

ancient_u__final_rank_11 = class ({})
ancient_u__final_rank_12 = class ({})
ancient_u__final_rank_21 = class ({})
ancient_u__final_rank_22 = class ({})
ancient_u__final_rank_31 = class ({})
ancient_u__final_rank_32 = class ({})
ancient_u__final_rank_41 = class ({})
ancient_u__final_rank_42 = class ({})

ancient__precache = class ({})

function ancient__precache:Spawn()
    if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function ancient__precache:Precache(context)
    PrecacheResource("soundfile", "soundevents/soundevent_ancient.vsndevts", context)
    PrecacheResource("model", "models/items/elder_titan/harness_of_the_soulforged_arms/harness_of_the_soulforged_arms.vmdl", context)
    PrecacheResource("model", "models/items/elder_titan/ti9_cache_et_monuments_head/ti9_cache_et_monuments_head.vmdl", context)
    PrecacheResource("model", "models/items/elder_titan/harness_of_the_soulforged_shoulder/harness_of_the_soulforged_shoulder.vmdl", context)
    PrecacheResource("model", "models/items/elder_titan/harness_of_the_soulforged_weapon/harness_of_the_soulforged_weapon.vmdl", context)
    PrecacheResource("model", "models/items/elder_titan/elder_titan_immortal_back/elder_titan_immortal_back.vmdl", context)

    PrecacheResource("particle", "particles/ancient/ancient_weapon.vpcf", context)
    PrecacheResource("particle", "particles/ancient/ancient_back.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_screen.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_v2.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_tiny/tiny_toss_blur.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_ally.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_chen/chen_penitence_debuff.vpcf", context)
    PrecacheResource("particle", "particles/ancient/ancient_aura_hands.vpcf", context)
    PrecacheResource("particle", "particles/status_fx/status_effect_statue.vpcf", context)
    PrecacheResource("particle", "particles/items_fx/aura_endurance.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/pugna/pugna_ward_golden_nether_lord/pugna_gold_ambient.vpcf", context)
    PrecacheResource("particle", "particles/ancient/ancient_aura_pulses.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_omniknight/omniknight_shard_hammer_of_purity_heal.vpcf", context)
    PrecacheResource("particle", "particles/ancient/flesh/ancient_flesh_lvl2.vpcf", context)
    PrecacheResource("particle", "particles/econ/events/fall_2022/radiance_target_fall2022.vpcf", context)
    PrecacheResource("particle", "particles/econ/events/fall_2022/radiance/radiance_owner_fall2022.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_chen/chen_holy_persuasion.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_chen/chen_divine_favor_buff.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_chen/chen_penitence.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_magnataur/magnataur_shockwave_cast.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_elder_titan/elder_titan_earth_splitter.vpcf", context)
    PrecacheResource("particle", "particles/ancient/ancient_aura_alt.vpcf", context)
end
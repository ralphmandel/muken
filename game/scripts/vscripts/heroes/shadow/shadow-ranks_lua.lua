shadow_0__toxin_rank_11 = class ({})
shadow_0__toxin_rank_12 = class ({})
shadow_0__toxin_rank_13 = class ({})
shadow_0__toxin_rank_21 = class ({})
shadow_0__toxin_rank_22 = class ({})
shadow_0__toxin_rank_23 = class ({})
shadow_0__toxin_rank_31 = class ({})
shadow_0__toxin_rank_32 = class ({})
shadow_0__toxin_rank_33 = class ({})
shadow_0__toxin_rank_41 = class ({})
shadow_0__toxin_rank_42 = class ({})

shadow_1__strike_rank_11 = class ({})
shadow_1__strike_rank_12 = class ({})
shadow_1__strike_rank_13 = class ({})
shadow_1__strike_rank_21 = class ({})
shadow_1__strike_rank_22 = class ({})
shadow_1__strike_rank_23 = class ({})
shadow_1__strike_rank_31 = class ({})
shadow_1__strike_rank_32 = class ({})
shadow_1__strike_rank_33 = class ({})
shadow_1__strike_rank_41 = class ({})
shadow_1__strike_rank_42 = class ({})

shadow_2__puddle_rank_11 = class ({})
shadow_2__puddle_rank_12 = class ({})
shadow_2__puddle_rank_13 = class ({})
shadow_2__puddle_rank_21 = class ({})
shadow_2__puddle_rank_22 = class ({})
shadow_2__puddle_rank_23 = class ({})
shadow_2__puddle_rank_31 = class ({})
shadow_2__puddle_rank_32 = class ({})
shadow_2__puddle_rank_33 = class ({})
shadow_2__puddle_rank_41 = class ({})
shadow_2__puddle_rank_42 = class ({})

shadow_3__walk_rank_11 = class ({})
shadow_3__walk_rank_12 = class ({})
shadow_3__walk_rank_13 = class ({})
shadow_3__walk_rank_21 = class ({})
shadow_3__walk_rank_22 = class ({})
shadow_3__walk_rank_23 = class ({})
shadow_3__walk_rank_31 = class ({})
shadow_3__walk_rank_32 = class ({})
shadow_3__walk_rank_33 = class ({})
shadow_3__walk_rank_41 = class ({})
shadow_3__walk_rank_42 = class ({})

shadow_u__dagger_rank_11 = class ({})
shadow_u__dagger_rank_12 = class ({})
shadow_u__dagger_rank_13 = class ({})
shadow_u__dagger_rank_21 = class ({})
shadow_u__dagger_rank_22 = class ({})
shadow_u__dagger_rank_23 = class ({})
shadow_u__dagger_rank_31 = class ({})
shadow_u__dagger_rank_32 = class ({})
shadow_u__dagger_rank_33 = class ({})
shadow_u__dagger_rank_41 = class ({})
shadow_u__dagger_rank_42 = class ({})

shadow__precache = class ({})

function shadow__precache:Spawn()
    if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function shadow__precache:Precache(context)
    PrecacheResource("soundfile", "soundevents/soundevent_shadowmancer.vsndevts", context)
    PrecacheResource("particle", "particles/status_fx/status_effect_maledict.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_witchdoctor/witchdoctor_shard_switcheroo_cast.vpcf", context)
    PrecacheResource("particle", "particles/econ/events/ti9/blink_dagger_ti9_start_lvl2_splash.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", context)
    PrecacheResource("particle", "particles/bioshadow/bioshadow_heart.vpcf", context)
    PrecacheResource("particle", "particles/items3_fx/octarine_core_lifesteal.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_void_spirit/dissimilate/void_spirit_dissimilate_dmg.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_dark_seer/dark_seer_vacuum.vpcf", context)
    PrecacheResource("particle", "particles/shadowmancer/blur/shadowmancer_blur_ambient.vpcf", context)
    PrecacheResource("particle", "particles/shadowmancer/blur/shadowmancer_blur_start.vpcf", context)
    PrecacheResource("particle", "particles/shadowmancer/dagger/shadowmancer_stifling_dagger_arcana_combined.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/void_spirit/void_spirit_immortal_2021/void_spirit_immortal_2021_astral_step_dmg.vpcf", context)
    PrecacheResource("particle", "particles/econ/events/ti9/blink_dagger_ti9_start_lvl2.vpcf", context)
    PrecacheResource("particle", "particles/econ/events/ti9/blink_dagger_ti9_lvl2_end.vpcf", context)
    PrecacheResource("particle", "particles/econ/items/phantom_assassin/phantom_assassin_weapon_hells_usher/phantom_assassin_hells_usher_ambient.vpcf", context)
    PrecacheResource("particle", "particles/shadowmancer/shadowmancer_arcana_ambient.vpcf", context)

    PrecacheResource("model", "models/items/phantom_assassin/creeping_shadow_back/creeping_shadow_back.vmdl", context)
    PrecacheResource("model", "models/items/phantom_assassin/creeping_shadow_belt/creeping_shadow_belt.vmdl", context)
    PrecacheResource("model", "models/items/phantom_assassin/creeping_shadow_head/creeping_shadow_head.vmdl", context)
    PrecacheResource("model", "models/items/phantom_assassin/creeping_shadow_shoulder/creeping_shadow_shoulder.vmdl", context)
    PrecacheResource("model", "models/items/phantom_assassin/hells_guide/hells_guide.vmdl", context)
end
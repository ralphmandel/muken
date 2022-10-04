bloodstained_1__rage_rank_11 = class ({})
bloodstained_1__rage_rank_12 = class ({})
bloodstained_1__rage_rank_21 = class ({})
bloodstained_1__rage_rank_22 = class ({})
bloodstained_1__rage_rank_31 = class ({})
bloodstained_1__rage_rank_32 = class ({})
bloodstained_1__rage_rank_41 = class ({})
bloodstained_1__rage_rank_42 = class ({})

bloodstained_2__lifesteal_rank_11 = class ({})
bloodstained_2__lifesteal_rank_12 = class ({})
bloodstained_2__lifesteal_rank_21 = class ({})
bloodstained_2__lifesteal_rank_22 = class ({})
bloodstained_2__lifesteal_rank_31 = class ({})
bloodstained_2__lifesteal_rank_32 = class ({})
bloodstained_2__lifesteal_rank_41 = class ({})
bloodstained_2__lifesteal_rank_42 = class ({})

bloodstained_3__curse_rank_11 = class ({})
bloodstained_3__curse_rank_12 = class ({})
bloodstained_3__curse_rank_21 = class ({})
bloodstained_3__curse_rank_22 = class ({})
bloodstained_3__curse_rank_31 = class ({})
bloodstained_3__curse_rank_32 = class ({})
bloodstained_3__curse_rank_41 = class ({})
bloodstained_3__curse_rank_42 = class ({})

bloodstained_4__frenzy_rank_11 = class ({})
bloodstained_4__frenzy_rank_12 = class ({})
bloodstained_4__frenzy_rank_21 = class ({})
bloodstained_4__frenzy_rank_22 = class ({})
bloodstained_4__frenzy_rank_31 = class ({})
bloodstained_4__frenzy_rank_32 = class ({})
bloodstained_4__frenzy_rank_41 = class ({})
bloodstained_4__frenzy_rank_42 = class ({})

bloodstained_5__tear_rank_11 = class ({})
bloodstained_5__tear_rank_12 = class ({})
bloodstained_5__tear_rank_21 = class ({})
bloodstained_5__tear_rank_22 = class ({})
bloodstained_5__tear_rank_31 = class ({})
bloodstained_5__tear_rank_32 = class ({})
bloodstained_5__tear_rank_41 = class ({})
bloodstained_5__tear_rank_42 = class ({})

bloodstained_u__seal_rank_11 = class ({})
bloodstained_u__seal_rank_12 = class ({})
bloodstained_u__seal_rank_21 = class ({})
bloodstained_u__seal_rank_22 = class ({})
bloodstained_u__seal_rank_31 = class ({})
bloodstained_u__seal_rank_32 = class ({})
bloodstained_u__seal_rank_41 = class ({})
bloodstained_u__seal_rank_42 = class ({})

bloodstained__precache = class ({})

function bloodstained__precache:Spawn()
    if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function bloodstained__precache:Precache(context)
    PrecacheResource("soundfile", "soundevents/soundevent_bloodstained.vsndevts", context)
    PrecacheResource( "model", "models/items/shadow_demon/mantle_of_the_shadow_demon_belt/mantle_of_the_shadow_demon_belt.vmdl", context )
    PrecacheResource( "model", "models/items/shadow_demon/sd_crown_of_the_nightworld_tail/sd_crown_of_the_nightworld_tail.vmdl", context )
    PrecacheResource( "model", "models/items/shadow_demon/ti7_immortal_back/sd_ti7_immortal_back.vmdl", context )
    PrecacheResource( "model", "models/items/shadow_demon/sd_crown_of_the_nightworld_armor/sd_crown_of_the_nightworld_armor.vmdl", context )

    PrecacheResource( "particle", "particles/econ/items/shadow_demon/sd_ti7_shadow_poison/sd_ti7_immortal_ambient.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/shadow_demon/sd_crown_nightworld/sd_crown_nightworld_armor.vpcf", context )
    PrecacheResource( "particle", "particles/status_fx/status_effect_rupture.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf", context )
    PrecacheResource( "particle", "particles/status_fx/status_effect_rupture.vpcf", context )
    PrecacheResource( "particle", "particles/bocuse/bocuse_msg.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_impact.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/axe/axe_ti9_immortal/axe_ti9_call.vpcf", context )
    PrecacheResource( "particle", "particles/status_fx/status_effect_beserkers_call.vpcf", context )
    PrecacheResource( "particle", "particles/bloodstained/status_efx/status_effect_bloodstained.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/lifestealer/lifestealer_immortal_backbone/status_effect_life_stealer_immortal_rage.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_gods_strength_crit.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_debuff.vpcf", context )
    PrecacheResource( "particle", "particles/bioshadow/bioshadow_drain.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture_nuke.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath.vpcf", context )
    PrecacheResource( "particle", "particles/items3_fx/octarine_core_lifesteal.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_queenofpain/queen_shadow_strike_body.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/grimstroke/gs_fall20_immortal/gs_fall20_immortal_soulbind.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodrage.vpcf", context )
    PrecacheResource( "particle", "particles/bloodstained/frenzy/bloodstained_frenzy.vpcf", context )
    PrecacheResource( "particle", "particles/osiris/poison_alt/osiris_poison_splash_shake.vpcf", context )
    PrecacheResource( "particle", "particles/bloodstained/bloodstained_x2_blood.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_bloodseeker/bloodseeker_scepter_blood_mist_spray_initial.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_bloodseeker/bloodseeker_scepter_blood_mist_aoe.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_undying/undying_soul_rip_damage.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath.vpcf", context )
    PrecacheResource( "particle", "particles/osiris/poison_alt/osiris_poison_splash_shake.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", context )
    PrecacheResource( "particle", "particles/bloodstained/seal_finder_aoe.vpcf", context )
    PrecacheResource( "particle", "particles/bloodstained/bloodstained_thirst_owner_smoke_dark.vpcf", context )
    PrecacheResource( "particle", "particles/bloodstained/bloodstained_u_illusion_status.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf", context )
    PrecacheResource( "particle", "particles/bloodstained/bloodstained_u_track1.vpcf", context )
    PrecacheResource( "particle", "particles/bloodstained/bloodstained_u_bubbles.vpcf", context )
    PrecacheResource( "particle", "particles/bloodstained/bloodstained_field_replica.vpcf", context )
    PrecacheResource( "particle", "particles/bloodstained/bloodstained_seal_impact.vpcf", context )
    PrecacheResource( "particle", "particles/bloodstained/bloodstained_seal_war.vpcf", context )
    PrecacheResource( "particle", "particles/bloodstained/frenzy/bloodstained_hands_v2.vpcf", context )
end
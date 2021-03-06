bloodstained_1__rage_rank_11 = class ({})
bloodstained_1__rage_rank_12 = class ({})
bloodstained_1__rage_rank_13 = class ({})
bloodstained_1__rage_rank_21 = class ({})
bloodstained_1__rage_rank_22 = class ({})
bloodstained_1__rage_rank_23 = class ({})
bloodstained_1__rage_rank_31 = class ({})
bloodstained_1__rage_rank_32 = class ({})
bloodstained_1__rage_rank_33 = class ({})
bloodstained_1__rage_rank_41 = class ({})
bloodstained_1__rage_rank_42 = class ({})

bloodstained_2__bloodsteal_rank_11 = class ({})
bloodstained_2__bloodsteal_rank_12 = class ({})
bloodstained_2__bloodsteal_rank_13 = class ({})
bloodstained_2__bloodsteal_rank_21 = class ({})
bloodstained_2__bloodsteal_rank_22 = class ({})
bloodstained_2__bloodsteal_rank_23 = class ({})
bloodstained_2__bloodsteal_rank_31 = class ({})
bloodstained_2__bloodsteal_rank_32 = class ({})
bloodstained_2__bloodsteal_rank_33 = class ({})
bloodstained_2__bloodsteal_rank_41 = class ({})
bloodstained_2__bloodsteal_rank_42 = class ({})

bloodstained_3__curse_rank_11 = class ({})
bloodstained_3__curse_rank_12 = class ({})
bloodstained_3__curse_rank_13 = class ({})
bloodstained_3__curse_rank_21 = class ({})
bloodstained_3__curse_rank_22 = class ({})
bloodstained_3__curse_rank_23 = class ({})
bloodstained_3__curse_rank_31 = class ({})
bloodstained_3__curse_rank_32 = class ({})
bloodstained_3__curse_rank_33 = class ({})
bloodstained_3__curse_rank_41 = class ({})
bloodstained_3__curse_rank_42 = class ({})

bloodstained_u__seal_rank_11 = class ({})
bloodstained_u__seal_rank_12 = class ({})
bloodstained_u__seal_rank_13 = class ({})
bloodstained_u__seal_rank_21 = class ({})
bloodstained_u__seal_rank_22 = class ({})
bloodstained_u__seal_rank_23 = class ({})
bloodstained_u__seal_rank_31 = class ({})
bloodstained_u__seal_rank_32 = class ({})
bloodstained_u__seal_rank_33 = class ({})
bloodstained_u__seal_rank_41 = class ({})
bloodstained_u__seal_rank_42 = class ({})

bloodstained__precache = class ({})

function bloodstained__precache:Spawn()
    if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function bloodstained__precache:Precache(context)
    PrecacheResource( "particle", "particles/econ/items/bloodseeker/bloodseeker_ti7/bloodseeker_ti7_thirst_owner.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_impact.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_beastmaster/beastmaster_wildaxes_hit.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/axe/axe_ti9_immortal/axe_ti9_call.vpcf", context )
    PrecacheResource( "particle", "particles/status_fx/status_effect_beserkers_call.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_gods_strength_crit.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_debuff.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/lifestealer/lifestealer_immortal_backbone/status_effect_life_stealer_immortal_rage.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/lifestealer/lifestealer_immortal_backbone_gold/lifestealer_immortal_backbone_gold_rage.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture_nuke.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_undying/undying_soul_rip_damage.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_trail.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_queenofpain/queen_shadow_strike_body.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/grimstroke/gs_fall20_immortal/gs_fall20_immortal_soulbind.vpcf", context )
    PrecacheResource( "particle", "particles/bloodstained/seal_finder_aoe.vpcf", context )
    PrecacheResource( "particle", "particles/bloodstained/bloodstained_u_illusion_status.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf", context )
    PrecacheResource( "particle", "particles/bloodstained/bloodstained_u_track1.vpcf", context )
    PrecacheResource( "particle", "particles/bloodstained/bloodstained_u_bubbles.vpcf", context )
    PrecacheResource( "particle", "particles/bloodstained/bloodstained_seal_war.vpcf", context )
    PrecacheResource( "particle", "particles/bloodstained/bloodstained_seal_impact.vpcf", context )
    PrecacheResource( "particle", "particles/bloodstained/bloodstained_field_replica.vpcf", context )
    PrecacheResource( "particle", "particles/bloodstained/bloodstained_thirst_owner_smoke_dark.vpcf", context )
    PrecacheResource( "particle", "particles/econ/events/ti6/blink_dagger_start_ti6.vpcf", context )
    PrecacheResource( "particle", "particles/econ/events/ti6/blink_dagger_end_ti6.vpcf", context )
    PrecacheResource( "particle", "particles/bloodstained/bloodstained_x2_blood.vpcf", context )

    PrecacheResource( "model", "models/items/shadow_demon/mantle_of_the_shadow_demon_belt/mantle_of_the_shadow_demon_belt.vmdl", context )
    PrecacheResource( "model", "models/items/shadow_demon/sd_crown_of_the_nightworld_tail/sd_crown_of_the_nightworld_tail.vmdl", context )
    PrecacheResource( "model", "models/items/shadow_demon/ti7_immortal_back/sd_ti7_immortal_back.vmdl", context )
    PrecacheResource( "model", "models/items/shadow_demon/sd_crown_of_the_nightworld_armor/sd_crown_of_the_nightworld_armor.vmdl", context )
    PrecacheResource( "particle", "particles/econ/items/shadow_demon/sd_ti7_shadow_poison/sd_ti7_immortal_ambient.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/shadow_demon/sd_crown_nightworld/sd_crown_nightworld_armor.vpcf", context )
end
bocuse_1__julienne_rank_11 = class ({})
bocuse_1__julienne_rank_12 = class ({})
bocuse_1__julienne_rank_13 = class ({})
bocuse_1__julienne_rank_21 = class ({})
bocuse_1__julienne_rank_22 = class ({})
bocuse_1__julienne_rank_23 = class ({})
bocuse_1__julienne_rank_31 = class ({})
bocuse_1__julienne_rank_32 = class ({})
bocuse_1__julienne_rank_33 = class ({})
bocuse_1__julienne_rank_41 = class ({})
bocuse_1__julienne_rank_42 = class ({})

bocuse_2__flambee_rank_11 = class ({})
bocuse_2__flambee_rank_12 = class ({})
bocuse_2__flambee_rank_13 = class ({})
bocuse_2__flambee_rank_21 = class ({})
bocuse_2__flambee_rank_22 = class ({})
bocuse_2__flambee_rank_23 = class ({})
bocuse_2__flambee_rank_31 = class ({})
bocuse_2__flambee_rank_32 = class ({})
bocuse_2__flambee_rank_33 = class ({})
bocuse_2__flambee_rank_41 = class ({})
bocuse_2__flambee_rank_42 = class ({})

bocuse_3__sauce_rank_11 = class ({})
bocuse_3__sauce_rank_12 = class ({})
bocuse_3__sauce_rank_13 = class ({})
bocuse_3__sauce_rank_21 = class ({})
bocuse_3__sauce_rank_22 = class ({})
bocuse_3__sauce_rank_23 = class ({})
bocuse_3__sauce_rank_31 = class ({})
bocuse_3__sauce_rank_32 = class ({})
bocuse_3__sauce_rank_33 = class ({})
bocuse_3__sauce_rank_41 = class ({})
bocuse_3__sauce_rank_42 = class ({})

bocuse_u__mise_rank_11 = class ({})
bocuse_u__mise_rank_12 = class ({})
bocuse_u__mise_rank_13 = class ({})
bocuse_u__mise_rank_21 = class ({})
bocuse_u__mise_rank_22 = class ({})
bocuse_u__mise_rank_23 = class ({})
bocuse_u__mise_rank_31 = class ({})
bocuse_u__mise_rank_32 = class ({})
bocuse_u__mise_rank_33 = class ({})
bocuse_u__mise_rank_41 = class ({})
bocuse_u__mise_rank_42 = class ({})

bocuse__precache = class ({})

function bocuse__precache:Spawn()
    if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function bocuse__precache:Precache(context)
    PrecacheResource( "particle", "particles/bocuse/bocuse_msg.vpcf", context )
    PrecacheResource( "particle", "particles/bocuse/bocuse_strike_blur.vpcf", context )
    PrecacheResource( "particle", "particles/bocuse/bocuse_strike_blur_2.vpcf", context )
    PrecacheResource( "particle", "particles/bocuse/bocuse_strike_blur_3.vpcf", context )
    PrecacheResource( "particle", "particles/bocuse/bocuse_strike_blur_extra_1.vpcf", context )
    PrecacheResource( "particle", "particles/bocuse/bocuse_strike_blur_extra_2.vpcf", context )
    PrecacheResource( "particle", "particles/bocuse/bocuse_strike_blur_extra_3.vpcf", context )
    PrecacheResource( "particle", "particles/bocuse/bocuse_strike_blur_extra_4.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_impact.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok.vpcf", context )
    PrecacheResource( "particle", "particles/items3_fx/star_emblem.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/bloodseeker/bloodseeker_ti7/bloodseeker_ti7_thirst_owner.vpcf", context )
    PrecacheResource( "particle", "particles/bocuse/bocuse_flambee.vpcf", context )
    PrecacheResource( "particle", "particles/bocuse/bocuse_flambee_impact.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/alchemist/alchemist_smooth_criminal/alchemist_smooth_criminal_unstable_concoction_explosion.vpcf", context )
    PrecacheResource( "particle", "particles/bocuse/bocuse_flambee_impact_fire_ring.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/lifestealer/ls_ti9_immortal/status_effect_ls_ti9_open_wounds.vpcf", context )
    PrecacheResource( "particle", "particles/bocuse/bocuse_drunk_ally_crit.vpcf", context )
    PrecacheResource( "particle", "particles/bocuse/bocuse_drunk_enemy.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodrage_ground_eztzhok.vpcf", context )
    PrecacheResource( "particle", "particles/bocuse/bocuse_3_counter.vpcf", context )
    PrecacheResource( "particle", "particles/bocuse/bocuse_3_double_counter.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/invoker/invoker_ti7/status_effect_alacrity_ti7.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/doom/doom_ti8_immortal_arms/doom_ti8_immortal_devour.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/pudge/pudge_immortal_arm/pudge_immortal_arm_rot.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/ogre_magi/ogre_ti8_immortal_weapon/ogre_ti8_immortal_bloodlust_buff.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_grimstroke/grimstroke_cast2_ground.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_mars/mars_shield_bash_crit.vpcf", context )
    PrecacheResource( "particle", "particles/bocuse/bocuse_roux_debuff.vpcf", context )
    PrecacheResource( "particle", "particles/bocuse/bocuse_roux_aoe_mass.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_sandking/sandking_epicenter.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/meepo/meepo_colossal_crystal_chorus/meepo_divining_rod_poof_start.vpcf", context )
    PrecacheResource( "particle", "particles/items_fx/black_king_bar_avatar.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/wisp/wisp_relocate_teleport_ti7_out.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_secondstyle_debuff.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/techies/techies_arcana/techies_suicide_kills_arcana.vpcf", context )
    PrecacheResource( "particle", "particles/status_fx/status_effect_slark_shadow_dance.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_techies/techies_blast_off.vpcf", context )

    PrecacheResource( "model", "models/items/pudge/pudge_lord_of_decay_weapon/pudge_lord_of_decay_weapon.vmdl", context )
    PrecacheResource( "model", "models/items/pudge/pudge_insanity_chooper/pudge_insanity_chooper.vmdl", context )
    PrecacheResource( "model", "models/items/pudge/pudge_frozen_pig_face_head/pudge_frozen_pig_face_head.vmdl", context )
    PrecacheResource( "model", "models/items/pudge/the_ol_choppers_shoulder/the_ol_choppers_shoulder.vmdl", context )
    PrecacheResource( "model", "models/items/pudge/delicacies_back/delicacies_back.vmdl", context )
    PrecacheResource( "model", "models/items/pudge/doomsday_ripper_belt/doomsday_ripper_belt.vmdl", context )
    PrecacheResource( "model", "models/items/pudge/delicacies_arms/delicacies_arms.vmdl", context )
end
bocuse_1__julienne_rank_11 = class ({})
bocuse_1__julienne_rank_12 = class ({})
bocuse_1__julienne_rank_21 = class ({})
bocuse_1__julienne_rank_22 = class ({})
bocuse_1__julienne_rank_31 = class ({})
bocuse_1__julienne_rank_32 = class ({})
bocuse_1__julienne_rank_41 = class ({})
bocuse_1__julienne_rank_42 = class ({})

bocuse_2__flambee_rank_11 = class ({})
bocuse_2__flambee_rank_12 = class ({})
bocuse_2__flambee_rank_21 = class ({})
bocuse_2__flambee_rank_22 = class ({})
bocuse_2__flambee_rank_31 = class ({})
bocuse_2__flambee_rank_32 = class ({})
bocuse_2__flambee_rank_41 = class ({})
bocuse_2__flambee_rank_42 = class ({})

bocuse_3__sauce_rank_11 = class ({})
bocuse_3__sauce_rank_12 = class ({})
bocuse_3__sauce_rank_21 = class ({})
bocuse_3__sauce_rank_22 = class ({})
bocuse_3__sauce_rank_31 = class ({})
bocuse_3__sauce_rank_32 = class ({})
bocuse_3__sauce_rank_41 = class ({})
bocuse_3__sauce_rank_42 = class ({})

bocuse_4__mirepoix_rank_11 = class ({})
bocuse_4__mirepoix_rank_12 = class ({})
bocuse_4__mirepoix_rank_21 = class ({})
bocuse_4__mirepoix_rank_22 = class ({})
bocuse_4__mirepoix_rank_31 = class ({})
bocuse_4__mirepoix_rank_32 = class ({})
bocuse_4__mirepoix_rank_41 = class ({})
bocuse_4__mirepoix_rank_42 = class ({})

bocuse_5__roux_rank_11 = class ({})
bocuse_5__roux_rank_12 = class ({})
bocuse_5__roux_rank_21 = class ({})
bocuse_5__roux_rank_22 = class ({})
bocuse_5__roux_rank_31 = class ({})
bocuse_5__roux_rank_32 = class ({})
bocuse_5__roux_rank_41 = class ({})
bocuse_5__roux_rank_42 = class ({})

bocuse_u__mise_rank_11 = class ({})
bocuse_u__mise_rank_12 = class ({})
bocuse_u__mise_rank_21 = class ({})
bocuse_u__mise_rank_22 = class ({})
bocuse_u__mise_rank_31 = class ({})
bocuse_u__mise_rank_32 = class ({})
bocuse_u__mise_rank_41 = class ({})
bocuse_u__mise_rank_42 = class ({})

bocuse__precache = class ({})
LinkLuaModifier("bocuse_special_values", "heroes/team_death/bocuse/bocuse-special_values", LUA_MODIFIER_MOTION_NONE)

function bocuse__precache:GetIntrinsicModifierName()
    return "bocuse_special_values"
end

function bocuse__precache:Spawn()
    if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function bocuse__precache:Precache(context)
    --PrecacheResource("soundfile", "soundevents/soundevent_bocuse.vsndevts", context)
    PrecacheResource( "model", "models/items/pudge/pudge_dapper_disguise_head/pudge_dapper_disguise_head.vmdl", context )
    PrecacheResource( "model", "models/items/pudge/nightmare_scarecrow_belt/nightmare_scarecrow_belt.vmdl", context )
    PrecacheResource( "model", "models/items/pudge/blackdeath_shoulder_s1/blackdeath_shoulder_s1.vmdl", context )
    PrecacheResource( "model", "models/items/pudge/ftp_dendi_arm/ftp_dendi_arm.vmdl", context )
    PrecacheResource( "model", "models/items/pudge/ftp_dendi_back/ftp_dendi_back.vmdl", context )
    PrecacheResource( "model", "models/items/pudge/pudge_dapper_disguise_weapon/pudge_dapper_disguise_weapon.vmdl", context )
    PrecacheResource( "model", "models/items/pudge/pudge_dapper_disguise_off_hand/pudge_dapper_disguise_off_hand.vmdl", context )

    PrecacheResource( "particle", "particles/econ/items/pudge/pudge_ftp_crow/pudge_ftp_back_crow.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/pudge/pudge_ti9_cache/pudge_ti9_cache_weapon_ambient.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/pudge/pudge_ti9_cache/pudge_ti9_cache_offhand_ambient.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/bloodseeker/bloodseeker_ti7/bloodseeker_ti7_thirst_owner.vpcf", context )
    PrecacheResource( "particle", "particles/bocuse/bocuse_msg.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_impact.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok.vpcf", context )
    PrecacheResource( "particle", "particles/bocuse/bocuse_strike_blur.vpcf", context )
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
    PrecacheResource( "particle", "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_secondstyle_debuff.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/wisp/wisp_relocate_teleport_ti7_out.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_secondstyle_debuff.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/wisp/wisp_relocate_teleport_ti7_out.vpcf", context )
    PrecacheResource( "particle", "particles/bocuse/bocuse_roux_debuff.vpcf", context )
    PrecacheResource( "particle", "particles/bocuse/bocuse_roux_aoe_mass.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_sandking/sandking_epicenter.vpcf", context )
    PrecacheResource( "particle", "particles/status_fx/status_effect_slark_shadow_dance.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/doom/doom_ti8_immortal_arms/doom_ti8_immortal_devour.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_techies/techies_blast_off.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/pudge/pudge_immortal_arm/pudge_immortal_arm_rot.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/invoker/invoker_ti7/status_effect_alacrity_ti7.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/ogre_magi/ogre_ti8_immortal_weapon/ogre_ti8_immortal_bloodlust_buff.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_grimstroke/grimstroke_cast2_ground.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_mars/mars_shield_bash_crit.vpcf", context )
    PrecacheResource( "particle", "particles/bocuse/sauce/bocuse_sauce_heal.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/techies/techies_arcana/techies_remote_mines_detonate_arcana.vpcf", context )
end
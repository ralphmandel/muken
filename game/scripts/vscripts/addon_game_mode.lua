if BattleArena == nil then
	BattleArena = class({})
end

require("game_setup")
require("talent_tree")

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]

	XP_PER_LEVEL_TABLE = {
		20, 40, 60, 80,
		100, 120, 140, 160,
		190, 220, 250, 280,
		310, 340, 370, 400,
		440, 480, 520, 560,
		600, 640, 680, 720
	}

	LinkLuaModifier("modifier_wearable", "components/modifiers/modifier_wearable.lua", LUA_MODIFIER_MOTION_NONE )

	--precache particle
		--general
			PrecacheResource( "model", "models/creeps/lane_creeps/creep_radiant_ranged/radiant_ranged_crystal.vmdl", context )
			PrecacheResource( "model", "models/creeps/ice_biome/frostbitten/n_creep_frostbitten_swollen01.vmdl", context )
			PrecacheResource( "model", "models/creeps/lane_creeps/ti9_crocodilian_dire/ti9_crocodilian_dire_ranged_mega.vmdl", context )
			PrecacheResource( "model", "models/creeps/neutral_creeps/n_creep_eimermole/n_creep_eimermole_lamp.vmdl", context )
			PrecacheResource( "model", "models/items/broodmother/spiderling/elder_blood_heir_of_elder_blood/elder_blood_heir_of_elder_blood.vmdl", context )
			PrecacheResource( "model", "models/items/broodmother/spiderling/dplus_malevolent_mother_malevoling/dplus_malevolent_mother_malevoling.vmdl", context )
			PrecacheResource( "model", "models/creeps/neutral_creeps/n_creep_dragonspawn_a/n_creep_dragonspawn_a.vmdl", context )
			PrecacheResource( "model", "models/creeps/neutral_creeps/n_creep_dragonspawn_b/n_creep_dragonspawn_b.vmdl", context )
			PrecacheResource( "model", "models/creeps/lane_creeps/ti9_chameleon_radiant/ti9_chameleon_radiant_melee_mega.vmdl", context )
			PrecacheResource( "model", "models/creeps/lane_creeps/ti9_chameleon_radiant/ti9_chameleon_radiant_melee.vmdl", context )
			PrecacheResource( "model", "models/creeps/lane_creeps/ti9_crocodilian_dire/ti9_crocodilian_dire_melee_mega.vmdl", context )
			PrecacheResource( "model", "models/creeps/lane_creeps/ti9_crocodilian_dire/ti9_crocodilian_dire_melee.vmdl", context )
			PrecacheResource( "model", "models/creeps/neutral_creeps/n_creep_black_dragon/n_creep_black_dragon.vmdl", context )
			PrecacheResource( "model", "models/props_structures/good_fountain001.vmdl", context )
			PrecacheResource( "particle", "particles/basics/silence.vpcf", context )
			PrecacheResource( "particle", "particles/basics/silence__red.vpcf", context )
			PrecacheResource( "particle", "particles/basics/restrict.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", context )
			PrecacheResource( "particle", "particles/items2_fx/teleport_start.vpcf", context )
			PrecacheResource( "particle", "particles/items2_fx/teleport_end.vpcf", context )
			PrecacheResource( "particle", "particles/msg_fx/msg_heal.vpcf", context )
			PrecacheResource( "particle", "particles/msg_fx/msg_gold.vpcf", context )
			PrecacheResource( "particle", "particles/msg_fx/msg_crit.vpcf", context )
			PrecacheResource( "particle", "particles/msg_fx/msg_blocked.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", context )
			PrecacheResource( "particle", "particles/generic_gameplay/generic_stunned.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_alchemist/alchemist_acid_spray_debuff.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_alchemist/alchemist_acid_spray.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_mars/mars_spear_impact_debuff.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_dragon_knight/dragon_knight_dragon_tail_dragonform_proj.vpcf", context )
			PrecacheResource( "particle", "particles/econ/events/ti7/fountain_regen_ti7_lvl3.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_phantom_assassin/phantom_assassin_blur.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/omniknight/omni_ti8_head/omniknight_repel_buff_ti8.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/gyrocopter/gyro_ti10_immortal_missile/gyro_ti10_immortal_missile_explosion.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/sven/sven_warcry_ti5/sven_warcry_cast_arc_lightning_impact.vpcf", context )
			PrecacheResource( "particle", "particles/status_fx/status_effect_combo_breaker.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_centaur/centaur_double_edge.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_treant/treant_bramble_root.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/heroes_underlord/abyssal_underlord_pitofmalice_stun.vpcf", context )

		--bloodstained
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

		--crusader
			PrecacheResource( "particle", "particles/crusader/crusader_aura.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/wraith_king/wraith_king_arcana/wk_arc_reincarn.vpcf", context )
			PrecacheResource( "particle", "particles/crusader/crusader_resist.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_rubick/rubick_spell_steal.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell_fear_debuff.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_abaddon/abaddon_aphotic_shield.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_hit.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_abaddon/abaddon_borrowed_time_heal.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/pugna/pugna_ti9_immortal/pugna_ti9_immortal_netherblast.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/terrorblade/terrorblade_back_ti8/terrorblade_sunder_ti8.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/underlord/underlord_ti8_immortal_weapon/underlord_ti8_immortal_pitofmalice_stun_light.vpcf", context )
			PrecacheResource( "particle", "particles/status_fx/status_effect_wraithking_ghosts.vpcf", context )
			PrecacheResource( "particle", "particles/crusader/crusader_trigger.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/phantom_assassin/pa_ti8_immortal_head/pa_ti8_immortal_dagger_debuff_arcana_combined.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_legion_commander/legion_commander_courage_hit.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_explosion.vpcf", context )
			PrecacheResource( "particle", "particles/items3_fx/octarine_core_lifesteal.vpcf", context )
			PrecacheResource( "particle", "particles/crusader/crusader_aura_buff_caster.vpcf", context )
			PrecacheResource( "particle", "particles/crusader/crusader_aura_buff.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_skeletonking/wraith_king_ghosts_ambient.vpcf", context )


		--icebreaker
			PrecacheResource( "model", "models/items/tuskarr/sigil/boreal_sigil/boreal_sigil.vmdl", context )
			PrecacheResource( "particle", "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_radiant.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ambient.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/winter_wyvern/winter_wyvern_ti7/wyvern_cold_embrace_ti7buff.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/drow/drow_ti9_immortal/status_effect_drow_ti9_frost_arrow.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_start.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/cm_arcana_pup_flee.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/ancient_apparition/aa_blast_ti_5/ancient_apparition_ice_blast_explode_ti5.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_abaddon/abaddon_curse_frostmourne_debuff.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_drow/drow_hypothermia_counter_stack.vpcf", context )
			PrecacheResource( "particle", "particles/icebreaker/icebreaker_counter_stack.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch_buff.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_drow/drow_silence_wave.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_jakiro/jakiro_ice_path.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_jakiro/jakiro_ice_path_b.vpcf", context )
			PrecacheResource( "particle", "particles/econ/events/winter_major_2017/blink_dagger_start_wm07.vpcf", context )
			PrecacheResource( "particle", "particles/econ/events/winter_major_2017/blink_dagger_end_wm07.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave_crit.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_death.vpcf", context )
			PrecacheResource( "particle", "particles/items_fx/black_king_bar_avatar.vpcf" , context )
			PrecacheResource( "particle", "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_l2_radiant.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_tusk/tusk_frozen_sigil.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_winter_wyvern/wyvern_cold_embrace_buff.vpcf", context )
			PrecacheResource( "particle", "particles/icebreaker/icebreaker_blur.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/phantom_assassin/pa_fall20_immortal_shoulders/pa_fall20_blur_ambient_warp.vpcf", context )
			PrecacheResource( "particle", "particles/icebreaker/icebreaker_zero.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf", context )
		
		--inquisitor
			PrecacheResource( "particle", "particles/econ/items/lanaya/ta_ti9_immortal_shoulders/ta_ti9_refraction.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_oracle/oracle_false_promise_attacked.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/effigies/status_fx_effigies/se_effigy_fm16_rad_lvl2.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_oracle/oracle_false_promise_attacked.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_phoenix/phoenix_supernova_egg.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_witchdoctor/witchdoctor_voodoo_restoration_heal.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_treant/treant_bramble_root.vpcf", context )
			PrecacheResource( "particle", "particles/econ/events/ti9/blink_dagger_ti9_start_lvl2.vpcf", context )
			PrecacheResource( "particle", "particles/econ/events/ti9/blink_dagger_ti9_end_sparkles_outer.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/effigies/status_fx_effigies/aghs_statue_boss_ambient.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/phantom_assassin/pa_fall20_immortal_shoulders/pa_fall20_blur_start.vpcf", context )
			PrecacheResource( "particle", "particles/econ/events/ti10/blink_dagger_end_ti10_lvl2.vpcf", context )
			PrecacheResource( "particle", "particles/econ/events/ti10/blink_dagger_start_ti10_splash.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_spawn_v2.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/centaur/centaur_ti6_gold/centaur_ti6_warstomp_gold.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/lifestealer/lifestealer_immortal_backbone_gold/lifestealer_immortal_backbone_gold_rage.vpcf", context )
			PrecacheResource( "particle", "particles/inquisitor/inquisitor_dark_sonic.vpcf", context )
			PrecacheResource( "particle", "particles/status_fx/status_effect_phantom_assassin_fall20_active_blur.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_centaur/centaur_return_buff.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_oracle/oracle_fatesedict.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_oracle/oracle_false_promise_cast_enemy.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_beam_shaft.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_ti6_immortal.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_immortal_cast.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/axe/axe_ti9_immortal/axe_ti9_gold_call.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/earthshaker/earthshaker_totem_ti6/earthshaker_totem_ti6_blur_impact.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/dazzle/dazzle_ti6_gold/dazzle_ti6_shallow_grave_gold.vpcf", context )

		--shadow
			PrecacheResource( "particle", "particles/status_fx/status_effect_phantom_assassin_fall20_active_blur.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_spectre/spectre_ambient.vpcf", context )
			PrecacheResource( "particle", "particles/status_fx/status_effect_maledict.vpcf", context )
			PrecacheResource( "particle", "particles/econ/events/ti9/blink_dagger_ti9_start_lvl2_splash.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_witchdoctor/witchdoctor_shard_switcheroo_cast.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_grimstroke/grimstroke_ink_swell_aoe.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_pangolier/pangolier_heartpiercer_delay.vpcf", context )
			PrecacheResource( "particle", "particles/bioshadow/bioshadow_drain.vpcf", context )
			PrecacheResource( "particle", "particles/bioshadow/bioshadow_deaddly_potion.vpcf", context )
			PrecacheResource( "particle", "particles/bioshadow/bioshadow_poison_hit.vpcf", context )
			PrecacheResource( "particle", "particles/bioshadow/bioshadow_lifetseal.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_dark_seer/dark_seer_vacuum.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_void_spirit/dissimilate/void_spirit_dissimilate_dmg.vpcf", context )
			PrecacheResource( "particle", "particles/econ/events/ti9/blink_dagger_ti9_start_lvl2.vpcf", context )
			PrecacheResource( "particle", "particles/econ/events/ti9/blink_dagger_ti9_lvl2_end.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/void_spirit/void_spirit_immortal_2021/void_spirit_immortal_2021_astral_step_dmg.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/spectre/spectre_transversant_soul/spectre_transversant_spectral_dagger_path_owner.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/grimstroke/gs_fall20_immortal/gs_fall20_immortal_soul_marker.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_grimstroke/grimstroke_ink_swell_buff.vpcf", context )
			PrecacheResource( "particle", "particles/bioshadow/bioshadow_knives.vpcf", context )
			PrecacheResource( "particle", "particles/bioshadow/bioshadow_heart.vpcf", context )
		
		--bocuse
			PrecacheResource( "particle", "particles/bocuse/bocuse_msg.vpcf", context )
			PrecacheResource( "particle", "particles/bocuse/bocuse_strike_blur.vpcf", context )
			PrecacheResource( "particle", "particles/bocuse/bocuse_strike_blur_2.vpcf", context )
			PrecacheResource( "particle", "particles/bocuse/bocuse_strike_blur_3.vpcf", context )
			PrecacheResource( "particle", "particles/bocuse/bocuse_strike_blur_extra_1.vpcf", context )
			PrecacheResource( "particle", "particles/bocuse/bocuse_strike_blur_extra_2.vpcf", context )
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

	--precache soundfile
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_broodmother.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_lone_druid.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_meepo.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_ogre_magi.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_skywrath_mage.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_alchemist.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_clinkz.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_viper.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_brewmaster.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_crystalmaiden.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_queenofpain.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_phantom_assassin.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_drowranger.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_centaur.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_legion_commander.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dawnbreaker.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_abaddon.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dazzle.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_life_stealer.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dark_willow.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_medusa.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_invoker.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_lich.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_antimage.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_puck.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_pangolier.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_spirit_breaker.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_void_spirit.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_necrolyte.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_nevermore.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_slardar.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_grimstroke.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_batrider.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_terrorblade.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_dark_seer.vsndevts", context ) 
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_bane.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_warlock.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_winter_wyvern.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_rubick.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_lion.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_enigma.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_huskar.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_marci.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_monkey_king.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_leshrac.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_abyssal_underlord.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_earthshaker.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_earth_spirit.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_ancient_apparition.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_bounty_hunter.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_templar_assassin.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_stormspirit.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_nightstalker.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_venomancer.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_magnataur.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_visage.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_bloodseeker.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_bristleback.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/voscripts/game_sounds_vo_night_stalker.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_skeletonking.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_juggernaut.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_enchantress.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_faceless_void.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_phoenix.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_chaos_knight.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_elder_titan.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_spectre.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_oracle.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_rattletrap.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_windrunner.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_pugna.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_omniknight.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_keeper_of_the_light.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_mars.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_treant.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_witchdoctor.vsndevts", context )
		PrecacheResource( "soundfile", "soundevents/soundevent_bloodstained.vsndevts", context)
		PrecacheResource( "soundfile", "soundevents/soundevent_bocuse.vsndevts", context)
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = BattleArena()
	GameRules.AddonTemplate:InitGameMode()
end

function BattleArena:InitGameMode()
	print( "Template addon is loaded." )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 )
	
	GameSetup:init()
	local GameMode = GameRules:GetGameModeEntity()

	GameMode:SetBountyRunePickupFilter(
		function(ctx, event)
			event.xp_bounty = 0
			event.gold_bounty = self.gold_bounty + (GameRules:GetDOTATime(false, false) * self.gold_bounty_time)

			for _,player in pairs(self.players) do
				if player:GetPlayerID() == event.player_id_const then
					for i = #self.teams, 1, -1 do
						if player:GetTeamNumber() == self.teams[i][1] then
							local score = self.score_bounty / self.teams[i][4]
							self.teams[i][2] = self.teams[i][2] + score
							local message = self.teams[i][3] .. " SCORE: " .. self.teams[i][2]
							GameRules:SendCustomMessage(self.teams[i][5] .. message .."</font>",-1,0)
						end
						if self.teams[i][2] >= self.score then
							local message = self.teams[i][3] .. " VICTORY!"
							GameRules:SetCustomVictoryMessage(message)
							GameRules:SetGameWinner(self.teams[i][2])
						end
					end
				end
			end
			return true
		end
	, self)

	GameMode:SetModifyExperienceFilter(
		function(ctx, event)
			return false
		end
	, self)

	GameMode:SetModifyGoldFilter(
		function(ctx, event)
			if event.reason_const == 18 then
				return true
			end
			return false
		end
	, self)

	-- GameMode:SetItemAddedToInventoryFilter(
	-- 	function(ctx, event)
	-- 		local unit = EntIndexToHScript(event.inventory_parent_entindex_const)
	-- 		local item = EntIndexToHScript(event.item_entindex_const)
	-- 		if unit:IsHero() and unit:IsIllusion() == false then
	-- 			local observer = 0
	-- 			local sentry = 0
	-- 			for i = 0, 8, 1 do
	-- 				local item_slot = unit:GetItemInSlot(i)
	-- 				if item_slot then
	-- 					item_slot:SetCombineLocked(true)
	-- 					if item_slot:GetName() == "item_ward_observer" then
	-- 						observer = observer + 1
	-- 					end
	-- 					if item_slot:GetName() == "item_ward_sentry" then
	-- 						sentry = sentry + 1
	-- 					end
	-- 				end
	-- 			end
	-- 			if item:GetName() == "item_ward_observer" then
	-- 				if observer >= 2 then return false end
	-- 			end
	-- 			if item:GetName() == "item_ward_sentry" then
	-- 				if sentry >= 2 then return false end
	-- 			end
	-- 		end
	-- 		return true
	-- 	end
	-- , self)


	self.score = 200
	self.score_kill = 5
	self.score_bounty = 10

	self.gold_kill = 50
	self.gold_kill_mult = 5
	self.gold_bounty = 50
	self.gold_bounty_time = 0.1

	self.players = {}
	self.teams = { -- [1] Team, [2] Score, [3] Team Name, [4] number of players, [5] team colour bar
		[1] = {[1] = DOTA_TEAM_CUSTOM_1, [2] = 0, [3] = "Team Green",  [4] = 0, [5] = "<font color='#009900'>"},
		[2] = {[1] = DOTA_TEAM_CUSTOM_2, [2] = 0, [3] = "Team Red",    [4] = 0, [5] = "<font color='#990000'>"},
		[3] = {[1] = DOTA_TEAM_CUSTOM_3, [2] = 0, [3] = "Team Yellow", [4] = 0, [5] = "<font color='#cc9900'>"},
		[4] = {[1] = DOTA_TEAM_CUSTOM_4, [2] = 0, [3] = "Team Cyan",   [4] = 0, [5] = "<font color='#0099cc'>"},
		[5] = {[1] = DOTA_TEAM_CUSTOM_5, [2] = 0, [3] = "Team Purple", [4] = 0, [5] = "<font color='#9900cc'>"}
	}

	ListenToGameEvent("entity_killed", Dynamic_Wrap(self, "OnUnitKilled"), self)
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(self, "OnUnitSpawn"), self)

	local fountain = CreateUnitByName("fountain_building", Vector(-250,-300,0), true, nil, nil, DOTA_TEAM_NEUTRALS)
	--fountain:RemoveModifierByName("modifier_invulnerable")
	Timers:CreateTimer((0.2), function()
		fountain:SetAbsOrigin(Vector(-250,-300,0))
	end)
	
    self.spots = {
        [1] = { [1] = {}, [2] = Vector(3960, -2963, 0), [3] = -30, [4] = 1},
		[2] = { [1] = {}, [2] = Vector(1604, -4734, 0), [3] = -30, [4] = 1},
        [3] = { [1] = {}, [2] = Vector(509, -3086, 0), [3] = -30, [4] = 1},
        [4] = { [1] = {}, [2] = Vector(-2429, -3974, 0), [3] = -30, [4] = 1},
        [5] = { [1] = {}, [2] = Vector(-3011, -1664, 0), [3] = -30, [4] = 1},
        [6] = { [1] = {}, [2] = Vector(-4274, -455, 0), [3] = -30, [4] = 1},
        [7] = { [1] = {}, [2] = Vector(-4017, 1468, 0), [3] = -30, [4] = 1},
        [8] = { [1] = {}, [2] = Vector(-2820, 2420, 0), [3] = -30, [4] = 1},
        [9] = { [1] = {}, [2] = Vector(-1410, 2232, 0), [3] = -30, [4] = 1},
        [10] = { [1] = {}, [2] = Vector(-3515, 3128, 0), [3] = -30, [4] = 1},
        [11] = { [1] = {}, [2] = Vector(-1796, 3575, 0), [3] = -30, [4] = 1},
        [12] = { [1] = {}, [2] = Vector(-1727, 5223, 0), [3] = -30, [4] = 1},
        [13] = { [1] = {}, [2] = Vector(65, 5298, 0), [3] = -30, [4] = 1},
		[14] = { [1] = {}, [2] = Vector(3459, 4393, 0), [3] = -30, [4] = 1},
        [15] = { [1] = {}, [2] = Vector(4269, 2743, 0), [3] = -30, [4] = 1},
        [16] = { [1] = {}, [2] = Vector(1457, 1858, 0), [3] = -30, [4] = 1},
        [17] = { [1] = {}, [2] = Vector(4728, 1130, 0), [3] = -30, [4] = 1},
        [18] = { [1] = {}, [2] = Vector(4412, -1042, 0), [3] = -30, [4] = 1},
        [19] = { [1] = {}, [2] = Vector(2624, -896, 0), [3] = -30, [4] = 1},
        [20] = { [1] = {}, [2] = Vector(2188, -2578, 0), [3] = -30, [4] = 1}
    }

	local count = 0
	for _,spot in pairs(self.spots) do
		count = count + 1
		self:CreateSpot(count)
	end
end

function BattleArena:GiveWards()
	local time = math.floor(GameRules:GetDOTATime(false, false))
	if not self.observer_time then self.observer_time = -10 end
	if not self.sentry_time then self.sentry_time = -10 end
	local has_observer = false
	local has_sentry = false
	
	for _,player in pairs(self.players) do
		local observer_time = 40
		local sentry_time = 60
		local max_wards = 4
		for i = #self.teams, 1, -1 do
			if player:GetTeamNumber() == self.teams[i][1] then
				observer_time = observer_time * (self.teams[i][4] + 1)
				sentry_time = sentry_time * (self.teams[i][4] + 1)
				max_wards = max_wards - self.teams[i][4]
				if max_wards == 0 then max_wards = 1 end
			end
		end

		-- OBSERVER
		if time % observer_time == 0 and self.observer_time < time then
			has_observer = true
			local dispenser = player:FindItemInInventory("item_ward_dispenser")
			if dispenser ~= nil then
				if dispenser:GetCurrentCharges() < max_wards then
					player:AddItemByName("item_ward_observer")
				end
			else
				local observer = player:FindItemInInventory("item_ward_observer")
				if observer == nil then
					player:AddItemByName("item_ward_observer")
				elseif observer:GetCurrentCharges() < max_wards then
					player:AddItemByName("item_ward_observer")
				end
			end
		end

		--SENTRY
		if time % sentry_time == 0 and self.sentry_time < time then
			has_sentry = true
			local dispenser = player:FindItemInInventory("item_ward_dispenser")
			if dispenser ~= nil then
				if dispenser:GetSecondaryCharges() < max_wards then
					player:AddItemByName("item_ward_sentry")
				end
			else
				local observer = player:FindItemInInventory("item_ward_sentry")
				if observer == nil then
					player:AddItemByName("item_ward_sentry")
				elseif observer:GetCurrentCharges() < max_wards then
					player:AddItemByName("item_ward_sentry")
				end
			end
		end
	end

	if has_observer then self.observer_time = time end
	if has_sentry then self.sentry_time = time end
end

function BattleArena:SpawnBountyRune()
	local time = GameRules:GetDOTATime(false, false)
	local intervals = 180
	local ping_delay = 40
	if self.creation_time == nil then 
		self.creation_time = -60
	end

	if math.floor(time) == 0 then
		if self.creation_time ~= math.floor(time) then
			self.creation_time = math.floor(time)
			CreateRune(self.pos, DOTA_RUNE_BOUNTY)
			self:CreateMinimapEvent(0.5, 256)
		end
	end

	if (math.floor(time) + ping_delay) % intervals == 0 then
		local rand = RandomInt(1,6)
		if rand == 1 then self.pos = Vector(-255,-2114,136) end
		if rand == 2 then self.pos = Vector(2686,-4038,136) end
		if rand == 3 then self.pos = Vector(-3197,61,136) end
		if rand == 4 then self.pos = Vector(315,3317,8) end
		if rand == 5 then self.pos = Vector(2558,2298,264) end
		if rand == 6 then self.pos = Vector(-4606,-2052,392) end
		self:CreateMinimapEvent(ping_delay, 128)
	end

	if math.floor(time) % intervals == 0 then
		if self.creation_time ~= math.floor(time) then
			self.creation_time = math.floor(time)
			CreateRune(self.pos, DOTA_RUNE_BOUNTY)
			self:CreateMinimapEvent(0.5, 256)
		end
	end
end

function BattleArena:CreateMinimapEvent(duration, step)
	for _,team in pairs(self.teams) do
		for _,player in pairs(self.players) do
			if player:GetTeamNumber() == team[1] then
				MinimapEvent(team[1], player, self.pos.x, self.pos.y, step, duration)
			end
		end
		if step == 128 then
			GameRules:ExecuteTeamPing(team[1], self.pos.x, self.pos.y, nil, 0)
		end
	end
end

function BattleArena:CreateSpot(number)
	local time = GameRules:GetDOTATime(false, false)
	local spawn_time = 30
	local respawn_time = 60
	local new = true
	for _,unit in pairs(self.spots[number][1]) do
		if unit ~= nil then
			if unit:IsAlive() then
				new = false
			end
		end
	end
	
	if new then
		if self.spots[number][3] == nil then
			self.spots[number][3] = time
		end

		if time >= spawn_time and time - self.spots[number][3] >= respawn_time then
			self:RandomizeNeutrals(number)
		end
	end
end

function BattleArena:RandomizeNeutrals(number)
	local time = GameRules:GetDOTATime(false, false)
	local factor_quantity = 1 + math.floor(time / 150)
	if factor_quantity > 16 then factor_quantity = 16 end

	local tier_3 = RandomInt(1, 100)

	local quantity = 0
	for _,spot in pairs(self.spots) do
		if spot[4] == 3 then
			quantity = quantity + 1
		end
	end

	if tier_3 <= 50 and quantity < factor_quantity then
		local rand_3 = RandomInt(1,3)

		if rand_3 == 1 then
			local unit = CreateUnitByName("neutral_lamp", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
			table.insert(self.spots[number][1], unit)
			

			self.spots[number][3] = nil
			self.spots[number][4] = 3
			return
		end

		if rand_3 == 2 then
			local unit = CreateUnitByName("neutral_spider", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
			table.insert(self.spots[number][1], unit)
			
	
			self.spots[number][3] = nil
			self.spots[number][4] = 3
			return
		end
	
		if rand_3 == 3 then
			local unit = CreateUnitByName("neutral_skydragon", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
			table.insert(self.spots[number][1], unit)
			
	
			unit = CreateUnitByName("neutral_dragon", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
			table.insert(self.spots[number][1], unit)
			
	
			self.spots[number][3] = nil
			self.spots[number][4] = 3
			return
		end
	end

	local tier_1 = RandomInt(1,5)

	if tier_1 == 1 then
		local unit = CreateUnitByName("neutral_basic_chameleon", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
		table.insert(self.spots[number][1], unit)
		

		unit = CreateUnitByName("neutral_basic_chameleon", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
		table.insert(self.spots[number][1], unit)
		

		unit = CreateUnitByName("neutral_basic_chameleon_b", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
		table.insert(self.spots[number][1], unit)
		

		unit = CreateUnitByName("neutral_basic_chameleon_b", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
		table.insert(self.spots[number][1], unit)
		

		self.spots[number][3] = nil
		self.spots[number][4] = 1
		return
	end

	if tier_1 == 2 then
		local unit = CreateUnitByName("neutral_basic_crocodilian", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
		table.insert(self.spots[number][1], unit)
		

		unit = CreateUnitByName("neutral_basic_crocodilian_b", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
		table.insert(self.spots[number][1], unit)
		

		self.spots[number][3] = nil
		self.spots[number][4] = 1
		return
	end

	if tier_1 == 3 then
		local unit = CreateUnitByName("neutral_basic_gargoyle", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
		table.insert(self.spots[number][1], unit)
		

		unit = CreateUnitByName("neutral_basic_gargoyle_b", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
		table.insert(self.spots[number][1], unit)
		

		unit = CreateUnitByName("neutral_basic_gargoyle_b", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
		table.insert(self.spots[number][1], unit)
		

		self.spots[number][3] = nil
		self.spots[number][4] = 1
		return
	end

	if tier_1 == 4 then
		local unit = CreateUnitByName("neutral_igor", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
		table.insert(self.spots[number][1], unit)
		

		unit = CreateUnitByName("neutral_frostbitten", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
		table.insert(self.spots[number][1], unit)
		

		unit = CreateUnitByName("neutral_frostbitten", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
		table.insert(self.spots[number][1], unit)
		

		self.spots[number][3] = nil
		self.spots[number][4] = 2
		return
	end

	if tier_1 == 5 then
		local unit = CreateUnitByName("neutral_crocodile", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
		table.insert(self.spots[number][1], unit)
		

		unit = CreateUnitByName("neutral_crocodile", self.spots[number][2], true, nil, nil, DOTA_TEAM_NEUTRALS)
		table.insert(self.spots[number][1], unit)
		

		self.spots[number][3] = nil
		self.spots[number][4] = 2
		return
	end
end

function BattleArena:RandomizePlayerSpawn(unit)
	local further_loc = nil
	local further_distance = nil

	local spawn_pos = {
		[1] = Vector(455, -1394, 0),
		[2] = Vector(-1040, -3661, 0),
		[3] = Vector(-2724, -2628, 0),
		[4] = Vector(-2563, -923, 0),
		[5] = Vector(-3144, 1596, 0),
		[6] = Vector(-828, 1413, 0),
		[7] = Vector(-2047, 4349, 0),
		[8] = Vector(1858, 5903, 0),
		[9] = Vector(935, 2619, 0),
		[10] = Vector(3291, 2578, 0),
		[11] = Vector(1084, 875, 0),
		[12] = Vector(3587, -670, 0),
		[13] = Vector(3848, -1969, 0),
		[14] = Vector(3920, -3897, 0),
		[15] = Vector(2175, -3259, 0)
	}

	local flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
	local enemies = FindUnitsInRadius(
		unit:GetTeamNumber(),	-- int, your team number
		unit:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO,	-- int, type filter
		flags,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)
	for _,loc in pairs(spawn_pos) do
		local closer = nil
		local distance = 0
		
		for _,enemy in pairs(enemies) do
			if (enemy:IsAlive() == false and enemy:IsReincarnating()) or enemy:IsAlive() then
				if closer == nil then
					closer = loc
					distance = (loc - enemy:GetAbsOrigin()):Length()
				end
				if (loc - enemy:GetAbsOrigin()):Length() < distance then
					closer = loc
					distance = (loc - enemy:GetAbsOrigin()):Length()
				end
			end
		end

		if further_loc == nil then
			further_loc = closer
			further_distance = distance
		else
			if distance > further_distance then
				further_loc = closer
				further_distance = distance
			end
		end
	end

	if further_loc == nil then
		further_loc = spawn_pos[RandomInt(1, 12)]
	end

	unit:SetOrigin(further_loc)
	FindClearSpaceForUnit(unit, further_loc, true)
end

function BattleArena:OnUnitKilled( args )
	local unit = EntIndexToHScript(args.entindex_killed)
	local killer = EntIndexToHScript(args.entindex_attacker)
	if unit == nil or killer == nil then return end
	if unit:IsReincarnating() then return end

	if unit:IsCreature() and unit:GetTeamNumber() == DOTA_TEAM_NEUTRALS then
		for _,spot in pairs(self.spots) do
			for i = #spot[1], 1, -1 do
				local neutral = spot[1][i]
				if neutral == unit then
					table.remove(spot[1],i)
					break
				end
			end
		end
	end

	if unit:IsHero() then
		local hero_kill = false
		if killer:GetClassname() ~= "ability_lua" then
			if killer:IsHero() then
				hero_kill = true
			end
		end

		for i = #self.teams, 1, -1 do
			if hero_kill == false then
				if unit:GetTeamNumber() == self.teams[i][1] then
					self.teams[i][2] = self.teams[i][2] - self.score_kill
					local message = self.teams[i][3] .. " SCORE: " .. self.teams[i][2]
					GameRules:SendCustomMessage(self.teams[i][5] .. message .."</font>",-1,0)
				end
			else
				if killer:GetTeamNumber() == self.teams[i][1] then
					self.teams[i][2] = self.teams[i][2] + self.score_kill
					local message = self.teams[i][3] .. " SCORE: " .. self.teams[i][2]
					GameRules:SendCustomMessage(self.teams[i][5] .. message .."</font>",-1,0)
				end
			end
			if self.teams[i][2] >= self.score then
				local message = self.teams[i][3] .. " VICTORY!"
				GameRules:SetCustomVictoryMessage(message)
				GameRules:SetGameWinner(self.teams[i][2])
			end
		end
	end

	local gold = 0
	local number = 1

	if killer:GetClassname() == "ability_lua" then return end

	local player_owner = killer:GetPlayerOwner()
	if player_owner == nil then return end
	local assigned_hero = player_owner:GetAssignedHero()
	if assigned_hero == nil then return end

	if unit:IsHero() and unit:IsIllusion() == false
	and assigned_hero:GetTeamNumber() ~= unit:GetTeamNumber() then

		local allies = FindUnitsInRadius(
			assigned_hero:GetTeamNumber(),	-- int, your team number
			unit:GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			1500,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)
		for _,unit in pairs(allies) do
			if unit ~= assigned_hero then
				number = number + 1
			end
		end

		gold = (((unit:GetLevel() + 1) * self.gold_kill_mult) + self.gold_kill) / number

		if math.floor(gold) > 0 then
			assigned_hero:ModifyGold(math.floor(gold), false, 18)

			for _,unit in pairs(allies) do
				if unit ~= assigned_hero then
					unit:ModifyGold(math.floor(gold), false, 18)
				end
			end
		end

		return
	end

	if unit:IsCreature() and unit:GetUnitName() ~= "crusader" and unit:IsIllusion() == false
	and assigned_hero:GetTeamNumber() ~= unit:GetTeamNumber() then

		local allies = FindUnitsInRadius(
			assigned_hero:GetTeamNumber(),	-- int, your team number
			unit:GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			750,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)
		for _,unit in pairs(allies) do
			if unit ~= assigned_hero then
				number = number + 1
			end
		end

		local average_gold_bounty = RandomInt(unit:GetMinimumGoldBounty(), unit:GetMaximumGoldBounty())
		gold = average_gold_bounty / number

		if math.floor(gold) > 0 then
			assigned_hero:ModifyGold(math.floor(gold), false, 18)

			for _,unit in pairs(allies) do
				if unit ~= assigned_hero then
					unit:ModifyGold(math.floor(gold), false, 18)
				end
			end
		end
	end
end

function BattleArena:OnUnitSpawn( args )
	local unit = EntIndexToHScript(args.entindex)
	if unit == nil then return end
	if unit:IsReincarnating() then return end
	if unit:IsHero() and unit:IsIllusion() == false then
		self:RandomizePlayerSpawn(unit)
		
		local playerID = unit:GetPlayerOwnerID()
		if playerID ~= nil then
			CenterCameraOnUnit(playerID, unit)
		end

		if unit:HasItemInInventory("item_tp") == false then
			unit:AddItemByName("item_tp")

			if IsInToolsMode() then
				if self.temp == nil then
					self.temp = 1
				else
					self.temp = self.temp + 1
					unit:SetTeam(self.teams[self.temp][1])
				end
			end

			for i = #self.teams, 1, -1 do
				if unit:GetTeamNumber() == self.teams[i][1] then
					self.teams[i][4] = self.teams[i][4] + 1
				end
			end

			table.insert(self.players, unit)
		end
	end
end

-- Evaluate the state of the game
function BattleArena:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		if math.floor(GameRules:GetDOTATime(false, true)) == -40 then
			local rand = RandomInt(1,6)
			if rand == 1 then self.pos = Vector(-255,-2114,136) end
			if rand == 2 then self.pos = Vector(2686,-4038,136) end
			if rand == 3 then self.pos = Vector(-3197,61,136) end
			if rand == 4 then self.pos = Vector(315,3317,8) end
			if rand == 5 then self.pos = Vector(2558,2298,264) end
			if rand == 6 then self.pos = Vector(-4606,-2052,392) end
			self:CreateMinimapEvent(40, 128)
		end
	end
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		local myTable = CustomNetTables:GetTableValue("game_state", "round_data")		

		if myTable == nil then
			CustomNetTables:SetTableValue("game_state", "round_data", { value = 0 })
		else
			local nextValue = myTable.value + 1
			CustomNetTables:SetTableValue("game_state", "round_data", { value = nextValue })
		end

		local index = 0
		for _,spot in pairs(self.spots) do
			index = index + 1
			self:CreateSpot(index)
		end

		self:GiveWards()
		self:SpawnBountyRune()
		
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end
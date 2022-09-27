icebreaker_1__hypo_rank_11 = class ({})
icebreaker_1__hypo_rank_12 = class ({})
icebreaker_1__hypo_rank_21 = class ({})
icebreaker_1__hypo_rank_22 = class ({})
icebreaker_1__hypo_rank_31 = class ({})
icebreaker_1__hypo_rank_32 = class ({})
icebreaker_1__hypo_rank_41 = class ({})
icebreaker_1__hypo_rank_42 = class ({})

icebreaker_2__puff_rank_11 = class ({})
icebreaker_2__puff_rank_12 = class ({})
icebreaker_2__puff_rank_21 = class ({})
icebreaker_2__puff_rank_22 = class ({})
icebreaker_2__puff_rank_31 = class ({})
icebreaker_2__puff_rank_32 = class ({})
icebreaker_2__puff_rank_41 = class ({})
icebreaker_2__puff_rank_42 = class ({})

icebreaker_3__zero_rank_11 = class ({})
icebreaker_3__zero_rank_12 = class ({})
icebreaker_3__zero_rank_21 = class ({})
icebreaker_3__zero_rank_22 = class ({})
icebreaker_3__zero_rank_31 = class ({})
icebreaker_3__zero_rank_32 = class ({})
icebreaker_3__zero_rank_41 = class ({})
icebreaker_3__zero_rank_42 = class ({})

icebreaker_4__wave_rank_11 = class ({})
icebreaker_4__wave_rank_12 = class ({})
icebreaker_4__wave_rank_21 = class ({})
icebreaker_4__wave_rank_22 = class ({})
icebreaker_4__wave_rank_31 = class ({})
icebreaker_4__wave_rank_32 = class ({})
icebreaker_4__wave_rank_41 = class ({})
icebreaker_4__wave_rank_42 = class ({})

icebreaker_5__mirror_rank_11 = class ({})
icebreaker_5__mirror_rank_12 = class ({})
icebreaker_5__mirror_rank_21 = class ({})
icebreaker_5__mirror_rank_22 = class ({})
icebreaker_5__mirror_rank_31 = class ({})
icebreaker_5__mirror_rank_32 = class ({})
icebreaker_5__mirror_rank_41 = class ({})
icebreaker_5__mirror_rank_42 = class ({})

icebreaker_u__blink_rank_11 = class ({})
icebreaker_u__blink_rank_12 = class ({})
icebreaker_u__blink_rank_21 = class ({})
icebreaker_u__blink_rank_22 = class ({})
icebreaker_u__blink_rank_31 = class ({})
icebreaker_u__blink_rank_32 = class ({})
icebreaker_u__blink_rank_41 = class ({})
icebreaker_u__blink_rank_42 = class ({})

icebreaker__precache = class ({})

function icebreaker__precache:Spawn()
    if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function icebreaker__precache:Precache(context)
    --PrecacheResource("soundfile", "soundevents/soundevent_icebreaker.vsndevts", context)
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
    PrecacheResource( "particle", "particles/econ/events/winter_major_2017/blink_dagger_start_wm06.vpcf", context )
    PrecacheResource( "particle", "particles/econ/events/winter_major_2017/blink_dagger_end_wm06.vpcf", context )
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
    PrecacheResource( "particle", "particles/items2_fx/shivas_guard_active.vpcf", context )
    PrecacheResource( "particle", "particles/items2_fx/shivas_guard_impact.vpcf", context )
    PrecacheResource( "particle", "", context )

    PrecacheResource( "model", "models/items/rikimaru/shadowfang_offhand/shadowfang_offhand.vmdl", context )
    PrecacheResource( "model", "models/items/rikimaru/haze_atrocity_weapon/haze_atrocity_weapon.vmdl", context )
    PrecacheResource( "model", "models/items/rikimaru/riki_killer_of_purple_smoke_tail/riki_killer_of_purple_smoke_tail.vmdl", context )
    PrecacheResource( "model", "models/items/rikimaru/riki_ti8_immortal_head/riki_ti8_immortal_head.vmdl", context )
    PrecacheResource( "model", "models/items/rikimaru/riki_killer_of_purple_smoke_arms/riki_killer_of_purple_smoke_arms.vmdl", context )
    PrecacheResource( "model", "models/items/rikimaru/ti6_blink_strike/riki_ti6_blink_strike.vmdl", context )
    PrecacheResource( "particle", "particles/icebreaker/icebreaker_head/icebreaker_head_ambient_ti8_crimson.vpcf", context )
    PrecacheResource( "particle", "particles/icebreaker/icebreaker_back.vpcf", context )
    PrecacheResource( "particle", "particles/icebreaker/icebreaker_smoke_arms.vpcf", context )
end
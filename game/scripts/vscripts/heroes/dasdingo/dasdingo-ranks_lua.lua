dasdingo_1__heal_rank_11 = class ({})
dasdingo_1__heal_rank_12 = class ({})
dasdingo_1__heal_rank_21 = class ({})
dasdingo_1__heal_rank_22 = class ({})
dasdingo_1__heal_rank_31 = class ({})
dasdingo_1__heal_rank_32 = class ({})
dasdingo_1__heal_rank_41 = class ({})
dasdingo_1__heal_rank_42 = class ({})

dasdingo_2__aura_rank_11 = class ({})
dasdingo_2__aura_rank_12 = class ({})
dasdingo_2__aura_rank_21 = class ({})
dasdingo_2__aura_rank_22 = class ({})
dasdingo_2__aura_rank_31 = class ({})
dasdingo_2__aura_rank_32 = class ({})
dasdingo_2__aura_rank_41 = class ({})
dasdingo_2__aura_rank_42 = class ({})

dasdingo_3__hex_rank_11 = class ({})
dasdingo_3__hex_rank_12 = class ({})
dasdingo_3__hex_rank_21 = class ({})
dasdingo_3__hex_rank_22 = class ({})
dasdingo_3__hex_rank_31 = class ({})
dasdingo_3__hex_rank_32 = class ({})
dasdingo_3__hex_rank_41 = class ({})
dasdingo_3__hex_rank_42 = class ({})

dasdingo_4__tribal_rank_11 = class ({})
dasdingo_4__tribal_rank_12 = class ({})
dasdingo_4__tribal_rank_21 = class ({})
dasdingo_4__tribal_rank_22 = class ({})
dasdingo_4__tribal_rank_31 = class ({})
dasdingo_4__tribal_rank_32 = class ({})
dasdingo_4__tribal_rank_41 = class ({})
dasdingo_4__tribal_rank_42 = class ({})

dasdingo_5__lash_rank_11 = class ({})
dasdingo_5__lash_rank_12 = class ({})
dasdingo_5__lash_rank_21 = class ({})
dasdingo_5__lash_rank_22 = class ({})
dasdingo_5__lash_rank_31 = class ({})
dasdingo_5__lash_rank_32 = class ({})
dasdingo_5__lash_rank_41 = class ({})
dasdingo_5__lash_rank_42 = class ({})

dasdingo_6__fire_rank_11 = class ({})
dasdingo_6__fire_rank_12 = class ({})
dasdingo_6__fire_rank_21 = class ({})
dasdingo_6__fire_rank_22 = class ({})
dasdingo_6__fire_rank_31 = class ({})
dasdingo_6__fire_rank_32 = class ({})
dasdingo_6__fire_rank_41 = class ({})
dasdingo_6__fire_rank_42 = class ({})

dasdingo_u__maledict_rank_11 = class ({})
dasdingo_u__maledict_rank_12 = class ({})
dasdingo_u__maledict_rank_21 = class ({})
dasdingo_u__maledict_rank_22 = class ({})
dasdingo_u__maledict_rank_31 = class ({})
dasdingo_u__maledict_rank_32 = class ({})
dasdingo_u__maledict_rank_41 = class ({})
dasdingo_u__maledict_rank_42 = class ({})

dasdingo__precache = class ({})

function dasdingo__precache:Spawn()
    if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function dasdingo__precache:Precache(context)
    PrecacheResource("soundfile", "soundevents/soundevent_dasdingo.vsndevts", context)

    PrecacheResource( "particle", "particles/units/heroes/hero_oracle/oracle_purifyingflames.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/witch_doctor/wd_ti10_immortal_weapon_gold/wd_ti10_immortal_voodoo_gold.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/juggernaut/jugg_fortunes_tout/jugg_healing_ward_fortunes_tout_ward_gold_flame.vpcf", context )
    PrecacheResource( "particle", "particles/dasdingo/dasdingo_aura.vpcf", context )
    PrecacheResource( "particle", "particles/dasdingo/dasdingo_aura.vpcf", context )
    PrecacheResource( "particle", "particles/dasdingo/dasdingo_aura.vpcf", context )
    PrecacheResource( "particle", "particles/dasdingo/dasdingo_aura.vpcf", context )
    PrecacheResource( "particle", "particles/dasdingo/dasdingo_aura.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/wraith_king/wraith_king_ti6_bracer/wraith_king_ti6_hellfireblast_debuff.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/alchemist/alchemist_smooth_criminal/alchemist_smooth_criminal_unstable_concoction_explosion.vpcf", context )
    PrecacheResource( "particle", "particles/dasdingo/dasdingo_fire_debuff.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_nevermore/nevermore_requiemofsouls.vpcf", context )
    PrecacheResource( "particle", "particles/dasdingo/requiem/dasdingo_requiemofsouls_line.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/shadow_shaman/ss_2021_crimson/shadowshaman_crimson_shackle.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_viper/viper_corrosive_debuff.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_skeletonking/wraith_king_ghosts_ambient.vpcf", context )
    PrecacheResource( "particle", "particles/status_fx/status_effect_wraithking_ghosts.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf", context )
    PrecacheResource( "particle", "particles/dasdingo/dasdingo_aoe_hex.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/witch_doctor/wd_ti8_immortal_head/wd_ti8_immortal_maledict.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/invoker/invoker_ti6/invoker_deafening_blast_ti6_knockback_debuff.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/witch_doctor/wd_2021_cache/wd_2021_cache_death_ward.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/juggernaut/jugg_fortunes_tout/jugg_healling_ward_fortunes_tout_hero_heal.vpcf", context )
    PrecacheResource( "particle", "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_chakra_magic.vpcf", context )
    PrecacheResource( "particle", "particles/msg_fx/msg_mana_add.vpcf", context )

    PrecacheResource( "model", "models/items/shadowshaman/shaman_charmer_of_firesnake_arms/shaman_charmer_of_firesnake_arms.vmdl", context )
    PrecacheResource( "model", "models/items/shadowshaman/ti8_ss_mushroomer_weapon/ti8_ss_mushroomer_weapon.vmdl", context )
    PrecacheResource( "model", "models/items/shadowshaman/shaman_charmer_of_firesnake_off_hand/shaman_charmer_of_firesnake_off_hand.vmdl", context )
    PrecacheResource( "model", "models/items/shadowshaman/ss_fall20_immortal_head/ss_fall20_immortal_head.vmdl", context )
    PrecacheResource( "model", "models/items/shadowshaman/ti8_ss_mushroomer_belt/ti8_ss_mushroomer_belt.vmdl", context )
    PrecacheResource( "particle", "particles/econ/items/shadow_shaman/ti8_ss_mushroomer_weapon/ti8_ss_mushroomer_weapon_ambient.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/shadow_shaman/shadow_shaman_charmer_firesnake/shadow_shaman_charmer_firesnake_offhand.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/shadow_shaman/ss_2021_crimson/shadowshaman_2021_crimson_hair.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/shadow_shaman/ss_2021_crimson/shadowshaman_2021_crimson_ambient.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/shadow_shaman/ss_2021_crimson/shadowshaman_2021_crimson_ambient_eyes.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/shadow_shaman/ss_2021_crimson/shadowshaman_2021_crimson_ambient_mouth_drips.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/shadow_shaman/ss_2021_crimson/shadowshaman_2021_crimson_ambient_crystal.vpcf", context )
    PrecacheResource( "particle", "particles/econ/items/shadow_shaman/ti8_ss_mushroomer_belt/ti8_ss_mushroomer_belt_ambient.vpcf", context )
end
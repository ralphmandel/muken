genuine_1__shooting_rank_11 = class ({})
genuine_1__shooting_rank_12 = class ({})
genuine_1__shooting_rank_21 = class ({})
genuine_1__shooting_rank_22 = class ({})
genuine_1__shooting_rank_31 = class ({})
genuine_1__shooting_rank_32 = class ({})
genuine_1__shooting_rank_41 = class ({})
genuine_1__shooting_rank_42 = class ({})

genuine_2__fallen_rank_11 = class ({})
genuine_2__fallen_rank_12 = class ({})
genuine_2__fallen_rank_21 = class ({})
genuine_2__fallen_rank_22 = class ({})
genuine_2__fallen_rank_31 = class ({})
genuine_2__fallen_rank_32 = class ({})
genuine_2__fallen_rank_41 = class ({})
genuine_2__fallen_rank_42 = class ({})

genuine_3__morning_rank_11 = class ({})
genuine_3__morning_rank_12 = class ({})
genuine_3__morning_rank_21 = class ({})
genuine_3__morning_rank_22 = class ({})
genuine_3__morning_rank_31 = class ({})
genuine_3__morning_rank_32 = class ({})
genuine_3__morning_rank_41 = class ({})
genuine_3__morning_rank_42 = class ({})

genuine_4__awakening_rank_11 = class ({})
genuine_4__awakening_rank_12 = class ({})
genuine_4__awakening_rank_21 = class ({})
genuine_4__awakening_rank_22 = class ({})
genuine_4__awakening_rank_31 = class ({})
genuine_4__awakening_rank_32 = class ({})
genuine_4__awakening_rank_41 = class ({})
genuine_4__awakening_rank_42 = class ({})

genuine_5__nightfall_rank_11 = class ({})
genuine_5__nightfall_rank_12 = class ({})
genuine_5__nightfall_rank_21 = class ({})
genuine_5__nightfall_rank_22 = class ({})
genuine_5__nightfall_rank_31 = class ({})
genuine_5__nightfall_rank_32 = class ({})
genuine_5__nightfall_rank_41 = class ({})
genuine_5__nightfall_rank_42 = class ({})

genuine_u__star_rank_11 = class ({})
genuine_u__star_rank_12 = class ({})
genuine_u__star_rank_21 = class ({})
genuine_u__star_rank_22 = class ({})
genuine_u__star_rank_31 = class ({})
genuine_u__star_rank_32 = class ({})
genuine_u__star_rank_41 = class ({})
genuine_u__star_rank_42 = class ({})

genuine__precache = class ({})
LinkLuaModifier("genuine_special_values", "heroes/team_moon/genuine/genuine-special_values", LUA_MODIFIER_MOTION_NONE)

function genuine__precache:GetIntrinsicModifierName()
  return "genuine_special_values"
end

function genuine__precache:Spawn()
	if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function genuine__precache:Precache(context)
  PrecacheResource("soundfile", "soundevents/soundevent_genuine.vsndevts", context)
  PrecacheResource("model", "models/items/drow/secret_witch_head/secret_witch_head.vmdl", context)
  PrecacheResource("model", "models/items/drow/secret_witch_legs/secret_witch_legs.vmdl", context)
  PrecacheResource("model", "models/items/drow/secret_witch_arms/secret_witch_arms.vmdl", context)
  PrecacheResource("model", "models/items/drow/secret_witch_shoulder/secret_witch_shoulder.vmdl", context)
  PrecacheResource("model", "models/items/drow/secret_witch_misc/secret_witch_misc.vmdl", context)
  PrecacheResource("model", "models/items/drow/ti6_immortal_cape/mesh/drow_ti6_immortal_cape.vmdl", context)
  PrecacheResource("model", "models/items/drow/drow_ti9_immortal_weapon/drow_ti9_immortal_weapon.vmdl", context)

  PrecacheResource("particle", "particles/genuine/shoulder_efx/genuine_back_ambient.vpcf", context)
  PrecacheResource("particle", "particles/genuine/bow_efx/genuine_bow_ambient.vpcf", context)
  PrecacheResource("particle", "particles/genuine/base_attack/genuine_base_attack.vpcf", context)
  PrecacheResource("particle", "particles/genuine/shooting_star/genuine_shooting.vpcf", context)
  PrecacheResource("particle", "particles/econ/items/drow/drow_ti6_gold/drow_ti6_silence_gold_wave.vpcf", context)
  PrecacheResource("particle", "particles/genuine/genuine_fallen_hit.vpcf", context)
  PrecacheResource("particle", "particles/genuine/morning_star/genuine_morning_star.vpcf", context)
  PrecacheResource("particle", "particles/genuine/genuine_powershoot/genuine_spell_powershot_ti6.vpcf", context)
  PrecacheResource("particle", "particles/genuine/genuine_powershoot/genuine_powershot_channel_combo_v2.vpcf", context)
  PrecacheResource("particle", "particles/genuine/ult_caster/genuine_ult_caster.vpcf", context)
  PrecacheResource("particle", "particles/units/heroes/hero_terrorblade/terrorblade_sunder.vpcf", context)
  PrecacheResource("particle", "particles/genuine/genuine_ultimate.vpcf", context)
  PrecacheResource("particle", "particles/genuine/ult_deny/genuine_deny_v2.vpcf", context)

  PrecacheResource("particle", "particles/genuine/starfall/genuine_starfall_attack.vpcf", context)
  PrecacheResource("particle", "particles/econ/items/drow/drow_ti6_gold/drow_ti6_silence_gold_wave_wide.vpcf", context)
end
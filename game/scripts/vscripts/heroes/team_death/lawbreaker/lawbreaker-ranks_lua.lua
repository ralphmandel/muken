lawbreaker_1__shot_rank_11 = class ({})
lawbreaker_1__shot_rank_12 = class ({})
lawbreaker_1__shot_rank_21 = class ({})
lawbreaker_1__shot_rank_22 = class ({})
lawbreaker_1__shot_rank_31 = class ({})
lawbreaker_1__shot_rank_32 = class ({})
lawbreaker_1__shot_rank_41 = class ({})
lawbreaker_1__shot_rank_42 = class ({})

lawbreaker_2__combo_rank_11 = class ({})
lawbreaker_2__combo_rank_12 = class ({})
lawbreaker_2__combo_rank_21 = class ({})
lawbreaker_2__combo_rank_22 = class ({})
lawbreaker_2__combo_rank_31 = class ({})
lawbreaker_2__combo_rank_32 = class ({})
lawbreaker_2__combo_rank_41 = class ({})
lawbreaker_2__combo_rank_42 = class ({})

lawbreaker_3__grenade_rank_11 = class ({})
lawbreaker_3__grenade_rank_12 = class ({})
lawbreaker_3__grenade_rank_21 = class ({})
lawbreaker_3__grenade_rank_22 = class ({})
lawbreaker_3__grenade_rank_31 = class ({})
lawbreaker_3__grenade_rank_32 = class ({})
lawbreaker_3__grenade_rank_41 = class ({})
lawbreaker_3__grenade_rank_42 = class ({})

lawbreaker_4__rain_rank_11 = class ({})
lawbreaker_4__rain_rank_12 = class ({})
lawbreaker_4__rain_rank_21 = class ({})
lawbreaker_4__rain_rank_22 = class ({})
lawbreaker_4__rain_rank_31 = class ({})
lawbreaker_4__rain_rank_32 = class ({})
lawbreaker_4__rain_rank_41 = class ({})
lawbreaker_4__rain_rank_42 = class ({})

lawbreaker_5__blink_rank_11 = class ({})
lawbreaker_5__blink_rank_12 = class ({})
lawbreaker_5__blink_rank_21 = class ({})
lawbreaker_5__blink_rank_22 = class ({})
lawbreaker_5__blink_rank_31 = class ({})
lawbreaker_5__blink_rank_32 = class ({})
lawbreaker_5__blink_rank_41 = class ({})
lawbreaker_5__blink_rank_42 = class ({})

lawbreaker_u__form_rank_11 = class ({})
lawbreaker_u__form_rank_12 = class ({})
lawbreaker_u__form_rank_21 = class ({})
lawbreaker_u__form_rank_22 = class ({})
lawbreaker_u__form_rank_31 = class ({})
lawbreaker_u__form_rank_32 = class ({})
lawbreaker_u__form_rank_41 = class ({})
lawbreaker_u__form_rank_42 = class ({})

lawbreaker__precache = class ({})
LinkLuaModifier("lawbreaker_special_values", "heroes/team_death/lawbreaker/lawbreaker-special_values", LUA_MODIFIER_MOTION_NONE)

function lawbreaker__precache:GetIntrinsicModifierName()
  return "lawbreaker_special_values"
end

function lawbreaker__precache:Spawn()
	if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function lawbreaker__precache:Precache(context)
  --PrecacheResource("soundfile", "soundevents/soundevent_lawbreaker.vsndevts", context)
end
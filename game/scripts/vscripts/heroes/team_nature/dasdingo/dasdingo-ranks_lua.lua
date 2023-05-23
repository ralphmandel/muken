dasdingo_1__field_rank_11 = class ({})
dasdingo_1__field_rank_12 = class ({})
dasdingo_1__field_rank_21 = class ({})
dasdingo_1__field_rank_22 = class ({})
dasdingo_1__field_rank_31 = class ({})
dasdingo_1__field_rank_32 = class ({})
dasdingo_1__field_rank_41 = class ({})
dasdingo_1__field_rank_42 = class ({})

dasdingo_2__shield_rank_11 = class ({})
dasdingo_2__shield_rank_12 = class ({})
dasdingo_2__shield_rank_21 = class ({})
dasdingo_2__shield_rank_22 = class ({})
dasdingo_2__shield_rank_31 = class ({})
dasdingo_2__shield_rank_32 = class ({})
dasdingo_2__shield_rank_41 = class ({})
dasdingo_2__shield_rank_42 = class ({})

dasdingo_3__leech_rank_11 = class ({})
dasdingo_3__leech_rank_12 = class ({})
dasdingo_3__leech_rank_21 = class ({})
dasdingo_3__leech_rank_22 = class ({})
dasdingo_3__leech_rank_31 = class ({})
dasdingo_3__leech_rank_32 = class ({})
dasdingo_3__leech_rank_41 = class ({})
dasdingo_3__leech_rank_42 = class ({})

dasdingo_4__tribal_rank_11 = class ({})
dasdingo_4__tribal_rank_12 = class ({})
dasdingo_4__tribal_rank_21 = class ({})
dasdingo_4__tribal_rank_22 = class ({})
dasdingo_4__tribal_rank_31 = class ({})
dasdingo_4__tribal_rank_32 = class ({})
dasdingo_4__tribal_rank_41 = class ({})
dasdingo_4__tribal_rank_42 = class ({})

dasdingo_5__fire_rank_11 = class ({})
dasdingo_5__fire_rank_12 = class ({})
dasdingo_5__fire_rank_21 = class ({})
dasdingo_5__fire_rank_22 = class ({})
dasdingo_5__fire_rank_31 = class ({})
dasdingo_5__fire_rank_32 = class ({})
dasdingo_5__fire_rank_41 = class ({})
dasdingo_5__fire_rank_42 = class ({})

dasdingo_u__curse_rank_11 = class ({})
dasdingo_u__curse_rank_12 = class ({})
dasdingo_u__curse_rank_21 = class ({})
dasdingo_u__curse_rank_22 = class ({})
dasdingo_u__curse_rank_31 = class ({})
dasdingo_u__curse_rank_32 = class ({})
dasdingo_u__curse_rank_41 = class ({})
dasdingo_u__curse_rank_42 = class ({})

dasdingo__precache = class ({})
LinkLuaModifier("dasdingo__special_values", "heroes/team_nature/dasdingo/dasdingo__special_values", LUA_MODIFIER_MOTION_NONE)

function dasdingo__precache:GetIntrinsicModifierName()
  return "dasdingo__special_values"
end

function dasdingo__precache:Spawn()
	if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function dasdingo__precache:Precache(context)
  PrecacheResource("soundfile", "soundevents/soundevent_dasdingo.vsndevts", context)
end
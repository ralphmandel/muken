template_1__sk1_rank_11 = class ({})
template_1__sk1_rank_12 = class ({})
template_1__sk1_rank_21 = class ({})
template_1__sk1_rank_22 = class ({})
template_1__sk1_rank_31 = class ({})
template_1__sk1_rank_32 = class ({})
template_1__sk1_rank_41 = class ({})
template_1__sk1_rank_42 = class ({})

template_2__sk2_rank_11 = class ({})
template_2__sk2_rank_12 = class ({})
template_2__sk2_rank_21 = class ({})
template_2__sk2_rank_22 = class ({})
template_2__sk2_rank_31 = class ({})
template_2__sk2_rank_32 = class ({})
template_2__sk2_rank_41 = class ({})
template_2__sk2_rank_42 = class ({})

template_3__sk3_rank_11 = class ({})
template_3__sk3_rank_12 = class ({})
template_3__sk3_rank_21 = class ({})
template_3__sk3_rank_22 = class ({})
template_3__sk3_rank_31 = class ({})
template_3__sk3_rank_32 = class ({})
template_3__sk3_rank_41 = class ({})
template_3__sk3_rank_42 = class ({})

template_4__sk4_rank_11 = class ({})
template_4__sk4_rank_12 = class ({})
template_4__sk4_rank_21 = class ({})
template_4__sk4_rank_22 = class ({})
template_4__sk4_rank_31 = class ({})
template_4__sk4_rank_32 = class ({})
template_4__sk4_rank_41 = class ({})
template_4__sk4_rank_42 = class ({})

template_5__sk5_rank_11 = class ({})
template_5__sk5_rank_12 = class ({})
template_5__sk5_rank_21 = class ({})
template_5__sk5_rank_22 = class ({})
template_5__sk5_rank_31 = class ({})
template_5__sk5_rank_32 = class ({})
template_5__sk5_rank_41 = class ({})
template_5__sk5_rank_42 = class ({})

template_u__sk6_rank_11 = class ({})
template_u__sk6_rank_12 = class ({})
template_u__sk6_rank_21 = class ({})
template_u__sk6_rank_22 = class ({})
template_u__sk6_rank_31 = class ({})
template_u__sk6_rank_32 = class ({})
template_u__sk6_rank_41 = class ({})
template_u__sk6_rank_42 = class ({})

template__precache = class ({})
LinkLuaModifier("template__special_values", "heroes/template/template__special_values", LUA_MODIFIER_MOTION_NONE)

function template__precache:GetIntrinsicModifierName()
  return "template__special_values"
end

function template__precache:Spawn()
	if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function template__precache:Precache(context)
  --PrecacheResource("soundfile", "soundevents/soundevent_template.vsndevts", context)
end
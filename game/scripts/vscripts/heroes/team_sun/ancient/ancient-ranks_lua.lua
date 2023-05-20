ancient_1__power_rank_11 = class ({})
ancient_1__power_rank_12 = class ({})
ancient_1__power_rank_21 = class ({})
ancient_1__power_rank_22 = class ({})
ancient_1__power_rank_31 = class ({})
ancient_1__power_rank_32 = class ({})
ancient_1__power_rank_41 = class ({})
ancient_1__power_rank_42 = class ({})

ancient_2__leap_rank_11 = class ({})
ancient_2__leap_rank_12 = class ({})
ancient_2__leap_rank_21 = class ({})
ancient_2__leap_rank_22 = class ({})
ancient_2__leap_rank_31 = class ({})
ancient_2__leap_rank_32 = class ({})
ancient_2__leap_rank_41 = class ({})
ancient_2__leap_rank_42 = class ({})

ancient_3__walk_rank_11 = class ({})
ancient_3__walk_rank_12 = class ({})
ancient_3__walk_rank_21 = class ({})
ancient_3__walk_rank_22 = class ({})
ancient_3__walk_rank_31 = class ({})
ancient_3__walk_rank_32 = class ({})
ancient_3__walk_rank_41 = class ({})
ancient_3__walk_rank_42 = class ({})

ancient_4__flesh_rank_11 = class ({})
ancient_4__flesh_rank_12 = class ({})
ancient_4__flesh_rank_21 = class ({})
ancient_4__flesh_rank_22 = class ({})
ancient_4__flesh_rank_31 = class ({})
ancient_4__flesh_rank_32 = class ({})
ancient_4__flesh_rank_41 = class ({})
ancient_4__flesh_rank_42 = class ({})

ancient_5__petrify_rank_11 = class ({})
ancient_5__petrify_rank_12 = class ({})
ancient_5__petrify_rank_21 = class ({})
ancient_5__petrify_rank_22 = class ({})
ancient_5__petrify_rank_31 = class ({})
ancient_5__petrify_rank_32 = class ({})
ancient_5__petrify_rank_41 = class ({})
ancient_5__petrify_rank_42 = class ({})

ancient_u__final_rank_11 = class ({})
ancient_u__final_rank_12 = class ({})
ancient_u__final_rank_21 = class ({})
ancient_u__final_rank_22 = class ({})
ancient_u__final_rank_31 = class ({})
ancient_u__final_rank_32 = class ({})
ancient_u__final_rank_41 = class ({})
ancient_u__final_rank_42 = class ({})

ancient__precache = class ({})
LinkLuaModifier("ancient__special_values", "heroes/team_sun/ancient/ancient__special_values", LUA_MODIFIER_MOTION_NONE)

function ancient__precache:GetIntrinsicModifierName()
  return "ancient__special_values"
end

function ancient__precache:Spawn()
	if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function ancient__precache:Precache(context)
  PrecacheResource("soundfile", "soundevents/soundevent_ancient.vsndevts", context)
end

ancient__jump = class ({})

function ancient__jump:Spawn()
	if self:IsTrained() == false then self:UpgradeAbility(true) end
end
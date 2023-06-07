fleaman_1__precision_rank_11 = class ({})
fleaman_1__precision_rank_12 = class ({})
fleaman_1__precision_rank_21 = class ({})
fleaman_1__precision_rank_22 = class ({})
fleaman_1__precision_rank_31 = class ({})
fleaman_1__precision_rank_32 = class ({})
fleaman_1__precision_rank_41 = class ({})
fleaman_1__precision_rank_42 = class ({})

fleaman_2__speed_rank_11 = class ({})
fleaman_2__speed_rank_12 = class ({})
fleaman_2__speed_rank_21 = class ({})
fleaman_2__speed_rank_22 = class ({})
fleaman_2__speed_rank_31 = class ({})
fleaman_2__speed_rank_32 = class ({})
fleaman_2__speed_rank_41 = class ({})
fleaman_2__speed_rank_42 = class ({})

fleaman_3__jump_rank_11 = class ({})
fleaman_3__jump_rank_12 = class ({})
fleaman_3__jump_rank_21 = class ({})
fleaman_3__jump_rank_22 = class ({})
fleaman_3__jump_rank_31 = class ({})
fleaman_3__jump_rank_32 = class ({})
fleaman_3__jump_rank_41 = class ({})
fleaman_3__jump_rank_42 = class ({})

fleaman_4__strip_rank_11 = class ({})
fleaman_4__strip_rank_12 = class ({})
fleaman_4__strip_rank_21 = class ({})
fleaman_4__strip_rank_22 = class ({})
fleaman_4__strip_rank_31 = class ({})
fleaman_4__strip_rank_32 = class ({})
fleaman_4__strip_rank_41 = class ({})
fleaman_4__strip_rank_42 = class ({})

fleaman_5__steal_rank_11 = class ({})
fleaman_5__steal_rank_12 = class ({})
fleaman_5__steal_rank_21 = class ({})
fleaman_5__steal_rank_22 = class ({})
fleaman_5__steal_rank_31 = class ({})
fleaman_5__steal_rank_32 = class ({})
fleaman_5__steal_rank_41 = class ({})
fleaman_5__steal_rank_42 = class ({})

fleaman_u__smoke_rank_11 = class ({})
fleaman_u__smoke_rank_12 = class ({})
fleaman_u__smoke_rank_21 = class ({})
fleaman_u__smoke_rank_22 = class ({})
fleaman_u__smoke_rank_31 = class ({})
fleaman_u__smoke_rank_32 = class ({})
fleaman_u__smoke_rank_41 = class ({})
fleaman_u__smoke_rank_42 = class ({})

fleaman__precache = class ({})
LinkLuaModifier("fleaman_special_values", "heroes/team_death/fleaman/fleaman-special_values", LUA_MODIFIER_MOTION_NONE)

function fleaman__precache:GetIntrinsicModifierName()
  return "fleaman_special_values"
end

function fleaman__precache:Spawn()
	if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function fleaman__precache:Precache(context)
  PrecacheResource("soundfile", "soundevents/soundevent_fleaman.vsndevts", context)
end
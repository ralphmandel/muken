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

genuine_3__sk3_rank_11 = class ({})
genuine_3__sk3_rank_12 = class ({})
genuine_3__sk3_rank_21 = class ({})
genuine_3__sk3_rank_22 = class ({})
genuine_3__sk3_rank_31 = class ({})
genuine_3__sk3_rank_32 = class ({})
genuine_3__sk3_rank_41 = class ({})
genuine_3__sk3_rank_42 = class ({})

genuine_4__sk4_rank_11 = class ({})
genuine_4__sk4_rank_12 = class ({})
genuine_4__sk4_rank_21 = class ({})
genuine_4__sk4_rank_22 = class ({})
genuine_4__sk4_rank_31 = class ({})
genuine_4__sk4_rank_32 = class ({})
genuine_4__sk4_rank_41 = class ({})
genuine_4__sk4_rank_42 = class ({})

genuine_5__sk5_rank_11 = class ({})
genuine_5__sk5_rank_12 = class ({})
genuine_5__sk5_rank_21 = class ({})
genuine_5__sk5_rank_22 = class ({})
genuine_5__sk5_rank_31 = class ({})
genuine_5__sk5_rank_32 = class ({})
genuine_5__sk5_rank_41 = class ({})
genuine_5__sk5_rank_42 = class ({})

genuine_6__sk6_rank_11 = class ({})
genuine_6__sk6_rank_12 = class ({})
genuine_6__sk6_rank_21 = class ({})
genuine_6__sk6_rank_22 = class ({})
genuine_6__sk6_rank_31 = class ({})
genuine_6__sk6_rank_32 = class ({})
genuine_6__sk6_rank_41 = class ({})
genuine_6__sk6_rank_42 = class ({})

genuine_u__sk7_rank_11 = class ({})
genuine_u__sk7_rank_12 = class ({})
genuine_u__sk7_rank_21 = class ({})
genuine_u__sk7_rank_22 = class ({})
genuine_u__sk7_rank_31 = class ({})
genuine_u__sk7_rank_32 = class ({})
genuine_u__sk7_rank_41 = class ({})
genuine_u__sk7_rank_42 = class ({})

genuine__precache = class ({})

function genuine__precache:Spawn()
    if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function genuine__precache:Precache(context)
    PrecacheResource("soundfile", "soundevents/soundevent_genuine.vsndevts", context)
end
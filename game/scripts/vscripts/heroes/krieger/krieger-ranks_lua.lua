krieger_1__fury_rank_11 = class ({})
krieger_1__fury_rank_12 = class ({})
krieger_1__fury_rank_21 = class ({})
krieger_1__fury_rank_22 = class ({})
krieger_1__fury_rank_31 = class ({})
krieger_1__fury_rank_32 = class ({})
krieger_1__fury_rank_41 = class ({})
krieger_1__fury_rank_42 = class ({})

krieger_2__slash_rank_11 = class ({})
krieger_2__slash_rank_12 = class ({})
krieger_2__slash_rank_21 = class ({})
krieger_2__slash_rank_22 = class ({})
krieger_2__slash_rank_31 = class ({})
krieger_2__slash_rank_32 = class ({})
krieger_2__slash_rank_41 = class ({})
krieger_2__slash_rank_42 = class ({})

krieger_3__rush_rank_11 = class ({})
krieger_3__rush_rank_12 = class ({})
krieger_3__rush_rank_21 = class ({})
krieger_3__rush_rank_22 = class ({})
krieger_3__rush_rank_31 = class ({})
krieger_3__rush_rank_32 = class ({})
krieger_3__rush_rank_41 = class ({})
krieger_3__rush_rank_42 = class ({})

krieger_4__death_rank_11 = class ({})
krieger_4__death_rank_12 = class ({})
krieger_4__death_rank_21 = class ({})
krieger_4__death_rank_22 = class ({})
krieger_4__death_rank_31 = class ({})
krieger_4__death_rank_32 = class ({})
krieger_4__death_rank_41 = class ({})
krieger_4__death_rank_42 = class ({})

krieger_5__sk5_rank_11 = class ({})
krieger_5__sk5_rank_12 = class ({})
krieger_5__sk5_rank_21 = class ({})
krieger_5__sk5_rank_22 = class ({})
krieger_5__sk5_rank_31 = class ({})
krieger_5__sk5_rank_32 = class ({})
krieger_5__sk5_rank_41 = class ({})
krieger_5__sk5_rank_42 = class ({})

krieger_6__sk6_rank_11 = class ({})
krieger_6__sk6_rank_12 = class ({})
krieger_6__sk6_rank_21 = class ({})
krieger_6__sk6_rank_22 = class ({})
krieger_6__sk6_rank_31 = class ({})
krieger_6__sk6_rank_32 = class ({})
krieger_6__sk6_rank_41 = class ({})
krieger_6__sk6_rank_42 = class ({})

krieger_u__rage_rank_11 = class ({})
krieger_u__rage_rank_12 = class ({})
krieger_u__rage_rank_21 = class ({})
krieger_u__rage_rank_22 = class ({})
krieger_u__rage_rank_31 = class ({})
krieger_u__rage_rank_32 = class ({})
krieger_u__rage_rank_41 = class ({})
krieger_u__rage_rank_42 = class ({})

krieger__precache = class ({})

function krieger__precache:Spawn()
    if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function krieger__precache:Precache(context)
    PrecacheResource("soundfile", "soundevents/soundevent_krieger.vsndevts", context)
end
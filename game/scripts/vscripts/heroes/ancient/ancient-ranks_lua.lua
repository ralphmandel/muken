ancient_1__berserk_rank_11 = class ({})
ancient_1__berserk_rank_12 = class ({})
ancient_1__berserk_rank_21 = class ({})
ancient_1__berserk_rank_22 = class ({})
ancient_1__berserk_rank_31 = class ({})
ancient_1__berserk_rank_32 = class ({})
ancient_1__berserk_rank_41 = class ({})
ancient_1__berserk_rank_42 = class ({})

ancient_2__bash_rank_11 = class ({})
ancient_2__bash_rank_12 = class ({})
ancient_2__bash_rank_21 = class ({})
ancient_2__bash_rank_22 = class ({})
ancient_2__bash_rank_31 = class ({})
ancient_2__bash_rank_32 = class ({})
ancient_2__bash_rank_41 = class ({})
ancient_2__bash_rank_42 = class ({})

ancient_3__leap_rank_11 = class ({})
ancient_3__leap_rank_12 = class ({})
ancient_3__leap_rank_21 = class ({})
ancient_3__leap_rank_22 = class ({})
ancient_3__leap_rank_31 = class ({})
ancient_3__leap_rank_32 = class ({})
ancient_3__leap_rank_41 = class ({})
ancient_3__leap_rank_42 = class ({})

ancient_4__walk_rank_11 = class ({})
ancient_4__walk_rank_12 = class ({})
ancient_4__walk_rank_21 = class ({})
ancient_4__walk_rank_22 = class ({})
ancient_4__walk_rank_31 = class ({})
ancient_4__walk_rank_32 = class ({})
ancient_4__walk_rank_41 = class ({})
ancient_4__walk_rank_42 = class ({})

ancient_5__stone_rank_11 = class ({})
ancient_5__stone_rank_12 = class ({})
ancient_5__stone_rank_21 = class ({})
ancient_5__stone_rank_22 = class ({})
ancient_5__stone_rank_31 = class ({})
ancient_5__stone_rank_32 = class ({})
ancient_5__stone_rank_41 = class ({})
ancient_5__stone_rank_42 = class ({})

ancient_6__sk6_rank_11 = class ({})
ancient_6__sk6_rank_12 = class ({})
ancient_6__sk6_rank_21 = class ({})
ancient_6__sk6_rank_22 = class ({})
ancient_6__sk6_rank_31 = class ({})
ancient_6__sk6_rank_32 = class ({})
ancient_6__sk6_rank_41 = class ({})
ancient_6__sk6_rank_42 = class ({})

ancient_u__final_rank_11 = class ({})
ancient_u__final_rank_12 = class ({})
ancient_u__final_rank_21 = class ({})
ancient_u__final_rank_22 = class ({})
ancient_u__final_rank_31 = class ({})
ancient_u__final_rank_32 = class ({})
ancient_u__final_rank_41 = class ({})
ancient_u__final_rank_42 = class ({})

ancient__precache = class ({})

function ancient__precache:Spawn()
    if self:IsTrained() == false then self:UpgradeAbility(true) end
end

function ancient__precache:Precache(context)
    PrecacheResource("soundfile", "soundevents/soundevent_ancient.vsndevts", context)
end
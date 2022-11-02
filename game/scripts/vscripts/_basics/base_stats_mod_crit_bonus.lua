base_stats_mod_crit_bonus = class({})

function base_stats_mod_crit_bonus:IsPurgable()
	return false
end

function base_stats_mod_crit_bonus:IsHidden()
	return true
end

function base_stats_mod_crit_bonus:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function base_stats_mod_crit_bonus:OnCreated( kv )
	if IsServer() then
		self.crit_damage = kv.crit_damage
	end
end

function base_stats_mod_crit_bonus:OnRemoved()
end

function base_stats_mod_crit_bonus:OnDestroy()
end
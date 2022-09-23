base_stats_mod_block_bonus = class({})

function base_stats_mod_block_bonus:IsPurgable()
	return false
end

function base_stats_mod_block_bonus:IsHidden()
	return true
end

function base_stats_mod_block_bonus:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function base_stats_mod_block_bonus:OnCreated( kv )
	if IsServer() then
		self.physical_block_max_percent = kv.physical_block_max_percent or 0
		self.physical_block_min_percent = kv.physical_block_min_percent or 0
		self.physical_block_max_const = kv.physical_block_max_const or 0
		self.physical_block_min_const = kv.physical_block_min_const or 0
		
		self.magical_block_max_percent = kv.magical_block_max_percent or 0
		self.magical_block_min_percent = kv.magical_block_min_percent or 0
		self.magical_block_max_const = kv.magical_block_max_const or 0
		self.magical_block_min_const = kv.magical_block_min_const or 0
	end
end

function base_stats_mod_block_bonus:OnRemoved()
end

function base_stats_mod_block_bonus:OnDestroy()
end
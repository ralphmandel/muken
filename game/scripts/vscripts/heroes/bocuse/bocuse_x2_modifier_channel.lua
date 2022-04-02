bocuse_x2_modifier_channel = class ({})

function bocuse_x2_modifier_channel:IsHidden()
    return true
end

function bocuse_x2_modifier_channel:IsPurgable()
    return false
end

function bocuse_x2_modifier_channel:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

-----------------------------------------------------------

function bocuse_x2_modifier_channel:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self:PlayEfxStart()
end

function bocuse_x2_modifier_channel:OnRefresh(kv)
end

function bocuse_x2_modifier_channel:OnRemoved()
	if IsServer() then
		self.parent:StopSound("DOTA_Item.Cheese.Activate")
		self.parent:StopSound("DOTA_Item.RepairKit.Target")
	end
end

------------------------------------------------------------

function bocuse_x2_modifier_channel:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true
	}

	return state
end

function bocuse_x2_modifier_channel:DeclareFunctions()
    local decFuncs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return decFuncs
end

function bocuse_x2_modifier_channel:OnTakeDamage(keys)
	-- if not (keys.unit == self.parent) then return end
	--if keys.attacker:IsBaseNPC() == false then return end
	-- if keys.attacker:GetTeamNumber() == self.parent:GetTeamNumber() then return end

	-- self.parent:InterruptChannel()
end

-----------------------------------------------------------

function bocuse_x2_modifier_channel:GetEffectName()
	return "particles/econ/items/meepo/meepo_colossal_crystal_chorus/meepo_divining_rod_poof_start.vpcf"
end

function bocuse_x2_modifier_channel:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function bocuse_x2_modifier_channel:PlayEfxStart()
	if IsServer() then
		self.parent:EmitSound("DOTA_Item.Cheese.Activate")
		self.parent:EmitSound("DOTA_Item.RepairKit.Target")
	end
end
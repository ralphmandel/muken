ancient_3_modifier_aura_effect = class({})

function ancient_3_modifier_aura_effect:IsHidden()
	if self:GetParent() == self:GetCaster() then
		return true
	else
		return false
	end
end

function ancient_3_modifier_aura_effect:IsPurgable()
	return false
end

function ancient_3_modifier_aura_effect:IsDebuff()
	if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
		return true
	end
end

function ancient_3_modifier_aura_effect:GetPriority()
	if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
		return MODIFIER_PRIORITY_ULTRA
	end
end

-----------------------------------------------------------

function ancient_3_modifier_aura_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.slow = self.ability:GetSpecialValueFor("slow")

	-- UP 3.12
	if self.ability:GetRank(12) then
		self.slow = self.slow - 25
	end

	-- UP 3.23
	if self.ability:GetRank(23) then
		if self.parent:GetTeamNumber() ~= self.caster:GetTeamNumber() then
			self.ability:AddBonus("_1_AGI", self.parent, -15, 0, nil)
		end
	end

	self.ability:CheckEnemies()
end

function ancient_3_modifier_aura_effect:OnRefresh(kv)
end

function ancient_3_modifier_aura_effect:OnRemoved()
	self.ability:RemoveBonus("_1_AGI", self.parent)
	self.ability:CheckEnemies()
end

-----------------------------------------------------------

function ancient_3_modifier_aura_effect:CheckState()
	local state = {}

	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber()
	and self:GetParent() ~= self:GetCaster() then
		state = {
			[MODIFIER_STATE_MAGIC_IMMUNE] = true
		}
	end

	return state
end

function ancient_3_modifier_aura_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_LIMIT
	}

	return funcs
end

function ancient_3_modifier_aura_effect:GetModifierMoveSpeed_Limit()
	if self:GetParent():GetTeamNumber() ~= self:GetCaster():GetTeamNumber() then
		return self.slow
	end
end

-----------------------------------------------------------

function ancient_3_modifier_aura_effect:GetEffectName()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		if self:GetParent() ~= self:GetCaster() then
			return "particles/items_fx/black_king_bar_avatar.vpcf"
		end
	else
		return "particles/units/heroes/hero_omniknight/omniknight_shard_hammer_of_purity_overhead_debuff.vpcf"
	end
end

function ancient_3_modifier_aura_effect:GetEffectAttachType()
	if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		if self:GetParent() ~= self:GetCaster() then
			return PATTACH_ABSORIGIN_FOLLOW
		end
	else
		return PATTACH_OVERHEAD_FOLLOW
	end
end
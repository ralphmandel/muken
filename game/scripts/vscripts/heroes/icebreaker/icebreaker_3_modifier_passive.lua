icebreaker_3_modifier_passive = class({})

function icebreaker_3_modifier_passive:IsHidden()
	return false
end

function icebreaker_3_modifier_passive:IsPurgable()
	return false
end

function icebreaker_3_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_3_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.creep_hit = 3
	self.max_layer = self.ability:GetSpecialValueFor("max_layer")
	self.ability.def_layer = self.ability:GetSpecialValueFor("def_layer")

	-- UP 3.21
	if self.ability:GetRank(21) then
		self.ability.def_layer = self.ability.def_layer + 1
	end

	if IsServer() then
		self:SetStackCount(self.max_layer)
	end
end

function icebreaker_3_modifier_passive:OnRefresh(kv)
end

function icebreaker_3_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_3_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function icebreaker_3_modifier_passive:OnAttackLanded(keys)
	if keys.target ~= self.parent then return end

	if keys.attacker:IsHero() and keys.attacker:IsIllusion() == false then
		self:DecrementLayer(keys.attacker)
	else
		self.creep_hit = self.creep_hit - 1
		if self.creep_hit < 1 then
			self:DecrementLayer(keys.attacker)
		end
	end
end

function icebreaker_3_modifier_passive:OnIntervalThink()
	if IsServer() then
		if self:GetStackCount() > 0
		and self:GetStackCount() < self.max_layer then
			self:SetStackCount(self.max_layer)
		end

		self:StartIntervalThink(-1)
	end
end

function icebreaker_3_modifier_passive:OnStackCountChanged(old)
	if self:GetStackCount() < 0 then self:SetStackCount(0) end
	if self:GetStackCount() > self.max_layer then self:SetStackCount(self.max_layer) end

	self:UpdateBonusLayer()
	self.ability:SetActivated(self:GetStackCount() < 1)
end

-- UTILS -----------------------------------------------------------

function icebreaker_3_modifier_passive:UpdateBonusLayer()
	self.ability:RemoveBonus("_2_DEF", self.parent)
	self.ability:AddBonus("_2_DEF", self.parent, self:GetStackCount() * self.ability.def_layer, 0, nil)
end

function icebreaker_3_modifier_passive:DecrementLayer(target)
	if self:GetStackCount() == 0 then return end

	local delay_layer = self.ability:GetSpecialValueFor("delay_layer")
	self:DecrementStackCount()
	self.creep_hit = 3

	-- UP 3.31
	if self.ability:GetRank(31) then
		self:AddFrost(target, self.parent:IsIllusion())
	end

	if IsServer() then self:StartIntervalThink(delay_layer) end
end

function icebreaker_3_modifier_passive:AddFrost(target, bIllusion)
	if bIllusion then return end
	if target:IsMagicImmune() then return end
	if target:HasModifier("icebreaker_1_modifier_frozen") then return end
	if self.parent:PassivesDisabled() then return end

	local hypo = self.parent:FindAbilityByName("icebreaker_1__hypo")
	if hypo == nil then return end
	if hypo:IsTrained() == false then return end

	local chance = 20
	local base_stats = self.parent:FindAbilityByName("base_stats")
	if base_stats then chance = chance * base_stats:GetCriticalChance() end
	
	if RandomFloat(1, 100) <= chance then
		target:AddNewModifier(self.caster, self.ability, "icebreaker_1_modifier_instant", {duration = 0.5})
		hypo:AddSlow(target, hypo, 1, true)
	end
end

-- EFFECTS -----------------------------------------------------------
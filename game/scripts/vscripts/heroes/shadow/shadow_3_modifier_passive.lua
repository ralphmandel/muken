shadow_3_modifier_passive = class({})

function shadow_3_modifier_passive:IsHidden()
	return true
end

function shadow_3_modifier_passive:IsPurgable()
	return false
end

-----------------------------------------------------------

function shadow_3_modifier_passive:OnCreated(kv)
	self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.move = false

	if IsServer() then
		self.ability:StartRechargeTime()
		self:OnIntervalThink(FrameTime())
	end
end

function shadow_3_modifier_passive:OnRefresh(kv)
end

function shadow_3_modifier_passive:OnRemoved()
end

-----------------------------------------------------------

function shadow_3_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

-----------------------------------------------------------

function shadow_3_modifier_passive:OnAttackLanded(keys)
	if self.parent ~= keys.attacker and self.parent ~= keys.target then return end

	-- UP 3.22
	if self.ability:GetRank(22)
	and RandomInt(1, 100) <= 15
	and self.parent == keys.attacker then
		self.ability:CreateShadow(keys.target, 5, 1)
	end

	self.ability:StartRechargeTime()
end

function shadow_3_modifier_passive:OnIntervalThink()
	-- UP 3.12
	if self.ability:GetRank(12) == false then
		self:StartIntervalThink(FrameTime())
		return
	end

	if self.parent:IsMoving() then
		if self.move == false then
			self.move = true
			self.ability:AddBonus("_2_DEX", self.parent, 15, 0, nil)
		end
	else
		if self.move == true then
			self.move = false
			self.ability:RemoveBonus("_2_DEX", self.parent)
		end
	end

	self:StartIntervalThink(FrameTime())
end
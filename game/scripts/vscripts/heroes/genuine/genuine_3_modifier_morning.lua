genuine_3_modifier_morning = class({})

function genuine_3_modifier_morning:IsHidden()
	return false
end

function genuine_3_modifier_morning:IsPurgable()
	return true
end

-----------------------------------------------------------

function genuine_3_modifier_morning:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	-- UP 3.11
	if self.ability:GetRank(11) then
		self.parent:Purge(false, true, false, true, false)
	end

	local agi_bonus = self.ability:GetSpecialValueFor("agi_bonus")
	local rec_bonus = self.ability:GetSpecialValueFor("rec_bonus")

	-- UP 3.21
	if self.ability:GetRank(21) then
		agi_bonus = agi_bonus + 5
		rec_bonus = rec_bonus + 10
	end

	-- UP 3.22
	if self.ability:GetRank(22) then
		self.ability:AddBonus("_1_INT", self.parent, 15, 0, nil)
	end

	self.ability:AddBonus("_1_AGI", self.parent, agi_bonus, 0, nil)
	self.ability:AddBonus("_2_REC", self.parent, rec_bonus, 0, nil)

	self.ability:EndCooldown()
	self.ability:SetActivated(false)
end

function genuine_3_modifier_morning:OnRefresh(kv)
end

function genuine_3_modifier_morning:OnRemoved(kv)
	self.ability:RemoveBonus("_1_INT", self.parent)
	self.ability:RemoveBonus("_1_AGI", self.parent)
	self.ability:RemoveBonus("_2_REC", self.parent)

	local passive = self.caster:FindModifierByName("genuine_3_modifier_passive")
	if passive then passive:StopEfxBuff() end

	self.ability:SetActivated(true)
	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
end

-----------------------------------------------------------
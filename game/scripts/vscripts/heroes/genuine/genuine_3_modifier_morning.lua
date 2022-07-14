genuine_3_modifier_morning = class({})

function genuine_3_modifier_morning:IsHidden()
	return false
end

function genuine_3_modifier_morning:IsPurgable()
	return self.purge
end

-----------------------------------------------------------

function genuine_3_modifier_morning:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local agi_bonus = self.ability:GetSpecialValueFor("agi_bonus")
	local rec_bonus = self.ability:GetSpecialValueFor("rec_bonus")

	self.ability:AddBonus("_1_AGI", self.parent, agi_bonus, 0, nil)
	self.ability:AddBonus("_2_REC", self.parent, rec_bonus, 0, nil)

	self.purge = true

	-- UP 3.11
	if self.ability:GetRank(11) then
		self.parent:Purge(false, true, false, true, false)
	end

	-- UP 3.12
	if self.ability:GetRank(12) then
		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {percent = 15})
	end

	-- UP 3.41
	if self.ability:GetRank(41)
	and GameRules:IsDaytime() == false then
		self.purge = false
	end

	self.ability:EndCooldown()
	self.ability:SetActivated(false)
end

function genuine_3_modifier_morning:OnRefresh(kv)
end

function genuine_3_modifier_morning:OnRemoved(kv)
	self.ability:RemoveBonus("_1_AGI", self.parent)
	self.ability:RemoveBonus("_2_REC", self.parent)

	local passive = self.caster:FindModifierByName("genuine_3_modifier_passive")
	if passive then passive:StopEfxBuff() end

	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_buff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	self.ability:SetActivated(true)
	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
end

-----------------------------------------------------------
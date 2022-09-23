item_rare_killer_dagger_mod_passive = class({})

function item_rare_killer_dagger_mod_passive:IsHidden()
    return true
end

function item_rare_killer_dagger_mod_passive:IsPurgable()
    return false
end

---------------------------------------------------------------------------------------------------

function item_rare_killer_dagger_mod_passive:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local passive_lck = self.ability:GetSpecialValueFor("passive_lck")
	local passive_str = self.ability:GetSpecialValueFor("passive_str")
	self.passive_agi = self.ability:GetSpecialValueFor("passive_agi")
	self.chance = self.ability:GetSpecialValueFor("chance")
	self.hits = 0

	self.ability:AddBonus("_2_LCK", self.parent, passive_lck, 0, nil)
	self.ability:AddBonus("_1_STR", self.parent, passive_str, 0, nil)
	self.ability:AddBonus("_1_AGI", self.parent, self.passive_agi, 0, nil)

	self.aspd = self.ability:GetSpecialValueFor("aspd")
end

function item_rare_killer_dagger_mod_passive:OnRefresh( kv )
end

function item_rare_killer_dagger_mod_passive:OnRemoved( kv )
	self.ability:RemoveBonus("_2_LCK", self.parent)
	self.ability:RemoveBonus("_1_STR", self.parent)
	self.ability:RemoveBonus("_1_AGI", self.parent)
end

-----------------------------------------------------------------------------

function item_rare_killer_dagger_mod_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK
	}
	
	return funcs
end

function item_rare_killer_dagger_mod_passive:OnAttack(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end

	local ancient_mod = self.parent:FindModifierByName("ancient_1_modifier_passive")
	if ancient_mod then
		-- if RandomFloat(1, 100) <= self.chance then
		-- 	ancient_mod:SetMultipleHits(2)
		-- end
		return
	end

	if self.hits > 0 then
		self.hits = self.hits - 1
	end
	
	if self.hits < 1 then
		self.ability:RemoveBonus("_1_AGI", self.parent)
		self.ability:AddBonus("_1_AGI", self.parent, self.passive_agi, 0, nil)
		self:StartIntervalThink(-1)
		self:StartIntervalThink(2)
	end

	if RandomFloat(1, 100) <= self.chance then
		self.ability:RemoveBonus("_1_AGI", self.parent)
		self.ability:AddBonus("_1_AGI", self.parent, 999, 0, nil)
		self.hits = 1
	end
end

function item_rare_killer_dagger_mod_passive:OnIntervalThink()
	if self.hits > 0 then self.hits = 0 end
	self:StartIntervalThink(-1)
end
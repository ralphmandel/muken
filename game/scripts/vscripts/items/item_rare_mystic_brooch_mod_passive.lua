item_rare_mystic_brooch_mod_passive = class({})

function item_rare_mystic_brooch_mod_passive:IsHidden()
    return true
end

function item_rare_mystic_brooch_mod_passive:IsPurgable()
    return false
end

---------------------------------------------------------------------------------------------------

function item_rare_mystic_brooch_mod_passive:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local passive_con = self.ability:GetSpecialValueFor("passive_con")
	local passive_mnd = self.ability:GetSpecialValueFor("passive_mnd")

	self.ability:AddBonus("_1_CON", self.parent, passive_con, 0, nil)
	self.ability:AddBonus("_2_MND", self.parent, passive_mnd, 0, nil)
end

function item_rare_mystic_brooch_mod_passive:OnRefresh( kv )
end

function item_rare_mystic_brooch_mod_passive:OnRemoved( kv )
	self.ability:RemoveBonus("_1_CON", self.parent)
	self.ability:RemoveBonus("_2_MND", self.parent)
end

---------------------------------------------------------------------------------------------------

function item_rare_mystic_brooch_mod_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function item_rare_mystic_brooch_mod_passive:OnAttackLanded(keys)
	if keys.target ~= self.parent then return end
	if self.ability:IsCooldownReady() == false then return end

	local heal = self.ability:GetSpecialValueFor("heal")
	local total_heal = self.parent:GetMaxHealth() * heal * 0.01

    local base_stats = self.caster:FindAbilityByName("base_stats")
	if base_stats then total_heal = total_heal * base_stats:GetHealPower() end

    self.parent:Heal(total_heal, self.ability)
	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
end
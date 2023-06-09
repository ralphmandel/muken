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

	AddBonus(self.ability, "_1_CON", self.parent, passive_con, 0, nil)
	AddBonus(self.ability, "_2_MND", self.parent, passive_mnd, 0, nil)
end

function item_rare_mystic_brooch_mod_passive:OnRefresh( kv )
end

function item_rare_mystic_brooch_mod_passive:OnRemoved( kv )
	RemoveBonus(self.ability, "_1_CON", self.parent)
	RemoveBonus(self.ability, "_2_MND", self.parent)
end

---------------------------------------------------------------------------------------------------

function item_rare_mystic_brooch_mod_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACKED
	}

	return funcs
end

function item_rare_mystic_brooch_mod_passive:OnAttacked(keys)
	if keys.target ~= self.parent then return end
	if self.ability:IsCooldownReady() == false then return end

	local heal = self.ability:GetSpecialValueFor("heal")
	local total_heal = self.parent:GetMaxHealth() * heal * 0.01 * BaseStats(self.caster):GetHealPower()

  self.parent:Heal(total_heal, self.ability)
	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
end
druid_3_modifier_totem_effect = class({})

function druid_3_modifier_totem_effect:IsHidden()
	if self:GetParent():GetUnitName() == "druid_totem" then return true end
	return false
end

function druid_3_modifier_totem_effect:IsPurgable()
	return false
end

-----------------------------------------------------------

function druid_3_modifier_totem_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if self.parent:GetUnitName() == "druid_totem" then return end

	local bonus = self.ability:GetSpecialValueFor("bonus")
	self.resist_creature = bonus

	self.ability:AddBonus("_2_RES", self.parent, bonus, 0, nil)
	self.ability:AddBonus("_2_MND", self.parent, bonus, 0, nil)
end

function druid_3_modifier_totem_effect:OnRefresh(kv)
end

function druid_3_modifier_totem_effect:OnRemoved(kv)
	self.ability:RemoveBonus("_2_RES", self.parent)
	self.ability:RemoveBonus("_2_MND", self.parent)
end

-----------------------------------------------------------

-- function druid_3_modifier_totem_effect:CheckState()
-- 	local state = {}
	
-- 	if self.break_passive == true then
-- 		state = {
-- 			[MODIFIER_STATE_PASSIVES_DISABLED] = true,
-- 		}
-- 	end

-- 	return state
-- end

function druid_3_modifier_totem_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS 
	}

	return funcs
end

function druid_3_modifier_totem_effect:DeclareFunctions()
	if self:GetParent():IsHero() == false then
		return self.resist_creature
	end

	return 0
end

-----------------------------------------------------------
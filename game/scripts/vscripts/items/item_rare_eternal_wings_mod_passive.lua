item_rare_eternal_wings_mod_passive = class({})

function item_rare_eternal_wings_mod_passive:IsHidden()
    return true
end

function item_rare_eternal_wings_mod_passive:IsPurgable()
    return false
end

---------------------------------------------------------------------------------------------------

function item_rare_eternal_wings_mod_passive:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local passive_rec = self.ability:GetSpecialValueFor("passive_rec")
	self.wings_duration = self.ability:GetSpecialValueFor("wings_duration")
	self.manacost = self.ability:GetSpecialValueFor("manacost")

	self.ability:AddBonus("_2_REC", self.parent, passive_rec, 0, nil)
end

function item_rare_eternal_wings_mod_passive:OnRefresh( kv )
end

function item_rare_eternal_wings_mod_passive:OnRemoved( kv )
	self.ability:RemoveBonus("_2_REC", self.parent)
end


--------------------------------------------------------------------------------------------------

function item_rare_eternal_wings_mod_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}

	return funcs
end

function item_rare_eternal_wings_mod_passive:GetModifierPercentageManacost(keys)
	if self.ability:IsCooldownReady() then return self.manacost end
	return 0
end

function item_rare_eternal_wings_mod_passive:OnAbilityFullyCast(keys)
	if keys.unit ~= self.parent then return end
	if keys.ability:IsItem() then return end
	if self.ability:IsCooldownReady() == false then return end

	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
	self.parent:AddNewModifier(self.caster, self.ability, "item_rare_eternal_wings_mod_buff", {
		duration = self.ability:CalcStatus(self.wings_duration, self.caster, self.parent)
	})
end

--------------------------------------------------------------------------------------------------

-- function item_rare_eternal_wings_mod_passive:GetEffectName()
-- 	return "particles/items_fx/aura_shivas.vpcf"
-- end

-- function item_rare_eternal_wings_mod_passive:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end
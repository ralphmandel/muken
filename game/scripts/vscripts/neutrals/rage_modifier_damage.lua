rage_modifier_damage = class({})
local tempTable = require("libraries/tempTable")

function rage_modifier_damage:IsHidden()
	return false
end

function rage_modifier_damage:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function rage_modifier_damage:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.damage_bonus = self.ability:GetSpecialValueFor( "damage_bonus" )
	self.damage_duration = self.ability:GetSpecialValueFor( "damage_duration" )

	self:SetStackCount(1)

    if IsServer() then
        -- add stack modifier
		local this = tempTable:AddATValue( self )
		self.parent:AddNewModifier(
			self.caster, -- player source
			self.ability, -- ability source
			"rage_modifier_damage_stack", -- modifier name
			{
				duration = self.damage_duration,
				modifier = this,
			} -- kv
		)
    end
end

function rage_modifier_damage:OnRefresh( kv )
	if IsServer() then
		-- add stack
		local this = tempTable:AddATValue( self )
		self.parent:AddNewModifier(
			self.caster, -- player source
			self.ability, -- ability source
			"rage_modifier_damage_stack", -- modifier name
			{
				duration = self.damage_duration,
				modifier = this,
			} -- kv
		)
		
		-- increment stack
		self:IncrementStackCount()
	end
end

function rage_modifier_damage:OnRemoved()
end

--------------------------------------------------------------------------------

function rage_modifier_damage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
	}

	return funcs
end

function rage_modifier_damage:GetModifierBaseAttack_BonusDamage()
	return self:GetStackCount() * self.damage_bonus
end

function rage_modifier_damage:OnStackCountChanged(old)
	if self:GetStackCount() == 0 then
		self:Destroy()
	end
end
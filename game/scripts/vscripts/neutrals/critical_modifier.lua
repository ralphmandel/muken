critical_modifier = class({})

function critical_modifier:IsHidden()
	return false
end

function critical_modifier:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function critical_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.crit_chance = self.ability:GetSpecialValueFor( "crit_chance" )
	self.crit_bonus = self.ability:GetSpecialValueFor( "crit_bonus" )
end

function critical_modifier:OnRefresh( kv )
	self.crit_chance = self.ability:GetSpecialValueFor( "crit_chance" )
	self.crit_bonus = self.ability:GetSpecialValueFor( "crit_bonus" )
end

function critical_modifier:OnRemoved()
end

--------------------------------------------------------------------------------

function critical_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}

	return funcs
end

function critical_modifier:GetModifierPreAttack_CriticalStrike( params )
	if (not self.parent:PassivesDisabled()) then
		if self:RollChance( self.crit_chance ) then
			self.record = params.record
			return self.crit_bonus
		end
	end
end

function critical_modifier:GetModifierProcAttack_Feedback( params )
	if self.record then
		self.record = nil
		self:PlayEffects( params.target )
	end
end

function critical_modifier:RollChance( chance )
	local rand = math.random()
	if rand<chance/100 then
		return true
	end
	return false
end

--------------------------------------------------------------------------------

function critical_modifier:PlayEffects(target)
	if IsServer() then target:EmitSound("DOTA_Item.Daedelus.Crit") end
end
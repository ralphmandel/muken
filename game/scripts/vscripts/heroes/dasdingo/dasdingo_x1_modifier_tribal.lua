dasdingo_x1_modifier_tribal = class({})

function dasdingo_x1_modifier_tribal:IsHidden()
	return false
end

function dasdingo_x1_modifier_tribal:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function dasdingo_x1_modifier_tribal:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local levels = 0
	local int = self.caster:FindModifierByName("_1_INT_modifier")
	if int then self.parent:CreatureLevelUp(int:GetStackCount()) end

	self.parent:StartGesture(ACT_IDLE)
	self:PlayEfxRegen()
end

function dasdingo_x1_modifier_tribal:OnRefresh( kv )
end

function dasdingo_x1_modifier_tribal:OnRemoved()
	if IsValidEntity(self.parent) then
		if self.parent:IsAlive() then
			self.parent:Kill(self.ability, nil)
		end
	end
end

--------------------------------------------------------------------------------

function dasdingo_x1_modifier_tribal:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}

	return state
end

function dasdingo_x1_modifier_tribal:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		MODIFIER_PROPERTY_AVOID_DAMAGE,
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}
	return funcs
end

function dasdingo_x1_modifier_tribal:GetModifierAttackSpeedPercentage()
	return 75
end

function dasdingo_x1_modifier_tribal:GetModifierAvoidDamage()
	return 1
end

function dasdingo_x1_modifier_tribal:GetDisableHealing()
	return 1
end

function dasdingo_x1_modifier_tribal:OnAttack(keys)
	if keys.attacker == self.parent then
		if IsServer() then self.parent:EmitSound("Hero_WitchDoctor_Ward.Attack") end
	end
end

function dasdingo_x1_modifier_tribal:OnAttackLanded(keys)
	if keys.attacker == self.parent then
		if IsServer() then self.parent:EmitSound("Hero_WitchDoctor_Ward.ProjectileImpact") end
	end
end

function dasdingo_x1_modifier_tribal:GetModifierIncomingDamage_Percentage(keys)
	if keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
		local value = self.parent:GetHealth() - 1
		self.parent:ModifyHealth(value, self.ability, true, 0)		
	end
end

function dasdingo_x1_modifier_tribal:GetAttackSound(keys)
    return ""
end

--------------------------------------------------------------------------------

function dasdingo_x1_modifier_tribal:GetEffectName()
	return "particles/econ/items/witch_doctor/wd_2021_cache/wd_2021_cache_death_ward.vpcf"
end

function dasdingo_x1_modifier_tribal:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function dasdingo_x1_modifier_tribal:PlayEfxRegen()
	local string = "particles/econ/items/juggernaut/jugg_fortunes_tout/jugg_healling_ward_fortunes_tout_hero_heal.vpcf"
	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
    ParticleManager:SetParticleControl(effect_cast, 2, self.parent:GetOrigin())
	self:AddParticle(effect_cast, false, false, -1, false, false)
end
shadow_3_modifier_invisible = class({})

function shadow_3_modifier_invisible:IsHidden()
	return false
end

function shadow_3_modifier_invisible:IsPurgable()
	return true
end

-------------------------------------------------------------

function shadow_3_modifier_invisible:OnCreated( kv )
	self.caster = self:GetCaster()
    self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.invi_hits = 7
	self.truesight = false

	if IsServer() then
		self:SetStackCount(self.invi_hits)
		self:PlayEfxStart()
	end
end

function shadow_3_modifier_invisible:OnRefresh( kv )
	self.invi_hits = 7

	if IsServer() then
		self:SetStackCount(self.invi_hits)
		self:PlayEfxStart()
	end
end

function shadow_3_modifier_invisible:OnRemoved( kv )
	if IsServer() then self.parent:EmitSound("Hero_PhantomAssassin.Blur.Break") end
end

-------------------------------------------------------------

function shadow_3_modifier_invisible:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_TRUESIGHT_IMMUNE] = self.truesight,
	}

	return state
end

function shadow_3_modifier_invisible:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_PROPERTY_OVERRIDE_ATTACK_DAMAGE,
		MODIFIER_EVENT_ON_ATTACKED
	}

	return funcs
end

function shadow_3_modifier_invisible:GetModifierInvisibilityLevel()
	return 2
end

function shadow_3_modifier_invisible:GetModifierOverrideAttackDamage()
	return 1
end

function shadow_3_modifier_invisible:OnAttacked(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:HasModifier("shadow_0_modifier_poison") then
		self:SetDuration(self:GetRemainingTime() + 1, true)

		self.invi_hits = self.invi_hits - 1
		if self.invi_hits < 1 then self:Destroy() return end

		self.truesight = true
		self:SetStackCount(self.invi_hits)
		self:StartIntervalThink(1)
	else
		self:Destroy()
	end
end

function shadow_3_modifier_invisible:OnIntervalThink()
	self.truesight = false
	self:StartIntervalThink(-1)
end

--------------------------------------------------------------------------------

function shadow_3_modifier_invisible:PlayEfxStart()
	local particle_cast = "particles/econ/items/gyrocopter/gyro_ti10_immortal_missile/gyro_ti10_immortal_missile_explosion.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetParent():GetOrigin() )
	self:AddParticle(effect_cast, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_PhantomAssassin.Blur") end
end
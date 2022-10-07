bloodstained__modifier_bleeding = class({})

function bloodstained__modifier_bleeding:IsHidden()
	return false
end

function bloodstained__modifier_bleeding:IsPurgable()
	return true
end

function bloodstained__modifier_bleeding:IsDebuff()
	return true
end

function bloodstained__modifier_bleeding:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained__modifier_bleeding:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.intervals = 0.2

	self.damageTable = {
		victim = self.parent,
		attacker = self.caster,
		damage = 100 * self.intervals,
		damage_type = DAMAGE_TYPE_PURE,
		ability = self.ability
	}

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "bloodstained__modifier_bleeding_status_efx", true) end

	if IsServer() then
		self:StartIntervalThink(self.intervals)
		self:PlayEfxStart()
	end
end

function bloodstained__modifier_bleeding:OnRefresh(kv)
end

function bloodstained__modifier_bleeding:OnRemoved()
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "bloodstained__modifier_bleeding_status_efx", false) end
end

-- API FUNCTIONS -----------------------------------------------------------

function bloodstained__modifier_bleeding:OnIntervalThink()
	if IsServer() then
		if self.parent:IsMoving() then
			local apply_damage = math.floor(ApplyDamage(self.damageTable))
			if apply_damage > 0 then self:PopupBleeding(apply_damage) end
		end

		self:StartIntervalThink(self.intervals)
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bloodstained__modifier_bleeding:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end

function bloodstained__modifier_bleeding:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function bloodstained__modifier_bleeding:GetStatusEffectName()
    return "particles/status_fx/status_effect_rupture.vpcf"
end

function bloodstained__modifier_bleeding:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function bloodstained__modifier_bleeding:PopupBleeding(amount)
    local digits = 1 + #tostring(amount)
	local pidx = ParticleManager:CreateParticle("particles/bocuse/bocuse_msg.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(pidx, 3, Vector(0, tonumber(amount), 3))
    ParticleManager:SetParticleControl(pidx, 4, Vector(1, digits, 0))
end

function bloodstained__modifier_bleeding:PlayEfxStart()
	local particle_cast = "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_impact.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)

	local particle_cast2 = "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok.vpcf"
	local effect_cast2 = ParticleManager:CreateParticle(particle_cast2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast2, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast2, 1, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast2)

	if IsServer() then
		self.parent:EmitSound("hero_bloodseeker.bloodRite.silence")
		self.parent:EmitSound("Hero_Bloodstained.Bleed")
	end
end
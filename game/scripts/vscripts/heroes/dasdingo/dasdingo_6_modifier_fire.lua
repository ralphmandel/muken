dasdingo_6_modifier_fire = class({})

function dasdingo_6_modifier_fire:IsHidden()
	return false
end

function dasdingo_6_modifier_fire:IsPurgable()
	return true
end

function dasdingo_6_modifier_fire:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function dasdingo_6_modifier_fire:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local intervals = 0.5
	local fire_damage = self.ability:GetSpecialValueFor("fire_damage") * intervals
	self.max_stack = self.ability:GetSpecialValueFor("max_stack")

	self.damageTable = {
		victim = self.parent,
		attacker = self.caster,
		damage = fire_damage,
		damage_type = self.ability:GetAbilityDamageType(),
		ability = self.ability
	}

	if IsServer() then
		self:SetStackCount(1)
		self:StartIntervalThink(intervals)
	end
end

function dasdingo_6_modifier_fire:OnRefresh(kv)
	if IsServer() then self:IncrementStackCount() end
	if self:GetStackCount() < self.max_stack then return end

	local stun_duration = self.ability:GetSpecialValueFor("stun_duration")
	local blast_damage = self.ability:GetSpecialValueFor("blast_damage")

	self.parent:Purge(true, false, false, false, false)

	self.damageTable.damage = blast_damage
	ApplyDamage(self.damageTable)

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_stun", {
		duration = self.ability:CalcStatus(stun_duration, self.caster, self.parent)
	})

	self:Destroy()
end

function dasdingo_6_modifier_fire:OnRemoved()
end

--------------------------------------------------------------------------------

function dasdingo_6_modifier_fire:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function dasdingo_6_modifier_fire:OnAttackLanded(keys)
end

function dasdingo_6_modifier_fire:OnIntervalThink()
	ApplyDamage(self.damageTable)
end

--------------------------------------------------------------------------------

function dasdingo_6_modifier_fire:PlayEfxStart(target)
	local particle_cast = "particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, target)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then target:EmitSound("Hero_Lion.Voodoo") end
end
doom_modifier = class({})

function doom_modifier:IsHidden()
	return false
end

function doom_modifier:IsPurgable()
    return false
end

function doom_modifier:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  local damage = self.ability:GetSpecialValueFor("damage")
  local tick = self.ability:GetSpecialValueFor("tick")

  AddStatusEfx(self.ability, "doom_modifier_status_efx", self.caster, self.parent)

	self.damageTable = {
		damage = damage * tick,
		attacker = self.caster,
		victim = self.parent,
		damage_type = self.ability:GetAbilityDamageType(),
		ability = self.ability
	}

	if IsServer() then
		self:StartIntervalThink(tick)
		self:PlayEfxStart()
	end
end

function doom_modifier:OnRefresh(kv)
end

function doom_modifier:OnRemoved()
  RemoveStatusEfx(self.ability, "doom_modifier_status_efx", self.caster, self.parent)

	if IsServer() then self.parent:StopSound("Hero_DoomBringer.Doom") end
end

--------------------------------------------------------------------------------------------------------------------------

function doom_modifier:CheckState()
	local state = {
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
	}

	return state
end

function doom_modifier:OnIntervalThink()
	if self.caster == nil then self:Destroy() return end
	if IsValidEntity(self.caster) == false then self:Destroy() return end

	ApplyDamage(self.damageTable)
end

--------------------------------------------------------------------------------------------------------------------------

function doom_modifier:GetStatusEffectName()
	return "particles/status_fx/status_effect_doom.vpcf"
end

function doom_modifier:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function doom_modifier:PlayEfxStart()
	local particle_cast = "particles/units/heroes/hero_doom_bringer/doom_bringer_doom.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	--ParticleManager:SetParticleControl(effect_cast, iControlPoint, vControlVector)

	self:AddParticle(effect_cast, false, false, MODIFIER_PRIORITY_SUPER_ULTRA, false, false)

	if IsServer() then self.parent:EmitSound("Hero_DoomBringer.Doom") end
end
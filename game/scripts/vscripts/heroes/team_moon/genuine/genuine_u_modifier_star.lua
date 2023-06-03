genuine_u_modifier_star = class({})

function genuine_u_modifier_star:IsHidden() return false end
function genuine_u_modifier_star:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_u_modifier_star:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
  self.effect = (self.parent:GetMana() > self.caster:GetMana())

  local mana_steal = self.parent:GetMaxMana() * self.ability:GetSpecialValueFor("mana_steal") * 0.01

	if IsServer() then
		self:PlayEfxStart()
    self:OnIntervalThink()
    StealMana(self.parent, self.caster, self.ability, mana_steal)
	end
end

function genuine_u_modifier_star:OnRefresh(kv)
end

function genuine_u_modifier_star:OnRemoved()
  if self.parent:IsAlive() == false then
    local cd = self.ability:GetCooldownTimeRemaining()
    self.ability:EndCooldown()
    self.ability:StartCooldown(cd / 2)
  end
  
	if IsServer() then self.parent:StopSound("Hero_DeathProphet.Exorcism") end
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_u_modifier_star:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION
	}
	
	return funcs
end

function genuine_u_modifier_star:GetBonusNightVision()
	return self:GetAbility():GetSpecialValueFor("night_vision")
end

function genuine_u_modifier_star:OnIntervalThink()
	if self.effect == true then
    self:PlayEfxPurge()
		self.caster:Purge(false, true, false, false, false)

    if self.parent:IsMagicImmune() == false then
      AddModifier(self.parent, self.caster, self.ability, "_modifier_percent_movespeed_debuff", {
        percent = 100, duration = 0.5
      }, false)
    end
	end

	if IsServer() then
		self:StartIntervalThink(self.ability:GetSpecialValueFor("interval"))
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function genuine_u_modifier_star:PlayEfxStart()
	local particle = "particles/genuine/genuine_ultimate.vpcf"

	local effect_caster = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.caster)
	ParticleManager:SetParticleControl(effect_caster, 0, self.caster:GetOrigin())
	self:AddParticle(effect_caster, false, false, -1, false, false)

  local effect_target = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_target, 0, self.parent:GetOrigin())
	self:AddParticle(effect_target, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_DeathProphet.Exorcism") end
end

function genuine_u_modifier_star:PlayEfxPurge()
	local particle_cast = "particles/genuine/ult_deny/genuine_deny_v2.vpcf"

	local effect_caster = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.caster)
	ParticleManager:SetParticleControlEnt(effect_caster, 0, self.caster, PATTACH_POINT_FOLLOW, "", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effect_caster, 1, self.caster, PATTACH_POINT_FOLLOW, "", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex(effect_caster)

  local effect_target = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(effect_target, 0, self.parent, PATTACH_POINT_FOLLOW, "", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effect_target, 1, self.parent, PATTACH_POINT_FOLLOW, "", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex(effect_target)
end
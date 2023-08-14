baldur_u_modifier_endurance = class({})

function baldur_u_modifier_endurance:IsHidden() return false end
function baldur_u_modifier_endurance:IsPurgable() return false end

local BATTLE_OUT = 0
local BATTLE_IN = 1

-- CONSTRUCTORS -----------------------------------------------------------

function baldur_u_modifier_endurance:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.delay = 0

  AddStatusEfx(self.ability, "baldur_u_modifier_endurance_status_efx", self.caster, self.parent)

  self.ability:SetActivated(false)
  self.ability:EndCooldown()

	if IsServer() then
    self:SetStackCount(self.ability:GetSpecialValueFor("duration"))
		self:StartIntervalThink(1)
		self:PlayEfxStart()
    self:ChangeTime(BATTLE_OUT)
	end
end

function baldur_u_modifier_endurance:OnRefresh(kv)
end

function baldur_u_modifier_endurance:OnRemoved()
  RemoveStatusEfx(self.ability, "baldur_u_modifier_endurance_status_efx", self.caster, self.parent)

  self.ability:SetActivated(true)
  self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
end

-- API FUNCTIONS -----------------------------------------------------------

function baldur_u_modifier_endurance:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
    MODIFIER_EVENT_ON_ATTACKED
	}

	return funcs
end

function baldur_u_modifier_endurance:GetModifierConstantHealthRegen(keys)
	return self:GetParent():GetMaxHealth() * self.regen * 0.01
end

function baldur_u_modifier_endurance:OnTakeDamage(keys)
	if keys.unit == self.parent or keys.attacker == self.parent then
    self.delay = 0
    self:ChangeTime(BATTLE_IN)
	end

  if keys.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
		self:ApplyLifesteal(keys)
	end
end

function baldur_u_modifier_endurance:OnAttacked(keys)
	self:ApplyLifesteal(keys)
end

function baldur_u_modifier_endurance:OnIntervalThink()
  local interval = 1

  if self.battle_state == BATTLE_IN then
    if self.delay > 0 then
      self.delay = self.delay - interval
      if self.delay == 0 then
        self.battle_state = BATTLE_OUT
        self:ChangeTime(BATTLE_OUT)
      end
    else
      self.delay = self.ability:GetSpecialValueFor("delay")
    end
  else
    interval = 1 / (self.ability:GetSpecialValueFor("time_out") * 0.01)
  end

	if IsServer() then
    self.parent:EmitSound("Hero_OgreMagi.Bloodlust.Target.FP")
    self:DecrementStackCount()
    self:StartIntervalThink(interval)
  end
end

function baldur_u_modifier_endurance:OnStackCountChanged(old)
  if self:GetStackCount() ~= old and self:GetStackCount() == 0 then self:Destroy() end
end

-- UTILS -----------------------------------------------------------

function baldur_u_modifier_endurance:ChangeTime(battle_state)
  local regen = 0

  if battle_state == BATTLE_IN then
    regen = self.ability:GetSpecialValueFor("hp_regen_in")
  end

  if battle_state == BATTLE_OUT then
    regen = self.ability:GetSpecialValueFor("hp_regen_out")
  end

  self.battle_state = battle_state
  self.regen = regen
  if self.effect_cast then ParticleManager:SetParticleControl(self.effect_cast, 15, Vector(regen * 10, 0, 0)) end
end

function baldur_u_modifier_endurance:ApplyLifesteal(keys)
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end

	local lifesteal = keys.original_damage * self.ability:GetSpecialValueFor("lifesteal") * 0.01
  keys.attacker:Heal(lifesteal, self.ability)
  self:PlayEfxLifesteal(keys.attacker)
end

-- EFFECTS -----------------------------------------------------------

function baldur_u_modifier_endurance:GetStatusEffectName()
  return "particles/bald/bald_vitality/bald_vitality_status_efx.vpcf"
end

function baldur_u_modifier_endurance:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function baldur_u_modifier_endurance:PlayEfxStart()
	local particle_cast = "particles/bald/bald_vitality/bald_vitality_buff.vpcf"
	self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast, 0, self.parent:GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(self.effect_cast, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(1,0,0), true)
	ParticleManager:SetParticleControl(self.effect_cast, 15, Vector(1, 0, 0))
	self:AddParticle(self.effect_cast, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_OgreMagi.Bloodlust.Target") end
end

function baldur_u_modifier_endurance:PlayEfxLifesteal(attacker)
	local particle_cast = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, attacker)
	ParticleManager:SetParticleControl(effect_cast, 1, attacker:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)
end
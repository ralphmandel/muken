icebreaker_1_modifier_passive = class({})

function icebreaker_1_modifier_passive:IsHidden() return true end
function icebreaker_1_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_1_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then
    self:PlayEfxAmbient()
  end
end

function icebreaker_1_modifier_passive:OnRefresh(kv)
  local ms = self.ability:GetSpecialValueFor("special_ms")
  if ms > 0 then
    RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_permanent_movespeed_buff", self.ability)
    AddModifier(self.parent, self.ability, "_modifier_permanent_movespeed_buff", {percent = ms}, false)
  end
end

function icebreaker_1_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function icebreaker_1_modifier_passive:OnAttack(keys)
  if keys.attacker ~= self.parent then return end

  local invi_delay = self.ability:GetSpecialValueFor("special_invi_delay")
  if invi_delay > 0 then
    if IsServer() then self:StartIntervalThink(invi_delay) end
  end
end

function icebreaker_1_modifier_passive:OnTakeDamage(keys)  
  if keys.unit == self.parent then
    local invi_delay = self.ability:GetSpecialValueFor("special_invi_delay")
    if invi_delay > 0 then
      if IsServer() then self:StartIntervalThink(invi_delay) end
    end
  end

  if keys.attacker == nil then return end
  if keys.attacker:IsBaseNPC() == false then return end
  if keys.attacker ~= self.parent then return end

  if keys.damage_flags == 1024 then
    AddModifier(keys.unit, self.ability, "icebreaker__modifier_hypo", {stack = 1}, false)
  end
end

function icebreaker_1_modifier_passive:OnAttackLanded(keys)
  if keys.attacker ~= self.parent then return end
  if keys.target:IsMagicImmune() then return end
  if self.parent:IsIllusion() then return end
  if self.parent:PassivesDisabled() then return end
  if self.parent:HasModifier("icebreaker_1_modifier_hits") then return end

  if RandomFloat(0, 100) < self.ability:GetSpecialValueFor("chance") then
    self.ability:PerformFrostAttack(keys.target, keys.damage)
  end
end

function icebreaker_1_modifier_passive:OnIntervalThink()
  AddModifier(self.parent, self.ability, "_modifier_invisible", {spell_break = 1}, false)

  if IsServer() then self:StartIntervalThink(-1) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function icebreaker_1_modifier_passive:PlayEfxAmbient()
	if self.effect_cast_2 then ParticleManager:DestroyParticle(self.effect_cast_2, true) end
	local particle_cast_2 = "particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch_buff.vpcf"
	self.effect_cast_2 = ParticleManager:CreateParticle(particle_cast_2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast_2, 0, self.parent:GetOrigin() )
	self:AddParticle(self.effect_cast_2, false, false, -1, false, false)
end
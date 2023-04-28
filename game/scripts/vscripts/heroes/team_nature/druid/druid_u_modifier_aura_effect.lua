druid_u_modifier_aura_effect = class({})

function druid_u_modifier_aura_effect:IsHidden() return true end
function druid_u_modifier_aura_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_u_modifier_aura_effect:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.mod_applied = false

  self:ApplyOnAllies()
  self:ApplyOnEnemyHero()
  self:ApplyOnNeutral()
end

function druid_u_modifier_aura_effect:OnRefresh(kv)
end

function druid_u_modifier_aura_effect:OnRemoved()
  if self.mod_applied == true then self.ability:SetCurrentAbilityCharges(self.ability:GetCurrentAbilityCharges() - 1) end

  RemoveBonus(self.ability, "_1_STR", self.parent)
  RemoveBonus(self.ability, "_1_AGI", self.parent)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_percent_movespeed_debuff", self.ability)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_manaloss", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_u_modifier_aura_effect:OnIntervalThink()
  local calc = (100 / (20 + (self.parent:GetLevel() * 2))) * (1 + (self.caster:GetLevel() * self.ability:GetSpecialValueFor("chance") * 0.01))

  if RandomFloat(0, 100) < calc * self.interval and self.parent:GetLevel() <= self.ability:GetSpecialValueFor("max_dominate") then
    self.parent:Purge(false, true, false, false, false)
    self.parent:AddNewModifier(self.caster, self.ability, "druid_u_modifier_conversion", {})    
    self:Destroy()
    return
  end

	if IsServer() then self:StartIntervalThink(self.interval) end
end

-- UTILS -----------------------------------------------------------

function druid_u_modifier_aura_effect:ApplyOnAllies()
  local str = self.ability:GetSpecialValueFor("special_str")
  local agi = self.ability:GetSpecialValueFor("special_agi")
  if str == 0 and agi == 0 then return end
  if self.caster:GetTeamNumber() ~= self.parent:GetTeamNumber() then return end
  if self.caster == self.parent then return end

  self.ability:SetCurrentAbilityCharges(self.ability:GetCurrentAbilityCharges() + 1)
  self.mod_applied = true

  AddBonus(self.ability, "_1_STR", self.parent, str, 0, nil)
  AddBonus(self.ability, "_1_AGI", self.parent, agi, 0, nil)

  if IsServer() then self:PlayEfxBuff() end
end

function druid_u_modifier_aura_effect:ApplyOnEnemyHero()
  local slow = self.ability:GetSpecialValueFor("special_slow")
  local manaloss = self.ability:GetSpecialValueFor("special_manaloss")
  local hex_chance = self.ability:GetSpecialValueFor("hex_chance")
  local hex_duration = self.ability:GetSpecialValueFor("hex_duration")

  if slow == 0 and manaloss == 0 and hex_duration == 0 then return end
  if self.caster:GetTeamNumber() == self.parent:GetTeamNumber() then return end
  if self.parent:IsHero() == false then return end

  self.ability:SetCurrentAbilityCharges(self.ability:GetCurrentAbilityCharges() + 1)
  self.mod_applied = true

  if slow > 0 and manaloss > 0 then
    self.parent:AddNewModifier(self.caster, self.ability, "_modifier_percent_movespeed_debuff", {percent = slow})
    self.parent:AddNewModifier(self.caster, self.ability, "_modifier_manaloss", {manaloss = manaloss})
  end

  if RandomFloat(0, 100) < hex_chance then
    self.parent:AddNewModifier(self.caster, self.ability, "_modifier_hex", {
      duration = CalcStatus(hex_duration, self.caster, self.parent)
    })
  end

  if IsServer() then self:PlayEfxDebuff() end
end

function druid_u_modifier_aura_effect:ApplyOnNeutral()
  if self.caster:GetTeamNumber() == self.parent:GetTeamNumber() then return end
  if self.parent:IsHero() then return end

  self.interval = self.ability:GetSpecialValueFor("interval")
  self.ability:SetCurrentAbilityCharges(self.ability:GetCurrentAbilityCharges() + 1)
  self.mod_applied = true

  if IsServer() then
    self:PlayEfxDebuff()
    self:StartIntervalThink(self.interval)
  end
end

-- EFFECTS -----------------------------------------------------------

function druid_u_modifier_aura_effect:PlayEfxBuff()
	local string_3 = "particles/units/heroes/hero_lycan/lycan_howl_buff.vpcf"
	local particle = ParticleManager:CreateParticle(string_3, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	self:AddParticle(particle, false, false, -1, false, false)
end

function druid_u_modifier_aura_effect:PlayEfxDebuff()
	local string_3 = "particles/units/heroes/hero_enchantress/enchantress_enchant_slow.vpcf"
	local particle = ParticleManager:CreateParticle(string_3, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	self:AddParticle(particle, false, false, -1, false, false)
end
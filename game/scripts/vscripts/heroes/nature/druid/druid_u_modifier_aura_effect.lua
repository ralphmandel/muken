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
  if self.parent:IsReincarnating() == false then self.parent:RemoveModifierByNameAndCaster("druid_u_modifier_reborn", self.caster) end

  RemoveBonus(self.ability, "STR", self.parent)
  RemoveBonus(self.ability, "AGI", self.parent)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_percent_movespeed_debuff", self.ability)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_manaloss", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_u_modifier_aura_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_REINCARNATION
	}

	return funcs
end

function druid_u_modifier_aura_effect:ReincarnateTime()
  if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
    if RandomFloat(0, 100) < self:GetAbility():GetSpecialValueFor("special_reborn_chance") then
      return self:GetAbility():GetSpecialValueFor("special_reborn_delay")
    end
  end
  
  return 0
end

function druid_u_modifier_aura_effect:OnIntervalThink()
  self:TryConversion()
  self:TryHex()

	if IsServer() then self:StartIntervalThink(self.interval) end
end

-- UTILS -----------------------------------------------------------

function druid_u_modifier_aura_effect:TryConversion()
  if self.parent:IsHero() then return end

  local calc = (100 / (20 + (self.parent:GetLevel() * 2))) * (1 + (self.caster:GetLevel() * self.ability:GetSpecialValueFor("chance") * 0.01))

  if RandomFloat(0, 100) < calc * self.interval and self.parent:GetLevel() <= self.ability:GetSpecialValueFor("max_dominate") then
    self.parent:Purge(false, true, false, false, false)
    AddModifier(self.parent, self.ability, "druid_u_modifier_conversion", {}, false)

    self:Destroy()
    return
  end
end

function druid_u_modifier_aura_effect:TryHex()
  if self.parent:IsHero() == false then return end

  if RandomFloat(0, 100) < self.ability:GetSpecialValueFor("special_hex_chance") * self.interval then
    AddModifier(self.parent, self.ability, "_modifier_hex", {
      duration = self.ability:GetSpecialValueFor("special_hex_duration")
    }, true)
  end
end

function druid_u_modifier_aura_effect:ApplyOnAllies()
  if self.caster:GetTeamNumber() ~= self.parent:GetTeamNumber() then return end

  local str = self.ability:GetSpecialValueFor("special_str")
  local agi = self.ability:GetSpecialValueFor("special_agi")
  local reborn_chance = self.ability:GetSpecialValueFor("special_reborn_chance")

  if str > 0 or agi > 0 then
    AddBonus(self.ability, "STR", self.parent, str, 0, nil)
    AddBonus(self.ability, "AGI", self.parent, agi, 0, nil)
    self.ability:SetCurrentAbilityCharges(self.ability:GetCurrentAbilityCharges() + 1)
    self.mod_applied = true
  
    if IsServer() then self:PlayEfxBuff() end
  end

  if reborn_chance > 0 and self.parent:IsHero() then
    AddModifier(self.parent, self.ability, "druid_u_modifier_reborn", {}, false)
    self.ability:SetCurrentAbilityCharges(self.ability:GetCurrentAbilityCharges() + 1)
    self.mod_applied = true
  end
end

function druid_u_modifier_aura_effect:ApplyOnEnemyHero()
  if self.caster:GetTeamNumber() == self.parent:GetTeamNumber() then return end
  if self.parent:IsHero() == false then return end
  
  local slow = self.ability:GetSpecialValueFor("special_slow")
  local manaloss = self.ability:GetSpecialValueFor("special_manaloss")
  local hex_duration = self.ability:GetSpecialValueFor("special_hex_duration")

  if slow > 0 and manaloss > 0 then
    AddModifier(self.parent, self.ability, "_modifier_percent_movespeed_debuff", {percent = slow}, false)
    AddModifier(self.parent, self.ability, "_modifier_manaloss", {manaloss = manaloss}, false)
    self.ability:SetCurrentAbilityCharges(self.ability:GetCurrentAbilityCharges() + 1)
    self.mod_applied = true

    if IsServer() then self:PlayEfxDebuff() end
  end

  if hex_duration > 0 then
    self.interval = 1
    self.ability:SetCurrentAbilityCharges(self.ability:GetCurrentAbilityCharges() + 1)
    self.mod_applied = true

    if IsServer() then
      self:PlayEfxDebuff()
      self:StartIntervalThink(self.interval)
    end
  end
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
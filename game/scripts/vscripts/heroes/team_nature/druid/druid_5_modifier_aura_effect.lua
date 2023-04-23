druid_5_modifier_aura_effect = class({})

function druid_5_modifier_aura_effect:IsHidden() return false end
function druid_5_modifier_aura_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_5_modifier_aura_effect:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.delay = false
  self.amount = 0

  if IsServer() then self:SetStackCount(self.amount) end
end

function druid_5_modifier_aura_effect:OnRefresh(kv)
end

function druid_5_modifier_aura_effect:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_5_modifier_aura_effect:DeclareFunctions()
	local funcs = {
    MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function druid_5_modifier_aura_effect:OnTakeDamage(keys)
  if keys.unit ~= self.parent then return end
  if self.delay == true then return end

  local delay = self.ability:GetSpecialValueFor("delay")
  self.amount = self.amount + keys.damage

  if self.amount >= self.ability:GetSpecialValueFor("hp_lost") then
    self.amount = 0

    if self.parent:GetTeamNumber() == self.caster:GetTeamNumber() then
      if self.parent == self.caster then
        self:CasterSource()
      else
        self:AlliedSource()
      end
    else
      self:EnemySource()
    end

    if delay > 0 then
      if IsServer() then
        self.delay = true
        self:StartIntervalThink(delay)
      end
    end
  end

  if IsServer() then self:SetStackCount(self.amount) end
end

function druid_5_modifier_aura_effect:OnIntervalThink()
  self.delay = false
  if IsServer() then self:StartIntervalThink(-1) end
end

-- UTILS -----------------------------------------------------------

function druid_5_modifier_aura_effect:CasterSource()
  local druid_seed_extra = self.ability:GetSpecialValueFor("special_druid_seed_extra")
  local allies = FindUnitsInRadius(self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, -1, 1, 1, 0, 0, false)

  for _,ally in pairs(allies) do
    if druid_seed_extra > 0 and ally ~= self.parent
    and ally:HasModifier("druid_5_modifier_aura_effect") then
      self.ability:CreateSeed(self.parent, ally, self.parent:GetAbsOrigin())
      druid_seed_extra = druid_seed_extra - 1
    end
  end
end

function druid_5_modifier_aura_effect:AlliedSource()
  self.ability:CreateSeed(self.parent, self.caster, self.parent:GetAbsOrigin())

  local ally_seed_extra = self.ability:GetSpecialValueFor("special_ally_seed_extra")
  local allies = FindUnitsInRadius(self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, -1, 1, 1, 0, 0, false)

  for _,ally in pairs(allies) do
    if ally_seed_extra > 0 and ally ~= self.caster and ally ~= self.parent
    and ally:HasModifier("druid_5_modifier_aura_effect") then
      self.ability:CreateSeed(self.parent, ally, self.parent:GetAbsOrigin())
      ally_seed_extra = ally_seed_extra - 1
    end
  end
end

function druid_5_modifier_aura_effect:EnemySource()
  self.ability:CreateSeed(self.parent, self.caster, self.parent:GetAbsOrigin())
end

-- EFFECTS -----------------------------------------------------------
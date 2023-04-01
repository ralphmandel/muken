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
    self.ability:CreateSeed(self.parent)

    if delay > 0 then
      if IsServer() then
        self.delay = true
        self:StartIntervalThink(delay)
      end
    end
  end
end

function druid_5_modifier_aura_effect:OnIntervalThink()
  self.delay = false
  if IsServer() then self:StartIntervalThink(-1) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------
druid_5_modifier_wind_effect = class({})

function druid_5_modifier_wind_effect:IsHidden() return true end
function druid_5_modifier_wind_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_5_modifier_wind_effect:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  if IsServer() then
    self.parent:EmitSound("Druid.Wind")
    self:StartIntervalThink(60)
  end
end

function druid_5_modifier_wind_effect:OnRefresh(kv)
end

function druid_5_modifier_wind_effect:OnRemoved()
  if IsServer() then self.parent:StopSound("Druid.Wind") end
end

-- API FUNCTIONS -----------------------------------------------------------



function druid_5_modifier_wind_effect:OnIntervalThink()
  if IsServer() then
    self.parent:StopSound("Druid.Wind")
    self.parent:EmitSound("Druid.Wind")
    self:StartIntervalThink(60)
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------
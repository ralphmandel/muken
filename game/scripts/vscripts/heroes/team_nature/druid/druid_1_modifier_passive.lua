druid_1_modifier_passive = class({})

function druid_1_modifier_passive:IsHidden() return true end
function druid_1_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_1_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	self.location = self.parent:GetOrigin()
end

function druid_1_modifier_passive:OnRefresh(kv)
end

function druid_1_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_UNIT_MOVED
	}

	return funcs
end

function druid_1_modifier_passive:OnUnitMoved(keys)
	if keys.unit ~= self.parent then return end
	if self.parent:PassivesDisabled() then return end
	if self.parent:IsInvisible() then return end

	local origin = self.parent:GetOrigin()
	local distance = (origin - self.location):Length2D()
	local path_radius = self.ability:GetSpecialValueFor("path_radius") * 0.6
	local bush_duration = self.ability:GetSpecialValueFor("special_bush_duration")

  if bush_duration > 0 then    
    if distance >= path_radius / 3 then
      self.ability:CreateBush(
        self.ability:RandomizeLocation(self.location, origin, path_radius),
        bush_duration + RandomFloat(-bush_duration * 0.2, bush_duration * 0.2),
        "druid_1_modifier_mini_root"
      )
      self.location = origin
    end
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------
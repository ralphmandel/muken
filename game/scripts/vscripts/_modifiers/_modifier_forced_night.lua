_modifier_forced_night = class({})

--------------------------------------------------------------------------------
function _modifier_forced_night:IsHidden()
	return true
end

function _modifier_forced_night:IsPurgable()
	return false
end

function _modifier_forced_night:GetTexture()
	return "_modifier_forced_night"
end

--------------------------------------------------------------------------------

function _modifier_forced_night:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  print("kubo", self.parent:GetClassname())
  UpdateForcedTime()
end

function _modifier_forced_night:OnRemoved()
  UpdateForcedTime()
end

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
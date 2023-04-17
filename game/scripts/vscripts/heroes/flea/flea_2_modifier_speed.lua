flea_2_modifier_speed = class({})

function flea_2_modifier_speed:IsHidden() return true end
function flea_2_modifier_speed:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_2_modifier_speed:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.max_speed = self.ability:GetSpecialValueFor("max_speed")
	self.speed_hit = self.ability:GetSpecialValueFor("speed_hit")
	self.speed = self.speed_hit

	self:IncreaseSpeed()
end

function flea_2_modifier_speed:OnRefresh(kv)
	self.max_speed = self.ability:GetSpecialValueFor("max_speed")
	self.speed_hit = self.ability:GetSpecialValueFor("speed_hit")
	self.speed = self.speed + self.speed_hit

	if self.speed > self.max_speed then
		self.speed = self.max_speed
	end

	self:IncreaseSpeed()
end

function flea_2_modifier_speed:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_buff", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

function flea_2_modifier_speed:IncreaseSpeed()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_buff", self.ability)

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {
		duration = self:GetDuration(),
		percent = self.speed
	})
end

-- EFFECTS -----------------------------------------------------------
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
	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_buff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

function flea_2_modifier_speed:IncreaseSpeed()
	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_buff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {
		duration = self:GetDuration(),
		percent = self.speed
	})
end

-- EFFECTS -----------------------------------------------------------
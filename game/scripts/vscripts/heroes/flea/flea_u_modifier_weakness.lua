flea_u_modifier_weakness = class({})
local tempTable = require("libraries/tempTable")

function flea_u_modifier_weakness:IsHidden() return false end
function flea_u_modifier_weakness:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_u_modifier_weakness:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.stack = 0

	if IsServer() then
		self:SetStackCount(0)
		self:AddMultStack()
	end
end

function flea_u_modifier_weakness:OnRefresh(kv)
	if IsServer() then self:AddMultStack() end
end

function flea_u_modifier_weakness:OnRemoved()
	RemoveBonus(self.ability, "_1_STR", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_u_modifier_weakness:OnStackCountChanged(old)
	if old == self:GetStackCount() then return end

	local diff = self:GetStackCount() - old
	local mod = self.caster:FindModifierByName(self.ability:GetIntrinsicModifierName())
	mod:SetStackCount(mod:GetStackCount() + diff)

	if self:GetStackCount() == 0 then self:Destroy() return end
	if IsServer() and diff > 0 then self:PlayEfxHit(self.parent) end

	RemoveBonus(self.ability, "_1_STR", self.parent)
	AddBonus(self.ability, "_1_STR", self.parent, -self:GetStackCount(), 0, nil)
end

-- UTILS -----------------------------------------------------------

function flea_u_modifier_weakness:AddMultStack()
	local stack_duration = CalcStatus(self.ability:GetSpecialValueFor("stack_duration"), self.caster, self.parent)
	self:SetDuration(stack_duration, true)
	self:ChangeStack(1)

	local this = tempTable:AddATValue(self)
	self.parent:AddNewModifier(self.caster, self.ability, "flea_u_modifier_weakness_stack", {
		duration = stack_duration,
		modifier = this
	})
end

function flea_u_modifier_weakness:ChangeStack(value)
	self.stack = self.stack + value

	local current_stack = self.stack
	local max_stack = self.ability:GetSpecialValueFor("max_stack")
	
	if current_stack > max_stack then current_stack = max_stack end
	self:SetStackCount(current_stack)
end

-- EFFECTS -----------------------------------------------------------

function flea_u_modifier_weakness:PlayEfxHit(target)
	local particle_cast = "particles/econ/items/slark/slark_ti6_blade/slark_ti6_blade_essence_shift.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(effect_cast, 1, self.caster:GetOrigin() + Vector(0, 0, 64))
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then target:EmitSound("Hero_BountyHunter.Jinada") end
end
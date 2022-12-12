bald_3_modifier_inner = class({})
local tempTable = require("libraries/tempTable")

function bald_3_modifier_inner:IsHidden() return false end
function bald_3_modifier_inner:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_3_modifier_inner:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.ability.def = kv.def
	self.ability:ChangeModelScale()
	self.ability:SetActivated(false)
	self.ability:EndCooldown()

	if IsServer() then
		self:SetStackCount(kv.def)
		self:PlayEfxStart()
	end
end

function bald_3_modifier_inner:OnRefresh(kv)
	self.ability.def = kv.def
	self.ability:ChangeModelScale()

	if IsServer() then
		self:SetStackCount(kv.def)
		self:PlayEfxStart()
	end
end

function bald_3_modifier_inner:OnRemoved()
	self.ability.def = 0
	RemoveBonus(self.ability, "_2_DEF", self.parent)
	self.ability:ChangeModelScale()
	self.ability:SetActivated(true)
	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_3_modifier_inner:OnStackCountChanged(old)
	RemoveBonus(self.ability, "_2_DEF", self.parent)

	if self:GetStackCount() > 0 then
		AddBonus(self.ability, "_2_DEF", self.parent, self:GetStackCount(), 0, nil)
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bald_3_modifier_inner:PlayEfxStart()
	local string = "particles/bald/bald_inner/bald_inner_owner.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(particle, 10, Vector(self.parent:GetModelScale() * 100, 0, 0))
	ParticleManager:SetParticleControlEnt(particle, 2, self.parent, PATTACH_POINT_FOLLOW, "attach_weapon", Vector(0,0,0), true)
	self:AddParticle(particle, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_EarthSpirit.Magnetize.Cast") end
end
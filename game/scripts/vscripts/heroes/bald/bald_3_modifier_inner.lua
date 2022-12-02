bald_3_modifier_inner = class({})
local tempTable = require("libraries/tempTable")

function bald_3_modifier_inner:IsHidden() return false end
function bald_3_modifier_inner:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_3_modifier_inner:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self:ChangeModelScale(kv.def)
	self.atk_range = kv.def * 2

	if IsServer() then
		self:SetStackCount(kv.def)
		self:PlayEfxStart()
	end
end

function bald_3_modifier_inner:OnRefresh(kv)
	self:ChangeModelScale(kv.def)

	if IsServer() then
		self:SetStackCount(kv.def)
		self:PlayEfxStart()
	end
end

function bald_3_modifier_inner:OnRemoved()
	self.ability:RemoveBonus("_2_DEF", self.parent)
	self:ChangeModelScale(0)
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_3_modifier_inner:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
	}

	return funcs
end

function bald_3_modifier_inner:GetModifierAttackRangeBonus()
	return self.atk_range
end

function bald_3_modifier_inner:OnStackCountChanged(old)
	self.ability:RemoveBonus("_2_DEF", self.parent)

	if self:GetStackCount() > 0 then
		self.ability:AddBonus("_2_DEF", self.parent, self:GetStackCount(), 0, nil)
	end
end

-- UTILS -----------------------------------------------------------

function bald_3_modifier_inner:ChangeModelScale(def)
	local base_hero_mod = self.parent:FindModifierByName("base_hero_mod")
	if base_hero_mod == nil then return end
	if base_hero_mod.model_scale == nil then return end

	self.parent:SetModelScale(base_hero_mod.model_scale + (def * 0.02))
	self:ChangeAbilityRange("bald_2__bash")
end

function bald_3_modifier_inner:ChangeAbilityRange(ability_name)
	local ability = self.parent:FindAbilityByName(ability_name)
	if ability then
		if ability:IsTrained() then
			ability:CheckAbilityCharges(1)
		end
	end
end

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
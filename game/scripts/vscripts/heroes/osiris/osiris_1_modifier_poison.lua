osiris_1_modifier_poison = class ({})
local tempTable = require("libraries/tempTable")

function osiris_1_modifier_poison:IsHidden()
    return false
end

function osiris_1_modifier_poison:IsPurgable()
    return true
end

function osiris_1_modifier_poison:IsDebuff()
    return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function osiris_1_modifier_poison:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then
		self:SetStackCount(0)
		self:AddMultStack()
		self:PlayEfxRelease()
	end
end

function osiris_1_modifier_poison:OnRefresh(kv)
	if IsServer() then self:AddMultStack() end
end

function osiris_1_modifier_poison:OnRemoved(kv)
end

-- API FUNCTIONS -----------------------------------------------------------

function osiris_1_modifier_poison:DeclareFunctions()
end

-- UTILS -----------------------------------------------------------

function osiris_1_modifier_poison:AddMultStack()
	self:IncrementStackCount()

	local this = tempTable:AddATValue(self)
	self.parent:AddNewModifier(self.caster, self.ability, "osiris_1_modifier_poison_stack", {
		duration = self:GetDuration(),
		modifier = this
	})
end

function osiris_1_modifier_poison:Release()
end

-- EFFECTS -----------------------------------------------------------

function osiris_1_modifier_poison:PlayEfxRelease()
	if IsServer() then self.parent:EmitSound("Hero_Venomancer.VenomousGaleImpact") end
end
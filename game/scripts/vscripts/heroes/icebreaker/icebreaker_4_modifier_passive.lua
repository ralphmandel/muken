icebreaker_4_modifier_passive = class({})

function icebreaker_4_modifier_passive:IsHidden() return false end
function icebreaker_4_modifier_passive:IsPurgable() return false end
function icebreaker_4_modifier_passive:GetTexture() return "icebreaker_aspd" end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_4_modifier_passive:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

end

function icebreaker_4_modifier_passive:OnRefresh(kv)
end

function icebreaker_4_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_4_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function icebreaker_4_modifier_passive:OnAttackLanded(keys)
	if RandomFloat(1, 100) <= self.ability:GetSpecialValueFor("chance")
	and keys.target == self.parent then
		self:ApplyInvisibility(keys.attacker)
	end

	if keys.attacker == self.parent then
		local mod = self.parent:FindAllModifiersByName("_modifier_phase")
		for _,modifier in pairs(mod) do
			if modifier:GetAbility() == self.ability then modifier:Destroy() end
		end
	end
end

-- UTILS -----------------------------------------------------------

function icebreaker_4_modifier_passive:ApplyInvisibility(target)
	if self.parent:PassivesDisabled() then return end
	local invi_duration = self.ability:GetSpecialValueFor("invi_duration")

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_phase", {
		duration = CalcStatus(invi_duration, self.caster, self.parent)
	})

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_invisible", {
		duration = CalcStatus(invi_duration, self.caster, self.parent)
	})

	self:CreateMirror(target)
end

-- EFFECTS -----------------------------------------------------------

function icebreaker_4_modifier_passive:CreateMirror(target)
	local illu_array = CreateIllusions(self.parent, self.parent, {
		outgoing_damage = -50,
		incoming_damage = 500,
		bounty_base = 0,
		bounty_growth = 0,
		duration = self.ability:GetSpecialValueFor("illusion_lifetime")
	}, 1, 64, false, true)

	for _,illu in pairs(illu_array) do
		local loc = self.parent:GetAbsOrigin()
		illu:SetAbsOrigin(loc)
		illu:SetForwardVector((target:GetAbsOrigin() - loc):Normalized())
		illu:SetForceAttackTarget(target)
		FindClearSpaceForUnit(illu, loc, true)
	end		
end
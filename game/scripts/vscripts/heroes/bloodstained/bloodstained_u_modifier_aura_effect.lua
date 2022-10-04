bloodstained_u_modifier_aura_effect = class({})

function bloodstained_u_modifier_aura_effect:IsHidden()
	return false
end

function bloodstained_u_modifier_aura_effect:IsPurgable()
	return false
end

function bloodstained_u_modifier_aura_effect:IsDebuff()
	return self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber()
end

function bloodstained_u_modifier_aura_effect:GetPriority()
    return MODIFIER_PRIORITY_SUPER_ULTRA
end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained_u_modifier_aura_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function bloodstained_u_modifier_aura_effect:OnRefresh(kv)
end

function bloodstained_u_modifier_aura_effect:OnRemoved()
	self:ApplyBloodIllusion()
end

-- API FUNCTIONS -----------------------------------------------------------

function bloodstained_u_modifier_aura_effect:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_SILENCED] = true
	}

	return state
end

function bloodstained_u_modifier_aura_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_AVOID_DAMAGE,
	}

	return funcs
end

function bloodstained_u_modifier_aura_effect:GetModifierAvoidDamage(keys)
    if keys.attacker:HasModifier(self:GetName()) == false then
        return 1
    end

	return 0
end

-- UTILS -----------------------------------------------------------

function bloodstained_u_modifier_aura_effect:ApplyBloodIllusion()
	if self.caster:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if self.parent:IsAlive() == false then return end
	if self.parent:IsIllusion() then return end
	if self.parent:IsHero() == false then return end
	if self.ability:IsActivated() then return end

	local number = 1
	self:CreateCopy(number)
end

function bloodstained_u_modifier_aura_effect:CreateCopy(number)
	local copy_duration = self.ability:GetSpecialValueFor("copy_duration")
	local hp_stolen = self.ability:GetSpecialValueFor("hp_stolen")
	local total_hp_stolen = self.parent:GetHealth() * hp_stolen * number * 0.01

	local iDesiredHealthValue = self.parent:GetHealth() - total_hp_stolen
	self.parent:ModifyHealth(iDesiredHealthValue, self.ability, false, 0)

	local illu_array = CreateIllusions(self.caster, self.parent, {
		outgoing_damage = -50,
		incoming_damage = 200,
		bounty_base = 0,
		bounty_growth = 0,
		duration = -1
	}, number, 64, false, true)

	for _,illu in pairs(illu_array) do
		local mod = illu:AddNewModifier(self.caster, self.ability, "bloodstained_u_modifier_copy", {
			duration = copy_duration,
			hp = math.floor(total_hp_stolen / number)
		})

		illu:SetForceAttackTarget(self.parent)
		mod.target = self.parent
		mod:PlayEfxTarget()

		local loc = self.parent:GetAbsOrigin() + RandomVector(130)
		illu:SetAbsOrigin(loc)
		illu:SetForwardVector((self.parent:GetAbsOrigin() - loc):Normalized())
		FindClearSpaceForUnit(illu, loc, true)
	end
end

-- EFFECTS -----------------------------------------------------------

function bloodstained_u_modifier_aura_effect:GetEffectName()
	return "particles/bloodstained/bloodstained_thirst_owner_smoke_dark.vpcf"
end

function bloodstained_u_modifier_aura_effect:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end
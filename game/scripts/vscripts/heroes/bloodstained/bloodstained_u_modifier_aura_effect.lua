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

	-- UP 6.41
	if self.ability:GetRank(41) then
		self:ApplyDebuffs()
	end
end

function bloodstained_u_modifier_aura_effect:OnRefresh(kv)
end

function bloodstained_u_modifier_aura_effect:OnRemoved()
	local mod = self.parent:FindAllModifiersByName("bloodstained__modifier_bleeding")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	local mod = self.parent:FindAllModifiersByName("_modifier_break")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	self:ApplyBloodIllusion()

	-- UP 6.11
	if self.ability:GetRank(11) then
		self:ReduceCooldown()
	end
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

	local copy_duration = self.ability:GetSpecialValueFor("copy_duration")
	local slow_duration = self.ability:GetSpecialValueFor("slow_duration")
	local hp_stolen = self.ability:GetSpecialValueFor("hp_stolen")
	local number = 1

	-- UP 6.12
	if self.ability:GetRank(12) then
		copy_duration = copy_duration + 5
		slow_duration = 3
	end

	-- UP 6.21
	if self.ability:GetRank(21) then
		hp_stolen = hp_stolen - 5
		number = 2
	end

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {
		duration = self.ability:CalcStatus(slow_duration, self.caster, self.parent),
		percent = 100
	})
	
	self:CreateCopy(number, hp_stolen, copy_duration)
end

function bloodstained_u_modifier_aura_effect:ReduceCooldown()
	if self.parent:IsAlive() then return end
	if self.parent:IsIllusion() then return end
	if self.parent:IsHero() == false then return end

	self.ability.cooldown = self.ability.cooldown - 25
end

function bloodstained_u_modifier_aura_effect:ApplyDebuffs()
	if self.caster:GetTeamNumber() == self.parent:GetTeamNumber() then return end

	self.parent:AddNewModifier(self.caster, self.ability, "bloodstained__modifier_bleeding", {})
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_break", {})
end

function bloodstained_u_modifier_aura_effect:CreateCopy(number, hp_stolen, copy_duration)
	local total_hp_stolen = self.parent:GetBaseMaxHealth() * hp_stolen * number * 0.01
	if total_hp_stolen > self.parent:GetHealth() then total_hp_stolen = self.parent:GetHealth() end

	local iDesiredHealthValue = self.parent:GetHealth() - total_hp_stolen
	self.parent:ModifyHealth(iDesiredHealthValue, self.ability, false, 0)

	local illu_array = CreateIllusions(self.caster, self.parent, {
		outgoing_damage = -50,
		incoming_damage = 400,
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

		local loc = self.parent:GetAbsOrigin() + RandomVector(100)
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
bloodstained_u_modifier_status = class({})

function bloodstained_u_modifier_status:IsHidden()
	return false
end

function bloodstained_u_modifier_status:IsPurgable()
    return false
end

-----------------------------------------------------------------------------------------------------------

function bloodstained_u_modifier_status:OnCreated( kv )
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.creation = false

    self.range = self.ability:GetSpecialValueFor("radius") + 50

    -- UP 4.3
	if self.ability:GetRank(3) then
		if self.caster:GetTeamNumber() ~= self.parent:GetTeamNumber() then
			self.parent:AddNewModifier(self.caster, self.ability, "bloodstained_0_modifier_bleeding", {})
		end
	end

    -- UP 4.5
	if self.ability:GetRank(5) then
		if self.caster:GetTeamNumber() ~= self.parent:GetTeamNumber() then
			self.parent:AddNewModifier(self.caster, self.ability, "_modifier_break", {})
		end
	end

    self.parent:AddNewModifier(self.caster, self.ability, "_modifier_silence", {special = 2})
    self:StartIntervalThink(0.1)
end

function bloodstained_u_modifier_status:OnRefresh()
end

function bloodstained_u_modifier_status:OnRemoved()
    local passives_break = self.parent:FindAllModifiersByName("_modifier_break")
	for _,modifier in pairs(passives_break) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

    local silence = self.parent:FindAllModifiersByName("_modifier_silence")
	for _,modifier in pairs(silence) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

    local bleeding = self.parent:FindAllModifiersByName("bloodstained_0_modifier_bleeding")
	for _,modifier in pairs(bleeding) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	if self.creation == true then
		self.ability:CreateCopy(self.parent, self.ability)
	end
end

--------------------------------------------------------------------------------

function bloodstained_u_modifier_status:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}

	return state
end

function bloodstained_u_modifier_status:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_AVOID_DAMAGE,
	}

	return funcs
end

function bloodstained_u_modifier_status:GetModifierAvoidDamage(keys)
    if keys.attacker:HasModifier("bloodstained_u_modifier_status") == false then
        return 1
    end

	return 0
end

function bloodstained_u_modifier_status:OnIntervalThink()
    local thinkers = Entities:FindAllByClassname("npc_dota_thinker")
    local carnage_seal = nil
	for _,seal in pairs(thinkers) do
		if seal:GetOwner() == self.caster and seal:HasModifier("bloodstained_u_modifier_seal") then
            carnage_seal = seal
		end
	end

    if carnage_seal == nil then
        self:Destroy()
        self:StartIntervalThink(-1)
    else
        local distance = CalcDistanceBetweenEntityOBB(self.parent, carnage_seal)
		if self.range < distance then
            if self.parent:GetTeamNumber() ~= self.caster:GetTeamNumber() then
				self.creation = true
            end
			self:Destroy()
			self:StartIntervalThink(-1)
		end
    end
end

------------------------------------------------------------------------------------------------------------

function bloodstained_u_modifier_status:GetEffectName()
	return "particles/bloodstained/bloodstained_thirst_owner_smoke_dark.vpcf"
end

function bloodstained_u_modifier_status:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end
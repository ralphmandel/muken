_boss_gorillaz_modifier_passive = class({})

function _boss_gorillaz_modifier_passive:IsHidden()
	return true
end

function _boss_gorillaz_modifier_passive:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function _boss_gorillaz_modifier_passive:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self:StartIntervalThink(1)
end

function _boss_gorillaz_modifier_passive:OnRefresh( kv )
end

function _boss_gorillaz_modifier_passive:OnRemoved()
end

--------------------------------------------------------------------------------

function _boss_gorillaz_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function _boss_gorillaz_modifier_passive:GetModifierEvasion_Constant()
	return 20
end

function _boss_gorillaz_modifier_passive:OnDeath(keys)
	if keys.unit ~= self.caster then return end
	
end

function _boss_gorillaz_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if RandomInt(1, 100) > 10 then return end
	if self.parent:HasModifier("mk_gorillaz_buff") then return end

	self.parent:AddNewModifier(self.caster, self.ability, "mk_gorillaz_buff", {duration = 5})
end

function _boss_gorillaz_modifier_passive:OnIntervalThink()
	local target = self.parent:GetAggroTarget()
	if target == nil then return end
	if self.parent:IsSilenced() then return end
	if self.parent:IsStunned() then return end
	if self.parent:IsDominated() then return end
	
	if self:RandomizeTarget() then return end
	if self:TryCast_Skill_1() then return end
	--if self:TryCast_Skill_2() then return end
	--if self:TryCast_Skill_3() then return end
	--if self:TryCast_Skill_4() then return end
end

function _boss_gorillaz_modifier_passive:RandomizeTarget()
	if RandomInt(1, 100) > 15 then return false end
	local mod_ai = self.parent:FindModifierByName("_boss_modifier__ai")
	if mod_ai == nil then return false end

	if mod_ai.state == 1 then
		local units = FindUnitsInRadius(
			self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, 500,
			DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false
		)

		for _,unit in pairs(units) do
			if self.parent:GetAggroTarget() ~= unit then
				self.parent:SetAggroTarget(unit)
				return true
			end
		end
	end

	return false
end

function _boss_gorillaz_modifier_passive:TryCast_Skill_1()
	local ability = self.parent:FindAbilityByName("mk_root")
	if ability == nil then return false end
	if ability:IsTrained() == false then return false end
	if ability:IsCooldownReady() == false then return false end
	if ability:IsOwnersManaEnough() == false then return false end
	if RandomInt(1, 100) > 20 then return false end

	self.parent:CastAbilityNoTarget(ability, -1)
end

function _boss_gorillaz_modifier_passive:TryCast_Skill_2()
	local ability = self.parent:FindAbilityByName("")
	local target = self.parent:GetAggroTarget()
	if target == nil then return false end
	if ability == nil then return false end
	if ability:IsTrained() == false then return false end
	if ability:IsCooldownReady() == false then return false end
	if ability:IsOwnersManaEnough() == false then return false end

	ability:CastAbility()
	return true
end

function _boss_gorillaz_modifier_passive:TryCast_Skill_3()
	local ability = self.parent:FindAbilityByName("")
	local target = self.parent:GetAggroTarget()
	if target == nil then return false end
	if ability == nil then return false end
	if ability:IsTrained() == false then return false end
	if ability:IsCooldownReady() == false then return false end
	if ability:IsOwnersManaEnough() == false then return false end

	ability:CastAbility()
	return true
end

function _boss_gorillaz_modifier_passive:TryCast_Skill_4()
	local ability = self.parent:FindAbilityByName("")
	local target = self.parent:GetAggroTarget()
	if target == nil then return false end
	if ability == nil then return false end
	if ability:IsTrained() == false then return false end
	if ability:IsCooldownReady() == false then return false end
	if ability:IsOwnersManaEnough() == false then return false end

	ability:CastAbility()
	return true
end
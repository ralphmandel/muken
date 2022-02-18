_modifier_neutral_spider = class({})

function _modifier_neutral_spider:IsHidden()
	return true
end

function _modifier_neutral_spider:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function _modifier_neutral_spider:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	if self.parent:GetUnitName() == "neutral_spider" then
		self:StartIntervalThink(1)
	end
end

function _modifier_neutral_spider:OnRefresh( kv )
end

function _modifier_neutral_spider:OnRemoved()
end

--------------------------------------------------------------------------------

function _modifier_neutral_spider:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}

	return funcs
end

function _modifier_neutral_spider:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if IsServer() then self.parent:EmitSound("Hero_Broodmother.Attack") end
end

function _modifier_neutral_spider:GetAttackSound(keys)
    return ""
end

function _modifier_neutral_spider:OnIntervalThink()
	local target = self.parent:GetAggroTarget()
	if target == nil then return end
	if self.parent:IsSilenced() then return end
	if self.parent:IsStunned() then return end

	if RandomInt(1, 100) <= 25 then
		self:TryCast_Skill_1(target)
		return
	end

	if RandomInt(1, 100) <= 50 then
		self:TryCast_Skill_2(target)
		return
	end
end

function _modifier_neutral_spider:TryCast_Skill_1(target)
	local ability = self.parent:FindAbilityByName("summon_spiders")
	if ability == nil then return end
	if ability:IsTrained() == false then return end
	if ability:IsCooldownReady() == false then return end
	if ability:IsOwnersManaEnough() == false then return end

	self.parent:SetCursorPosition(target:GetOrigin())
	ability:CastAbility()
end

function _modifier_neutral_spider:TryCast_Skill_2(target)
	local ability = self.parent:FindAbilityByName("venom_aoe")
	if ability == nil then return end
	if ability:IsTrained() == false then return end
	if ability:IsCooldownReady() == false then return end
	if ability:IsOwnersManaEnough() == false then return end

	local distance = CalcDistanceBetweenEntityOBB( self.parent, target)
	local cast_range = ability:GetCastRange(self.parent:GetOrigin(), target)
	if distance > cast_range then return end

	self.parent:SetCursorPosition(target:GetOrigin())
	ability:CastAbility()
end
_modifier_neutral_igneo = class({})

function _modifier_neutral_igneo:IsHidden()
	return true
end

function _modifier_neutral_igneo:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function _modifier_neutral_igneo:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self:StartIntervalThink(1)
end

function _modifier_neutral_igneo:OnRefresh( kv )
end

function _modifier_neutral_igneo:OnRemoved()
end

--------------------------------------------------------------------------------

function _modifier_neutral_igneo:DeclareFunctions()
	local funcs = {
	}

	return funcs
end

function _modifier_neutral_igneo:OnIntervalThink()
	local target = self.parent:GetAggroTarget()
	if target == nil then return end
	if self.parent:IsSilenced() then return end
	if self.parent:IsStunned() then return end
	if self.parent:IsDominated() then return end

	if RandomFloat(0, 100) < 10 then
		self:TryCast_Skill_1(target)
	end
end

function _modifier_neutral_igneo:TryCast_Skill_1(target)
	local ability = self.parent:FindAbilityByName("doom")
	if ability == nil then return end
	if ability:IsTrained() == false then return end
	if ability:IsCooldownReady() == false then return end
	if ability:IsOwnersManaEnough() == false then return end

	local distance = CalcDistanceBetweenEntityOBB(self.parent, target)
	local cast_range = ability:GetCastRange(self.parent:GetOrigin(), target)
	if distance > cast_range then return end

	if target:IsMagicImmune() then return end

	self.parent:SetCursorCastTarget(target)
	--ability:CastAbility()

	self.parent:CastAbilityOnTarget(target, ability, self.parent:GetPlayerOwnerID())
end
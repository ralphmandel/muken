_modifier_neutral_dragon = class({})

function _modifier_neutral_dragon:IsHidden()
	return true
end

function _modifier_neutral_dragon:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function _modifier_neutral_dragon:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self:StartIntervalThink(1)
end

function _modifier_neutral_dragon:OnRefresh( kv )
end

function _modifier_neutral_dragon:OnRemoved()
end

--------------------------------------------------------------------------------

function _modifier_neutral_dragon:DeclareFunctions()
	local funcs = {
	}

	return funcs
end

function _modifier_neutral_dragon:OnIntervalThink()
	local target = self.parent:GetAggroTarget()
	if target == nil then return end
	if self.parent:IsSilenced() then return end
	if self.parent:IsStunned() then return end

	if RandomInt(1, 100) <= 35 then
		self:TryCast_Skill_1(target)
		return
	end
end

function _modifier_neutral_dragon:TryCast_Skill_1(target)
	local ability = self.parent:FindAbilityByName("immunity")
	if ability == nil then return end
	if ability:IsTrained() == false then return end
	if ability:IsCooldownReady() == false then return end
	if ability:IsOwnersManaEnough() == false then return end

	ability:CastAbility()
end
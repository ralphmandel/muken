_modifier_neutral_frostbitten = class({})

function _modifier_neutral_frostbitten:IsHidden()
	return true
end

function _modifier_neutral_frostbitten:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function _modifier_neutral_frostbitten:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
  self.try_sk1 = false

	self:StartIntervalThink(1)
end

function _modifier_neutral_frostbitten:OnRefresh( kv )
end

function _modifier_neutral_frostbitten:OnRemoved()
end

--------------------------------------------------------------------------------

function _modifier_neutral_frostbitten:DeclareFunctions()
	local funcs = {
	}

	return funcs
end

function _modifier_neutral_frostbitten:OnIntervalThink()
	local target = self.parent:GetAggroTarget()
	if target == nil then return end
	if self.parent:IsSilenced() then return end
	if self.parent:IsStunned() then return end
	if self.parent:IsDominated() then return end

	if RandomFloat(1, 100) < 10 then
		self.try_sk1 = true
	end

  if self.try_sk1 == true then
    self:TryCast_Skill_1()
  end
end

function _modifier_neutral_frostbitten:TryCast_Skill_1()
	local ability = self.parent:FindAbilityByName("smash")
	if ability == nil then return end
	if ability:IsTrained() == false then return end
	if ability:IsCooldownReady() == false then return end
	if ability:IsOwnersManaEnough() == false then return end

  local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, ability:GetSpecialValueFor("stun_radius") - 50,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false
	)

	for _,enemy in pairs(enemies) do
    self.parent:CastAbilityNoTarget(ability, self.parent:GetPlayerOwnerID())
    self.try_sk1 = false
    break
	end
end
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
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function _boss_gorillaz_modifier_passive:OnTakeDamage(keys)
	--if keys.unit ~= self.parent then return end
	--if keys.attacker == nil then return end
	--if keys.attacker:IsBaseNPC() == false then return end
end

function _boss_gorillaz_modifier_passive:OnIntervalThink()
	local target = self.parent:GetAggroTarget()
	if target == nil then return end
	if self.parent:IsSilenced() then return end
	if self.parent:IsStunned() then return end
	if self.parent:IsDominated() then return end

	--if RandomInt(1, 100) <= 15 then
		--self:TryCast_Skill_1(target)
		--return
	--end
end

function _boss_gorillaz_modifier_passive:TryCast_Skill_1(target)
	local ability = self.parent:FindAbilityByName("spike_armor")
	if ability == nil then return end
	if ability:IsTrained() == false then return end
	if ability:IsCooldownReady() == false then return end
	if ability:IsOwnersManaEnough() == false then return end

	ability:CastAbility()
end
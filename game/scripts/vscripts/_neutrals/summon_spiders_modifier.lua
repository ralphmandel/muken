summon_spiders_modifier = class({})

function summon_spiders_modifier:IsHidden()
	return true
end

function summon_spiders_modifier:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function summon_spiders_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.target = nil

	if IsServer() then self:StartIntervalThink(0.1) end
end

function summon_spiders_modifier:OnRefresh( kv )
end

function summon_spiders_modifier:OnRemoved()
	if self.parent:IsAlive() then self.parent:ForceKill(false) end
end

--------------------------------------------------------------------------------

function summon_spiders_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}

	return funcs
end

function summon_spiders_modifier:OnDeath(keys)
	if keys.unit == self.caster then self:Destroy() end
end

function summon_spiders_modifier:OnAttackLanded(keys)
	if keys.attacker ~= self.unit then return end
	if IsServer() then self.unit:EmitSound("Hero_Broodmother.Attack") end
end

function summon_spiders_modifier:GetAttackSound(keys)
    return ""
end

function summon_spiders_modifier:OnIntervalThink()
	if self.target then
		if IsValidEntity(self.target) then
			if self.target:IsAlive() then
				if IsServer() then self:StartIntervalThink(0.1) end
				return
			end
		end
	end

	self:ChangeTarget()
	if IsServer() then self:StartIntervalThink(0.1) end
end

function summon_spiders_modifier:ChangeTarget()
	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, 250,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0, 0, false
	)

	for _,enemy in pairs(enemies) do
		self.target = enemy
		self.parent:SetForceAttackTarget(self.target)
		return
	end
end
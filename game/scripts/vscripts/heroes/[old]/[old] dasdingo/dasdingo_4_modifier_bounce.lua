dasdingo_4_modifier_bounce = class({})

function dasdingo_4_modifier_bounce:IsHidden()
	return true
end

function dasdingo_4_modifier_bounce:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function dasdingo_4_modifier_bounce:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.bounces = 4
	-- self.reduction = self.ability:GetSpecialValueFor( "damage_reduction_percent")
	-- self.reduction = (100-self.reduction)/100
	self.bounce = 0
	self.targets = {}
	
	self.parent:SetOrigin(self.parent:GetOrigin() + Vector(0, 0, 100))
	self.parent:SetAttackCapability(self.caster:GetAttackCapability())
	self.parent:SetRangedProjectileName(self.caster:GetRangedProjectileName())

	local units = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, 1,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
		DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false
	)

	for _,unit in pairs(units) do
		table.insert(self.targets, unit)
		break
	end

	self:Attack()
end

function dasdingo_4_modifier_bounce:OnRemoved()
end

function dasdingo_4_modifier_bounce:OnDestroy()
	if not IsServer() then return end
	UTIL_Remove(self:GetParent())
end

--------------------------------------------------------------------------------

function dasdingo_4_modifier_bounce:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS
	}

	return funcs
end

function dasdingo_4_modifier_bounce:GetModifierProjectileSpeedBonus()
	return 600
end

function dasdingo_4_modifier_bounce:GetModifierProcAttack_Feedback(keys)
	self.ability.sound = true
	--self.ability.outgoing = math.pow(self.reduction, 2 + self.bounce)*100 - 100
	self.caster:PerformAttack(keys.target, false, false, true, true, false, false, true)
	self.ability.sound = nil
	--self.ability.outgoing = 0

	self.parent:SetOrigin(keys.target:GetOrigin() + Vector( 0, 0, 100 ))
	if IsServer() then self.parent:EmitSound("Hero_WitchDoctor_Ward.ProjectileImpact") end

	if self.bounce >= self.bounces then
		self:Destroy()
	else
		self:StartIntervalThink(0.05)
	end
end

function dasdingo_4_modifier_bounce:OnAttackFail(keys)
	if keys.attacker == self.parent then
		if keys.target ~= nil then
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_MISS, keys.target, 0, keys.target)
		end
		self:Destroy()
	end
end

function dasdingo_4_modifier_bounce:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end


function dasdingo_4_modifier_bounce:OnIntervalThink()
	self:StartIntervalThink(-1)
	self:Attack()
end

--------------------------------------------------------------------------------

function dasdingo_4_modifier_bounce:Attack()
	self.bounce = self.bounce+1

	local units = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.caster:GetBaseAttackRange(),
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
		DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false
	)

	for _,unit in pairs(units) do
		local new = true
		for _,target in pairs(self.targets) do
			if unit == target then
				new = false
			end
		end

		if new == true then
			table.insert(self.targets, unit)
			self.parent:PerformAttack(unit, false, true, true, true, true, true, false)
			return
		end
	end

	self:Destroy()
end
ancient_1_modifier_punch = class({})

function ancient_1_modifier_punch:IsHidden()
	return true
end

function ancient_1_modifier_punch:IsDebuff()
	return true
end

function ancient_1_modifier_punch:IsStunDebuff()
	return true
end

function ancient_1_modifier_punch:IsPurgable()
	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_1_modifier_punch:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.direction = self.caster:GetForwardVector()
	self.init_pos = self.parent:GetOrigin()
	self.speed = 900
	self.damage = 0

	if IsServer() then
		self.projectile = kv.projectile
		self.parent:SetForwardVector(-self.direction)

		if self:ApplyHorizontalMotionController() == false then
			self:Destroy()
		end
	end
end

function ancient_1_modifier_punch:OnRefresh(kv)
end

function ancient_1_modifier_punch:OnRemoved()
	if not IsServer() then return end
	self.parent:InterruptMotionControllers(false)

	if self.damage > 0 then
		if IsServer() then self.parent:EmitSound("Hero_Mars.Spear.Knockback") end
		local base_stats = self.caster:FindAbilityByName("base_stats")
		if base_stats then base_stats:SetForceCritSpell(0, true, self.ability:GetAbilityDamageType()) end       

		self.ability.pinned = true

		ApplyDamage({
			attacker = self.caster, victim = self.parent,
			ability = self.ability, damage = self.damage,
			damage_type = self.ability:GetAbilityDamageType()
		})

		self.ability.pinned = false
	end

	FindClearSpaceForUnit(self.parent, self.parent:GetOrigin(), false)
end

function ancient_1_modifier_punch:OnDestroy()
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_1_modifier_punch:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

function ancient_1_modifier_punch:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function ancient_1_modifier_punch:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

-- MOTIONS -----------------------------------------------------------

function ancient_1_modifier_punch:UpdateHorizontalMotion(me, dt)
	local target = me:GetOrigin() + self.direction * self.speed * dt
	me:SetOrigin(target)

	self:CheckObstructions()
end

function ancient_1_modifier_punch:OnHorizontalMotionInterrupted()
	if IsServer() then
		self:Destroy()
	end
end

-- UTILS -----------------------------------------------------------

function ancient_1_modifier_punch:CheckObstructions()
	local tree_radius = 120
	local wall_radius = 50
	local building_radius = 30

	-- search for high ground
	local base_loc = GetGroundPosition(self.parent:GetOrigin(), self.parent)
	local search_loc = GetGroundPosition(base_loc + self.direction * wall_radius, self.parent)
	if search_loc.z - base_loc.z > 10 and (not GridNav:IsTraversable(search_loc)) then
		self:CalcStun()
		return
	end

	-- search for tree
	if GridNav:IsNearbyTree(self.parent:GetOrigin(), tree_radius, false) then
		self:CalcStun()
		return
	end

	-- search for buildings
	local buildings = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, building_radius,
		DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BUILDING,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
		0, false
	)

	if #buildings>0 then
		self:CalcStun()
		return
	end
end

function ancient_1_modifier_punch:CalcStun()
	self.damage = (self.init_pos - self.parent:GetOrigin()):Length2D() * 0.2
	self:Destroy()
end
bocuse_u_modifier_rage = class({})

function bocuse_u_modifier_rage:IsHidden()
	return false
end

function bocuse_u_modifier_rage:IsPurgable()
	return false
end

function bocuse_u_modifier_rage:IsDebuff()
	return false
end

function bocuse_u_modifier_rage:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_u_modifier_rage:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.stop = false
	self.extra_damage = 0
	self.autocasted = kv.autocasted or 0
	self.status = self.ability:GetSpecialValueFor("status")

	self.ability:SetActivated(false)
	self.ability:EndCooldown()

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "bocuse_u_modifier_rage_status_efx", true) end

	self:CheckAggro()
	self:StartSlash()
    self:PlayEfxStart()
end

function bocuse_u_modifier_rage:OnRefresh(kv)
end

function bocuse_u_modifier_rage:OnRemoved()
	self.parent:FadeGesture(ACT_DOTA_CHANNEL_ABILITY_4)
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "bocuse_u_modifier_rage_status_efx", false) end

	local cooldown = self.ability:GetEffectiveCooldown(self.ability:GetLevel())
	self.ability:SetActivated(true)
    if self.autocasted == 0 then
		self.ability:StartCooldown(cooldown)
		self:StartExhaustion()
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_u_modifier_rage:CheckState()
	local state = {
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_CLIFFS] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = true,
		[MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_FROZEN] = false
	}

	return state
end

function bocuse_u_modifier_rage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_STATE_CHANGED
	}

	return funcs
end

function bocuse_u_modifier_rage:GetModifierStatusResistanceStacking()
	return self.status
end

function bocuse_u_modifier_rage:OnOrder(keys)
	if keys.unit ~= self.parent then return end
    if keys.order_type ~= DOTA_UNIT_ORDER_ATTACK_TARGET then return end
    local target = keys.target

    Timers:CreateTimer((FrameTime()), function()
        if target and self then
            if (self.parent:GetOrigin() - target:GetOrigin()):Length2D() > self.parent:Script_GetAttackRange() then
                local direction = (self.parent:GetOrigin() - target:GetOrigin()):Normalized() * self.parent:Script_GetAttackRange()
                local point = target:GetOrigin() + direction
                self.parent:MoveToPosition(point)
            else
                self.parent:Stop()
            end
        end
    end)
end

function bocuse_u_modifier_rage:OnDeath(keys)
    if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
    if keys.attacker ~= self.parent then return end
    if keys.unit:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if keys.unit:IsHero() == false then return end
	if keys.unit:IsIllusion() then return end
	if self.autocasted == 1 then return end

	-- UP 6.31
	if self.ability:GetRank(31) then
		local duration = self.ability:CalcStatus(self.ability:GetSpecialValueFor("duration"), self.parent, self.parent)
		self:SetDuration(duration, true)
		self.extra_damage = self.extra_damage + 10
		self:PlayEfxStart()
	end
end

function bocuse_u_modifier_rage:OnStateChanged(keys)
    if keys.unit ~= self.parent then return end
    if self.parent:IsHexed() == true and self.stop == false then
       self.stop = true
       self:StartIntervalThink(-1)
    end

    if self.parent:IsHexed() == false and self.stop == true then
        self.stop = false
        self:StartSlash()
     end
end

function bocuse_u_modifier_rage:OnIntervalThink()
	if self.init then
		self.init = false
        self.parent:FadeGesture(1728)
        self.parent:StartGestureWithPlaybackRate(ACT_DOTA_CHANNEL_ABILITY_4, self.speed)
	end

	local radius = self.parent:Script_GetAttackRange() + 80
	local angle = self.ability:GetSpecialValueFor("angle")
	local cast_direction = self.parent:GetForwardVector():Normalized()
	local cast_angle = VectorToAngles(cast_direction).y

	self:FindTrees(radius, angle, cast_angle)
	self:FindEnemies(radius, angle, cast_direction, cast_angle)
	self:SetSlashSpeed()
end

-- UTILS -----------------------------------------------------------

function bocuse_u_modifier_rage:CheckAggro()
	local target = self.parent:GetAttackTarget()
    if target == nil then target = self.parent:GetAggroTarget() end
    if target then
        self.parent:Stop()
        if (self.parent:GetOrigin() - target:GetOrigin()):Length2D() > self.parent:Script_GetAttackRange() then
            local direction = (self.parent:GetOrigin() - target:GetOrigin()):Normalized() * self.parent:Script_GetAttackRange()
            local point = target:GetOrigin() + direction
            self.parent:MoveToPosition(point)
        end
    end
end

function bocuse_u_modifier_rage:StartSlash()
    local speed_mult = 1 + ((self.ability:GetSpecialValueFor("speed_mult") - 100) * 0.01)
	local gesture_cycle = 1.5
    self.speed = gesture_cycle * speed_mult

    self.hits = {
        [1] = {[1] = 1, [2] = 0.35 / speed_mult},
        [2] = {[1] = 2, [2] = 0.35 / speed_mult},
        [3] = {[1] = 3, [2] = 0.5 / speed_mult},
        [4] = {[1] = 4, [2] = 0.3 / speed_mult}
    }

    self.state_hit = self.hits[1]
    
    self.init = true
    self.parent:StartGestureWithPlaybackRate(1728, 3)
    if IsServer() then self:StartIntervalThink(0.5) end
end

function bocuse_u_modifier_rage:SetSlashSpeed()
	for i = 1, 4, 1 do
        if self.state_hit[1] == self.hits[i][1] then
            if self.hits[i][1] == self.hits[4][1] then
                self.state_hit = self.hits[1]
            else
                self.state_hit = self.hits[i + 1]
            end
            break
        end
    end

    if IsServer() then self:StartIntervalThink(self.state_hit[2]) end
end

function bocuse_u_modifier_rage:FindTrees(radius, angle, cast_angle)
	local trees = GridNav:GetAllTreesAroundPoint(self.parent:GetOrigin(), radius, false)
	if trees == nil then return end

	for _,tree in pairs(trees) do
		local tree_direction = (tree:GetOrigin() - self.parent:GetOrigin()):Normalized()
		local tree_angle = VectorToAngles(tree_direction).y
		local angle_diff = math.abs(AngleDiff(cast_angle, tree_angle))

		if angle_diff <= angle then tree:CutDown(self.parent:GetTeamNumber()) end
	end
end

function bocuse_u_modifier_rage:FindEnemies(radius, angle, cast_direction, cast_angle)
    local enemies = FindUnitsInRadius(
        self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	0, false
    )

	for _,enemy in pairs(enemies) do
        local enemy_direction = (enemy:GetOrigin() - self.parent:GetOrigin()):Normalized()
        local enemy_angle = VectorToAngles(enemy_direction).y
        local angle_diff = math.abs(AngleDiff(cast_angle, enemy_angle))

        if angle_diff <= angle then
			self:HitTarget(enemy, cast_direction)
        end
    end
end

function bocuse_u_modifier_rage:HitTarget(target, direction)
	if target:IsInvulnerable() then return end
	if target:IsAttackImmune() then return end

	local damage_min = self.ability:GetSpecialValueFor("damage_min")
    local damage_max = self.ability:GetSpecialValueFor("damage_max")

	ApplyDamage({
		damage = RandomInt(damage_min, damage_max) + self.extra_damage,
		attacker = self.parent, victim = target,
		damage_type = self.ability:GetAbilityDamageType(),
		ability = self.ability
	})

	self:ApplyMark(target)
	self:PlayEfxHit(target, self.parent:GetOrigin(), direction)

	-- UP 6.21
	if self.ability:GetRank(21) then
		self:ApplyBleeding(target)
	end

	-- UP 6.41
	if self.ability:GetRank(41) then
		self:ApplyStun(target)
	end
end

function bocuse_u_modifier_rage:ApplyMark(target)
	local mark = self.parent:FindAbilityByName("bocuse_3__mark")
	if mark == nil then return end
	if mark:IsTrained() == false then return end
	
	mark:ApplyMark(target)
end

function bocuse_u_modifier_rage:ApplyBleeding(target)
	local cut = self.parent:FindAbilityByName("bocuse_1__cut")
	if cut == nil then return end
	if cut:IsTrained() == false then return end
	
	cut:ApplyBleeding(target)
end

function bocuse_u_modifier_rage:ApplyStun(target)
	if target:IsAlive() == false then return end

	if RandomFloat(1, 100) <= 50 then
		target:AddNewModifier(self.caster, self.ability, "_modifier_stun", {duration = 0.1})
	end
end

function bocuse_u_modifier_rage:StartExhaustion()
	-- UP 6.12
	if self.ability:GetRank(12) then
		self.parent:AddNewModifier(self.caster, self.ability, "bocuse_u_modifier_exhaustion", {
			duration = 4 * (1 - self.parent:GetStatusResistance())
		})
	end
end

-- EFFECTS -----------------------------------------------------------

function bocuse_u_modifier_rage:GetStatusEffectName()
	return "particles/econ/items/invoker/invoker_ti7/status_effect_alacrity_ti7.vpcf"
end

function bocuse_u_modifier_rage:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function bocuse_u_modifier_rage:PlayEfxStart()
    local particle_cast = "particles/econ/items/doom/doom_ti8_immortal_arms/doom_ti8_immortal_devour.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())

    if self.effect_cast ~= nil then ParticleManager:DestroyParticle(self.effect_cast, true) end
    local particle_cast_1 = "particles/econ/items/pudge/pudge_immortal_arm/pudge_immortal_arm_rot.vpcf"
	self.effect_cast = ParticleManager:CreateParticle(particle_cast_1, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.effect_cast, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)
	self:AddParticle(self.effect_cast, false, false, -1, false, false)

    if self.effect_cast2 ~= nil then ParticleManager:DestroyParticle(self.effect_cast2, true) end
    local particle_cast_2 = "particles/econ/items/ogre_magi/ogre_ti8_immortal_weapon/ogre_ti8_immortal_bloodlust_buff.vpcf"
	self.effect_cast2 = ParticleManager:CreateParticle(particle_cast_2, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.effect_cast2, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)
	self:AddParticle(self.effect_cast2, false, false, -1, false, false)

    if IsServer() then self.parent:EmitSound("Hero_Alchemist.ChemicalRage.Cast") end
end

function bocuse_u_modifier_rage:PlayEfxHit(target, origin, direction)
    local particle_cast = "particles/units/heroes/hero_grimstroke/grimstroke_cast2_ground.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())

	particle_cast = "particles/units/heroes/hero_mars/mars_shield_bash_crit.vpcf"
	effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, target)
	ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, target:GetOrigin())
	ParticleManager:SetParticleControlForward(effect_cast, 1, direction)
	ParticleManager:ReleaseParticleIndex(effect_cast)

    if IsServer() then target:EmitSound("Hero_Alchemist.ChemicalRage.Attack") end
end
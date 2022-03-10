bocuse_u_modifier_mise = class ({})

function bocuse_u_modifier_mise:IsHidden()
    return false
end

function bocuse_u_modifier_mise:IsPurgable()
    return false
end

-----------------------------------------------------------

function bocuse_u_modifier_mise:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

    self.damage_min = self.ability:GetSpecialValueFor("damage_min")
    self.damage_max = self.ability:GetSpecialValueFor("damage_max")
	self.angle = self.ability:GetSpecialValueFor("angle")
    self.stun_chance = self.ability:GetSpecialValueFor("stun_chance")
    self.extra_damage = 0
    self.reset = true
    self.number_of_hits = kv.number_of_hits or -1

    self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {percent = 15})

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

    -- UP 4.2
	if self.ability:GetRank(2) then
		self.ability:AddBonus("_1_CON", self.parent, 25, 0, nil)
	end

    self.speed = 1.5
    self.hits = {
        [1] = {[1] = 1, [2] = 0.35},
        [2] = {[1] = 2, [2] = 0.35},
        [3] = {[1] = 3, [2] = 0.5},
        [4] = {[1] = 4, [2] = 0.3}
    }

    -- UP 4.5
    if self.ability:GetRank(5) then
        self.speed = 2.25
        self.stun_chance = self.stun_chance - 20
        self.hits = {
            [1] = {[1] = 1, [2] = 0.23},
            [2] = {[1] = 2, [2] = 0.23},
            [3] = {[1] = 3, [2] = 0.34},
            [4] = {[1] = 4, [2] = 0.2}
        }
    end

    self.state_hit = self.hits[1]
    
    self.delay = true
    self.parent:StartGestureWithPlaybackRate(1728, 3)
    self:StartIntervalThink(0.5)
    self:PlayEfxStart()
end

function bocuse_u_modifier_mise:OnRefresh(kv)
end

function bocuse_u_modifier_mise:OnRemoved()
    self.ability:RemoveBonus("_1_CON", self.parent)
    self.parent:FadeGesture(ACT_DOTA_CHANNEL_ABILITY_4)
    self.ability:SetActivated(true)

    local cd = self.ability:GetEffectiveCooldown(self.ability:GetLevel())
    if self.reset == false then
        cd = cd * 0.25
    end

    self.ability:StartCooldown(cd)

    local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

------------------------------------------------------------

function bocuse_u_modifier_mise:CheckState()
	local state = {
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_CLIFFS] = true,
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = true,
		[MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_FROZEN] = false
	}

	return state
end

function bocuse_u_modifier_mise:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function bocuse_u_modifier_mise:DeclareFunctions()
	local funcs = {
        MODIFIER_EVENT_ON_ORDER,
		MODIFIER_EVENT_ON_HERO_KILLED
	}

	return funcs
end

function bocuse_u_modifier_mise:OnOrder(keys)
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

function bocuse_u_modifier_mise:OnHeroKilled(keys)
    if keys.attacker ~= self.parent then return end
    if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end

    self:SetDuration(self:GetDuration(), true)
    
    local con = self.parent:FindAbilityByName("_1_CON")
	if con ~= nil then con:BonusPermanent(1) end

    local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(nFXIndex, 1, Vector(1, 0, 0))
    ParticleManager:ReleaseParticleIndex(nFXIndex)

    local heal = self.ability:GetSpecialValueFor("heal")

    -- UP 4.6
    if self.ability:GetRank(6) then
        self.extra_damage = self.extra_damage + 15
        heal = heal + 10
    end

    local total_heal = heal * keys.target:GetMaxHealth() * 0.01
    if total_heal > 0 then self.parent:Heal(total_heal, self.ability) end

    self:PlayEfxStart()
end

function bocuse_u_modifier_mise:OnIntervalThink()
    if self.delay == true then
        self.delay = false
        self.parent:FadeGesture(1728)
        self.parent:StartGestureWithPlaybackRate(ACT_DOTA_CHANNEL_ABILITY_4, self.speed)
        self:StartIntervalThink(0.05)
        return
    end

    local radius = self.parent:Script_GetAttackRange() + 80

    local enemies = FindUnitsInRadius(
        self.parent:GetTeamNumber(),	-- int, your team number
        self.parent:GetOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
        0,	-- int, order filter
        false	-- bool, can grow cache
    )

    -- precache
    local origin = self.parent:GetOrigin()
    local cast_direction = self.parent:GetForwardVector():Normalized()
    local cast_angle = VectorToAngles( cast_direction ).y

    for _,enemy in pairs(enemies) do
        -- check within cast angle
        local enemy_direction = (enemy:GetOrigin() - origin):Normalized()
        local enemy_angle = VectorToAngles( enemy_direction ).y
        local angle_diff = math.abs( AngleDiff( cast_angle, enemy_angle ) )
        if angle_diff<=self.angle then
            if enemy:IsInvulnerable() == false
            and enemy:IsAttackImmune() == false then
                local damage = RandomInt(self.damage_min, self.damage_max) + self.extra_damage
                local damageTable = {
                    victim = enemy,
                    attacker = self.parent,
                    damage = damage,
                    damage_type = DAMAGE_TYPE_PHYSICAL,
                    ability = self.ability
                }

                ApplyDamage(damageTable)
                self:PlayEfxHit( enemy, origin, cast_direction )

                if RandomInt(1, 100) <= self.stun_chance then
                    enemy:AddNewModifier(self.caster, self.ability, "_modifier_stun", {duration = 0.1})
                end

                -- UP 4.3
                if self.ability:GetRank(3) then
                    enemy:AddNewModifier(self.caster, self.ability, "_modifier_break", {duration = 1})
                end
            end
        end
    end

    local trees = GridNav:GetAllTreesAroundPoint(self.parent:GetOrigin(), radius, false)

    if trees then
        for _,tree in pairs(trees) do
            -- check within cast angle
            local tree_direction = (tree:GetOrigin() - origin):Normalized()
            local tree_angle = VectorToAngles(tree_direction).y
            local angle_diff = math.abs(AngleDiff(cast_angle, tree_angle))
            if angle_diff<=self.angle then
                tree:CutDown(self.parent:GetTeamNumber())
            end
        end
    end

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

    if self.number_of_hits > 0 then
        self.number_of_hits = self.number_of_hits - 1
    elseif self.number_of_hits == 0 then
        self.reset = false
        self:Destroy()
        return
    end

    self:StartIntervalThink(self.state_hit[2])
end

--------------------------------------------------------------------------------

function bocuse_u_modifier_mise:GetStatusEffectName()
	return "particles/econ/items/invoker/invoker_ti7/status_effect_alacrity_ti7.vpcf"
end

function bocuse_u_modifier_mise:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function bocuse_u_modifier_mise:PlayEfxStart()
    if IsServer() then self.parent:EmitSound("Hero_Alchemist.ChemicalRage.Cast") end

    particle_cast = "particles/econ/items/doom/doom_ti8_immortal_arms/doom_ti8_immortal_devour.vpcf"
	effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, self.parent )
	ParticleManager:SetParticleControl( effect_cast, 0, self.parent:GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, self.parent:GetOrigin() )

    if self.effect_cast ~= nil then ParticleManager:DestroyParticle(self.effect_cast, true) end
    local particle_cast_1 = "particles/econ/items/pudge/pudge_immortal_arm/pudge_immortal_arm_rot.vpcf"
	self.effect_cast = ParticleManager:CreateParticle( particle_cast_1, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt(
		self.effect_cast,
		0,
		self.parent,
		PATTACH_ABSORIGIN_FOLLOW,
		"",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)

	-- buff particle
	self:AddParticle(
		self.effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

    if self.effect_cast2 ~= nil then ParticleManager:DestroyParticle(self.effect_cast2, true) end
    local particle_cast_2 = "particles/econ/items/ogre_magi/ogre_ti8_immortal_weapon/ogre_ti8_immortal_bloodlust_buff.vpcf"
	self.effect_cast2 = ParticleManager:CreateParticle( particle_cast_2, PATTACH_POINT_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt(
		self.effect_cast2,
		0,
		self.parent,
		PATTACH_ABSORIGIN_FOLLOW,
		"",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)

	-- buff particle
	self:AddParticle(
		self.effect_cast2,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
end

function bocuse_u_modifier_mise:PlayEfxHit( target, origin, direction )
    local particle_cast = "particles/units/heroes/hero_grimstroke/grimstroke_cast2_ground.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl( effect_cast, 0, target:GetOrigin() )

	particle_cast = "particles/units/heroes/hero_mars/mars_shield_bash_crit.vpcf"
	effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, target )
	ParticleManager:SetParticleControl( effect_cast, 0, target:GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast, 1, direction )
	ParticleManager:ReleaseParticleIndex( effect_cast )

    if IsServer() then target:EmitSound("Hero_Alchemist.ChemicalRage.Attack") end
end
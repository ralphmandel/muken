bocuse_u_modifier_mise = class ({})

function bocuse_u_modifier_mise:IsHidden()
    return false
end

function bocuse_u_modifier_mise:IsPurgable()
    return false
end

function bocuse_u_modifier_mise:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
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
    self.reset = kv.reset or 0
    self.stop = false

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

    self:StartSlash()
    self:PlayEfxStart()

    local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect("bocuse_u_modifier_mise_status_efx", true) end
end

function bocuse_u_modifier_mise:OnRefresh(kv)
end

function bocuse_u_modifier_mise:OnRemoved()
    self.parent:FadeGesture(ACT_DOTA_CHANNEL_ABILITY_4)
    self.ability:SetActivated(true)

    local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect("bocuse_u_modifier_mise_status_efx", false) end

    if self.reset == 1 then return end
    self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))

    -- UP 4.22
    if self.ability:GetRank(22) then
        local stun_duration = 4
        self.parent:AddNewModifier(self.caster, self.ability, "bocuse_u_modifier_exhaustion", {
            duration = self.ability:CalcStatus(stun_duration, nil, self.parent)
        })

        self:PlayEfxBlast()

        local damageTable = {
            damage = 100,
            attacker = self.parent,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self.ability
        }

        local enemies = FindUnitsInRadius(
            self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, self.ability:GetCastRange(self.parent:GetOrigin(), nil),
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	0, false
        )

        for _,enemy in pairs(enemies) do
            if enemy:IsMagicImmune() == false then
                damageTable.victim = enemy
                ApplyDamage(damageTable)
            end

            if enemy:IsAlive() then
                enemy:AddNewModifier(self.caster, self.ability, "_modifier_stun", {
                    duration = self.ability:CalcStatus(stun_duration, self.caster, enemy)
                })
            end
        end
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

function bocuse_u_modifier_mise:DeclareFunctions()
	local funcs = {
        MODIFIER_EVENT_ON_ORDER,
		MODIFIER_EVENT_ON_DEATH,
        MODIFIER_EVENT_ON_STATE_CHANGED
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

function bocuse_u_modifier_mise:OnDeath(keys)
    if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
    if keys.attacker ~= self.parent then return end
    if keys.unit:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if keys.unit:IsIllusion() then return end

    -- UP 4.21
    if self.ability:GetRank(21) then
        local heal = keys.unit:GetMaxHealth() * 0.2
        if heal > 0 then self.parent:Heal(heal, self.ability) end
    end

    if keys.unit:IsHero() == false then return end

    local base_stats = self.parent:FindAbilityByName("base_stats")
	if base_stats then base_stats:AddBaseStat("CON", 1) end

    self:SetDuration(self:GetDuration(), true)
    self.extra_damage = self.extra_damage + self.ability:GetSpecialValueFor("bonus_damage")

    self:PlayEfxKill()
    self:PlayEfxStart()
end

function bocuse_u_modifier_mise:OnStateChanged(keys)
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
        self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	0, false
    )

    -- precache
    local origin = self.parent:GetOrigin()
    local cast_direction = self.parent:GetForwardVector():Normalized()
    local cast_angle = VectorToAngles( cast_direction ).y

    local damageTable = {
        attacker = self.parent,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        ability = self.ability
    }

    for _,enemy in pairs(enemies) do
        -- check within cast angle
        local enemy_direction = (enemy:GetOrigin() - origin):Normalized()
        local enemy_angle = VectorToAngles(enemy_direction).y
        local angle_diff = math.abs(AngleDiff(cast_angle, enemy_angle))
        if angle_diff<=self.angle then
            if enemy:IsInvulnerable() == false
            and enemy:IsAttackImmune() == false
            and self.parent:IsHexed() == false then
                damageTable.damage = RandomInt(self.damage_min, self.damage_max) + self.extra_damage
                damageTable.victim = enemy
                ApplyDamage(damageTable)

                self:PlayEfxHit( enemy, origin, cast_direction )

                -- UP 4.31
                if self.ability:GetRank(31) then
                    self.caster:FindAbilityByName("bocuse_1__julienne"):InflictBleeding(enemy)
                end

                -- UP 4.42
                if self.ability:GetRank(42)
                and RandomInt(1, 100) <= 35 then
                    enemy:AddNewModifier(self.caster, self.ability, "_modifier_stun", {duration = 0.1})
                end
            end
        end
    end

    local trees = GridNav:GetAllTreesAroundPoint(self.parent:GetOrigin(), radius, false)

    if trees then
        for _,tree in pairs(trees) do
            if self.parent:IsHexed() == false then
                -- check within cast angle
                local tree_direction = (tree:GetOrigin() - origin):Normalized()
                local tree_angle = VectorToAngles(tree_direction).y
                local angle_diff = math.abs(AngleDiff(cast_angle, tree_angle))
                if angle_diff<=self.angle then
                    tree:CutDown(self.parent:GetTeamNumber())
                end
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

    self:StartIntervalThink(self.state_hit[2])
end

function bocuse_u_modifier_mise:StartSlash()
    local speed_mult = self.ability:GetSpecialValueFor("speed_mult")
    self.speed = 1.5 * speed_mult
    self.hits = {
        [1] = {[1] = 1, [2] = 0.35 / speed_mult},
        [2] = {[1] = 2, [2] = 0.35 / speed_mult},
        [3] = {[1] = 3, [2] = 0.5 / speed_mult},
        [4] = {[1] = 4, [2] = 0.3 / speed_mult}
    }

    self.state_hit = self.hits[1]
    
    self.delay = true
    self.parent:StartGestureWithPlaybackRate(1728, 3)
    self:StartIntervalThink(0.5)
end

--------------------------------------------------------------------------------

function bocuse_u_modifier_mise:GetStatusEffectName()
	return "particles/econ/items/invoker/invoker_ti7/status_effect_alacrity_ti7.vpcf"
end

function bocuse_u_modifier_mise:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function bocuse_u_modifier_mise:PlayEfxStart()
    local particle_cast = "particles/econ/items/doom/doom_ti8_immortal_arms/doom_ti8_immortal_devour.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, self.parent )
	ParticleManager:SetParticleControl( effect_cast, 0, self.parent:GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, self.parent:GetOrigin() )

    if self.effect_cast ~= nil then ParticleManager:DestroyParticle(self.effect_cast, true) end
    local particle_cast_1 = "particles/econ/items/pudge/pudge_immortal_arm/pudge_immortal_arm_rot.vpcf"
	self.effect_cast = ParticleManager:CreateParticle( particle_cast_1, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt(self.effect_cast, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)
	self:AddParticle(self.effect_cast, false, false, -1, false, false)

    if self.effect_cast2 ~= nil then ParticleManager:DestroyParticle(self.effect_cast2, true) end
    local particle_cast_2 = "particles/econ/items/ogre_magi/ogre_ti8_immortal_weapon/ogre_ti8_immortal_bloodlust_buff.vpcf"
	self.effect_cast2 = ParticleManager:CreateParticle( particle_cast_2, PATTACH_POINT_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt(self.effect_cast2, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)
	self:AddParticle(self.effect_cast2, false, false, -1, false, false)

    if IsServer() then self.parent:EmitSound("Hero_Alchemist.ChemicalRage.Cast") end
end

function bocuse_u_modifier_mise:PlayEfxHit(target, origin, direction)
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

function bocuse_u_modifier_mise:PlayEfxKill()
    local particle_cast = "particles/econ/items/techies/techies_arcana/techies_suicide_kills_arcana.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_OVERHEAD_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())

    local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(nFXIndex, 1, Vector(1, 0, 0))
    ParticleManager:ReleaseParticleIndex(nFXIndex)
end

function bocuse_u_modifier_mise:PlayEfxBlast()
    local particle_cast = "particles/units/heroes/hero_techies/techies_blast_off.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, self.parent)
    ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
end
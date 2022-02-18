inquisitor_2_modifier_portal = class({})

function inquisitor_2_modifier_portal:OnCreated( kv )
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.expire = true
    self.flag = 0

    self.delay = false
    self:StartIntervalThink( 0.4 )

    -- UP 2.4
    if self.ability:GetRank(4) then
        self.flag = 16
    end

	-- UP 2.3
	if self.ability:GetRank(3) then
        self:PullEnemies()
	end

    self:PlayEfxStart()
end

function inquisitor_2_modifier_portal:OnRemoved()
    self:PlayEfxEnd()
end

---------------------------------------------------------------------------------

function inquisitor_2_modifier_portal:OnIntervalThink()

    if self.delay == false then
        self.delay = true
        self:StartIntervalThink(0.1)
        return
    end

    local targets = 0
	local heroes = FindUnitsInRadius(
		self.caster:GetTeamNumber(),	-- int, your team number
		self.parent:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		150,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
		DOTA_UNIT_TARGET_HERO,	-- int, type filter
		self.flag,	-- int, flag filter
		1,	-- int, order filter
		false	-- bool, can grow cache
	)

    for _,hero in pairs(heroes) do
        if targets == 0 then
            hero:AddNewModifier(self.caster, self.ability, "inquisitor_2_modifier_portal_effect", {})
            targets = targets + 1
            self.expire = false
            self:Destroy()
        end
    end
end

function inquisitor_2_modifier_portal:PullEnemies()
	local heroes = FindUnitsInRadius(
		self.caster:GetTeamNumber(),	-- int, your team number
		self.parent:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		250,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO,	-- int, type filters
		16,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

    for _,hero in pairs(heroes) do
        hero:AddNewModifier(self.caster, self.ability, "_modifier_pull", {
            duration = 0.2,
            x = self.parent:GetOrigin().x,
            y = self.parent:GetOrigin().y,
        })
    end
end

---------------------------------------------------------------------------------

function inquisitor_2_modifier_portal:PlayEfxStart()
    if self.portal_effect_cast ~= nil then ParticleManager:DestroyParticle(self.portal_effect_cast, false) end
	local particle_cast = "particles/econ/items/effigies/status_fx_effigies/aghs_statue_boss_ambient.vpcf"
	self.portal_effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.portal_effect_cast, 0, self.parent:GetOrigin())

    if IsServer() then self.parent:EmitSound("Hero_Abaddon.DeathCoil.Cast") end

    -- UP 2.1
    local fow_radius = 175
	if self.ability:GetRank(1) then
		fow_radius = fow_radius + 200
	end

    self.fow = AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), fow_radius, self:GetDuration(), false)
end

function inquisitor_2_modifier_portal:PlayEfxEnd()
    if self.portal_effect_cast ~= nil then ParticleManager:DestroyParticle(self.portal_effect_cast, false) end
    RemoveFOWViewer(self.caster:GetTeamNumber(), self.fow)
    
    if self.expire == false then
        local particle_cast = "particles/econ/events/ti9/blink_dagger_ti9_start_lvl2.vpcf"
        local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self.parent )
        ParticleManager:SetParticleControl( effect_cast, 0, self.parent:GetOrigin() )
    else
        local particle_cast = "particles/econ/events/ti9/blink_dagger_ti9_end_sparkles_outer.vpcf"
        local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self.parent )
        ParticleManager:SetParticleControl( effect_cast, 0, self.parent:GetOrigin() )

        if IsServer() then self.parent:EmitSound("Hero_Medusa.ManaShield.Off") end
    end
end
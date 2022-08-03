bocuse_x1_modifier_roux = class ({})

function bocuse_x1_modifier_roux:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

    self.radius = self.ability:GetSpecialValueFor("radius")
    self.time = 0

    self:ApplyDebuffUnits("bocuse_x1_modifier_debuff", 0.3, true)
    self:StartIntervalThink(0.2)
    self:PlayEfxStart()
end

function bocuse_x1_modifier_roux:OnRefresh(kv)
end

function bocuse_x1_modifier_roux:OnRemoved()
end

-----------------------------------------------------------

function bocuse_x1_modifier_roux:OnIntervalThink()
    self.time = self.time + 0.2

    if self.time >= 4.6 then
        if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, true) end
        local time = self.ability:GetSpecialValueFor("root_duration")
        self:ApplyDebuffUnits("_modifier_root", time, false)
    
        self:PlayEfxFinal()
        self:StartIntervalThink(-1)
        return
    end

    self:ApplyDebuffUnits("bocuse_x1_modifier_debuff", 0.3, true)
end

function bocuse_x1_modifier_roux:ApplyDebuffUnits(modifier_name, time, fixed)
    local units = FindUnitsInRadius(
		self.caster:GetTeamNumber(),	-- int, your team number
		self.parent:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,unit in pairs(units) do
        if fixed == false then
            time = self.ability:CalcStatus(time, self.caster, unit)
            unit:AddNewModifier(self.caster, self.ability, modifier_name, {duration = time, effect = 3})
        else
            unit:AddNewModifier(self.caster, self.ability, modifier_name, {duration = time})
        end
    end
end

------------------------------------------------------------

function bocuse_x1_modifier_roux:PlayEfxStart()
	local particle_cast = "particles/bocuse/bocuse_roux_aoe_mass.vpcf"
	self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast, 0, self.parent:GetOrigin())

    if IsServer() then self.parent:EmitSound("Brewmaster_Storm.Cyclone") end
end

function bocuse_x1_modifier_roux:PlayEfxFinal()
    local particle_cast = "particles/units/heroes/hero_sandking/sandking_epicenter.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(self.radius, self.radius, self.radius))

    if IsServer() then
        self.parent:EmitSound("Hero_EarthSpirit.StoneRemnant.Impact")
        self.parent:StopSound("Brewmaster_Storm.Cyclone")
    end
end
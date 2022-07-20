striker_3_modifier_portal = class({})

function striker_3_modifier_portal:IsHidden()
	return true
end

function striker_3_modifier_portal:IsPurgable()
	return false
end

function striker_3_modifier_portal:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_3_modifier_portal:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.expire = true

	self.portal_radius = self.ability:GetSpecialValueFor("portal_radius")
	local pull_radius = self.ability:GetSpecialValueFor("pull_radius")
	local fow_radius = self.ability:GetSpecialValueFor("fow_radius")

	if IsServer() then
		self:StartIntervalThink(0.4)
		self:PullEnemies(pull_radius)
		self:PlayEfxStart(fow_radius)
	end
end

function striker_3_modifier_portal:OnRefresh(kv)
end

function striker_3_modifier_portal:OnRemoved()
	self:PlayEfxEnd(self.expire)
end

-- API FUNCTIONS -----------------------------------------------------------

function striker_3_modifier_portal:OnIntervalThink()
	if IsServer() then
		self:FindHeroes()
		self:StartIntervalThink(FrameTime())
	end
end

-- UTILS -----------------------------------------------------------

function striker_3_modifier_portal:PullEnemies(pull_radius)
	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, pull_radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false
	)

    for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(self.caster, self.ability, "_modifier_pull", {
            duration = 0.2,
            x = self.parent:GetOrigin().x,
            y = self.parent:GetOrigin().y,
        })
	end
end

function striker_3_modifier_portal:FindHeroes()
	local heroes = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.portal_radius,
		DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, 0, 1, false
	)

    for _,hero in pairs(heroes) do
		local mod_string = "striker_3_modifier_debuff"
		if hero:GetTeamNumber() == self.caster:GetTeamNumber() then mod_string = "striker_3_modifier_buff" end
		hero:AddNewModifier(self.caster, self.ability, mod_string, {})
		self.expire = false
		self:Destroy()
		return
	end
end

-- EFFECTS -----------------------------------------------------------

function striker_3_modifier_portal:PlayEfxStart(fow_radius)
	local string = "particles/striker/portal/striker_portal_ambient.vpcf"
	self.particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.particle, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.particle, 1, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(self.particle)

	self.fow = AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), fow_radius, self:GetDuration(), false)
	if IsServer() then self.parent:EmitSound("Hero_Abaddon.DeathCoil.Cast") end
end

function striker_3_modifier_portal:PlayEfxEnd(bExpire)
    if self.particle then ParticleManager:DestroyParticle(self.particle, false) end
    RemoveFOWViewer(self.caster:GetTeamNumber(), self.fow)
    
    if bExpire then
        local string = "particles/econ/events/ti9/blink_dagger_ti9_end_sparkles_outer.vpcf"
        local particle = ParticleManager:CreateParticle(string, PATTACH_WORLDORIGIN, self.parent)
        ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())

        if IsServer() then self.parent:EmitSound("Hero_TemplarAssassin.Meld.Move") end
    else
		local string = "particles/econ/events/fall_2021/blink_dagger_fall_2021_end.vpcf"
        local particle = ParticleManager:CreateParticle(string, PATTACH_WORLDORIGIN, self.parent)
        ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
    end
end
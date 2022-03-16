inquisitor_x1_modifier_hammer = class({})

function inquisitor_x1_modifier_hammer:IsHidden()
	return true
end

function inquisitor_x1_modifier_hammer:IsPurgable()
    return true
end

function inquisitor_x1_modifier_hammer:IsDebuff()
	return true
end

--------------------------------------------------------------------------

function inquisitor_x1_modifier_hammer:OnCreated( kv )
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.radius = self.ability:GetAOERadius()

    local stack = self.caster:GetModifierStackCount("_1_AGI_modifier", self.caster) * 0.75
    if stack > 90 then stack = 90 end
    stack = stack * 0.01
    self.delay = self.ability:GetSpecialValueFor( "delay" )
    self.delay = self.delay - (self.delay * stack)
    self.time = 0

    self:StartIntervalThink(0.1)
    self:PlayEfxStart()
end

function inquisitor_x1_modifier_hammer:OnRefresh( kv )
end

function inquisitor_x1_modifier_hammer:OnRemoved()
    if self.effect_cast ~= nil then ParticleManager:DestroyParticle(self.effect_cast, false) end
    if IsServer() then StopSoundOn("Hero_Nevermore.RequiemOfSoulsCast", self.parent) end

    if self.time < self.delay then return end 
    
    local level = 1

    -- Stop if blocked by linken
	if self.parent:GetTeamNumber()~= self.caster:GetTeamNumber() then
		if self.parent:TriggerSpellAbsorb( self ) then return end
	end	

    if self.caster:GetLevel() % 2 == 0 and self.parent:GetLevel() % 3 == 0 then level = level + 1 end
    if self.caster:GetLevel() % 3 == 0 and self.parent:GetLevel() % 2 == 0 then level = level + 1 end
    
    local damage = self.ability:GetSpecialValueFor( "damage" ) * level
    local stun = self.ability:GetSpecialValueFor( "stun" ) * level

    local damage = {
        victim = self.parent,
        attacker = self.caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_PURE,
        ability = self.ability,
    }

    if self.parent:IsIllusion()
    and self.parent:HasModifier("strider_1_modifier_spirit") == false
    and self.parent:HasModifier("bloodstained_u_modifier_copy") == false then
        self.parent:ForceKill(false)
    else
        ApplyDamage(damage)
    end

    local enemies = FindUnitsInRadius(
        self.caster:GetTeamNumber(),
        self.parent:GetOrigin(),
        self.parent,
        self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0, 0, false
    )
    if #enemies > 0 then
        for _,enemy in pairs(enemies) do
            if enemy ~= nil and (not enemy:IsMagicImmune()) and (not enemy:IsInvulnerable()) then
                enemy:AddNewModifier(self.caster, self.ability, "_modifier_stun", {
                    duration = self.ability:CalcStatus(stun, self.caster, enemy)
                })
            end
        end
    end

    GridNav:DestroyTreesAroundPoint(self.parent:GetOrigin(), self.radius, true)
    self:PlayEfxEnd(self.parent, level)
end

--------------------------------------------------------------------------------------------------

function inquisitor_x1_modifier_hammer:OnIntervalThink()
    self.time = self.time + 0.1
    if self.time >= self.delay then
        self:Destroy()
        self:StartIntervalThink(-1)
    end
end

--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

function inquisitor_x1_modifier_hammer:PlayEfxStart()
    self.effect_cast = ParticleManager:CreateParticle( "particles/units/heroes/hero_dawnbreaker/dawnbreaker_solar_guardian_beam_shaft.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast, 0, self.parent:GetOrigin())
    if IsServer() then self.parent:EmitSound("Hero_Nevermore.RequiemOfSoulsCast") end

    -- buff particle
	self:AddParticle(
		self.effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
end

function inquisitor_x1_modifier_hammer:PlayEfxEnd(parent, level)
    local particle = "particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_ti6_immortal.vpcf"
    local effect = ParticleManager:CreateParticle( particle, PATTACH_ABSORIGIN_FOLLOW, parent )
    ParticleManager:SetParticleControl( effect, 0, parent:GetOrigin() )

    local particle2 = "particles/econ/items/omniknight/hammer_ti6_immortal/omniknight_purification_immortal_cast.vpcf"
    local effect2 = ParticleManager:CreateParticle( particle2, PATTACH_ABSORIGIN_FOLLOW, self.caster )
    ParticleManager:SetParticleControl( effect2, 0, self.caster:GetOrigin() )
    ParticleManager:SetParticleControl( effect2, 1, parent:GetOrigin() )

    local particle3 = "particles/econ/items/axe/axe_ti9_immortal/axe_ti9_gold_call.vpcf"
    local effect3 = ParticleManager:CreateParticle( particle3, PATTACH_ABSORIGIN_FOLLOW, parent )
    ParticleManager:SetParticleControl( effect3, 0, parent:GetOrigin() )
    ParticleManager:SetParticleControl( effect3, 2, Vector( self.radius, self.radius, self.radius ) )

    local particle_cast = "particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf"
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_OVERHEAD_FOLLOW, parent )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( level, 1, level ) )

    if IsServer() then parent:EmitSound("Hero_Nevermore.Shadowraze") end
end
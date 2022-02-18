inquisitor_1_modifier_shield = class({})

function inquisitor_1_modifier_shield:IsHidden()
	return false
end

function inquisitor_1_modifier_shield:IsPurgable()
    return false
end

function inquisitor_1_modifier_shield:OnCreated( kv )
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.hits = self.ability:GetSpecialValueFor("hits")
    self.limit = self.ability:GetSpecialValueFor("limit")
    self.immunity = false
    self.regen_amp = 0

    -- UP 1.1
    if self.ability:GetRank(1) then
        self.regen_amp = 100
    end

    -- UP 1.5
    if self.ability:GetRank(5) then
        local dps = 25
        local intervals = 0.4
        self.damageTable = {
            victim = nil,
            attacker = self.parent,
            damage = dps * intervals,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self.ability
        }
    
        self:StartIntervalThink(intervals)
        self:PlayEfxBurn(self.parent)
    end

    -- UP 1.3
    if self.ability:GetRank(3) then
        self.hits = self.hits + 2
    end

    -- UP 1.6
    if self.ability:GetRank(6) then
        self.immunity = true
    end

    if IsServer() then
        self:SetStackCount(self.hits)
        self:PlayEfxStart()
    end
end

function inquisitor_1_modifier_shield:OnRefresh( kv )
    self.hits = self.ability:GetSpecialValueFor("hits")
    self.limit = self.ability:GetSpecialValueFor("limit")
    self.immunity = false

    -- UP 1.3
    if self.ability:GetRank(3) then
        self.hits = self.hits + 2
    end

    -- UP 1.5
    if self.ability:GetRank(5) then
        local dps = 25
        local intervals = 0.4
        self.damageTable = {
            victim = nil,
            attacker = self.parent,
            damage = dps * intervals,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self.ability
        }
    
        self:StartIntervalThink(intervals)
        self:PlayEfxBurn(self.parent)
    end

    -- UP 1.6
    if self.ability:GetRank(6) then
        self.immunity = true
    end

    if IsServer() then
        self:SetStackCount(self.hits)
        self:PlayEfxStart()
    end
end

function inquisitor_1_modifier_shield:OnRemoved()
    if IsServer() then
        self.parent:EmitSound("Hero_Medusa.ManaShield.Off")
        self.parent:StopSound("Hero_Batrider.Firefly.loop")
    end

    if self.burn_particle ~= nil then
        ParticleManager:DestroyParticle(self.burn_particle, false)
    end
end

--------------------------------------------------------------------------------------------------

function inquisitor_1_modifier_shield:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = self.immunity,
	}

	return state
end

function inquisitor_1_modifier_shield:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end

function inquisitor_1_modifier_shield:DeclareFunctions()

    local funcs = {
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK
    }
    return funcs
end

function inquisitor_1_modifier_shield:GetModifierHPRegenAmplify_Percentage(keys)
    return self.regen_amp
end

function inquisitor_1_modifier_shield:GetModifierPhysical_ConstantBlock(keys)
    if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then return end
    local attacker = keys.attacker
    local damage = keys.damage

    -- UP 1.4
    if self.ability:GetRank(4) == false then
        if damage > self.limit then
            self:Destroy()
            return 0
        end
    else
        if keys.damage_flags ~= DOTA_DAMAGE_FLAG_REFLECTION then
            local damageTable = {
                victim = attacker,
                attacker = self.parent,
                damage = damage * 0.3,
                damage_type = DAMAGE_TYPE_PHYSICAL,
                ability = self.ability,
                damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
            }
            ApplyDamage( damageTable )
        end
    end

    if IsServer() and damage > 1 then
        self:DecrementStackCount()
        self:PlayEfxBlocked(damage)
    end

    if self:GetStackCount() < 1 then
        self:Destroy()
    end

    return damage
end

function inquisitor_1_modifier_shield:OnIntervalThink()
    local enemies = FindUnitsInRadius(
        self.caster:GetTeamNumber(),	-- int, your team number
        self.parent:GetOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        275,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
        0,	-- int, flag filter
        0,	-- int, order filter
        false	-- bool, can grow cache
    )

    for _,enemy in pairs(enemies) do
        self.damageTable.victim = enemy
        ApplyDamage(self.damageTable)
    end

    GridNav:DestroyTreesAroundPoint(self.parent:GetOrigin(), 175, true)
end

--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

function inquisitor_1_modifier_shield:PlayEfxStart()
    if self.shield_particle ~= nil then ParticleManager:DestroyParticle(self.shield_particle, false) end
	self.shield_particle = ParticleManager:CreateParticle("particles/econ/items/lanaya/ta_ti9_immortal_shoulders/ta_ti9_refraction.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.shield_particle, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.shield_particle, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(self.shield_particle, 5, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	self:AddParticle(self.shield_particle, false, false, -1, true, false)

    if IsServer() then self.parent:EmitSound("Hero_TemplarAssassin.Refraction") end
end

function inquisitor_1_modifier_shield:PlayEfxBlocked(damage)
    --local pidx = ParticleManager:CreateParticle("particles/msg_fx/msg_blocked.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())

	local particle_cast = "particles/units/heroes/hero_oracle/oracle_false_promise_attacked.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 1, Vector( damage, 0, 0 ))
	ParticleManager:ReleaseParticleIndex(effect_cast)

    if IsServer() then self.parent:EmitSound("Hero_Inquisitor.Shield.Block") end
end

function inquisitor_1_modifier_shield:PlayEfxBurn(target)

    if self.burn_particle ~= nil then
        ParticleManager:DestroyParticle(self.burn_particle, false)
    end

	self.burn_particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_phoenix/phoenix_supernova_egg.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt( self.burn_particle, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true )

    if IsServer() then
        self.parent:EmitSound("Hero_Inquisitor.Shield.Fire")
        self.parent:EmitSound("Hero_Batrider.Firefly.loop")
    end

    -- buff particle
	self:AddParticle(
		self.burn_particle,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
end
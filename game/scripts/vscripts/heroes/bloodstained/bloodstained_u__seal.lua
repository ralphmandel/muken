bloodstained_u__seal = class({})
LinkLuaModifier( "bloodstained_u_modifier_seal", "heroes/bloodstained/bloodstained_u_modifier_seal", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "bloodstained_u_modifier_status", "heroes/bloodstained/bloodstained_u_modifier_status", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "bloodstained_u_modifier_debuff_slow", "heroes/bloodstained/bloodstained_u_modifier_debuff_slow", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "bloodstained_u_modifier_copy", "heroes/bloodstained/bloodstained_u_modifier_copy", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "bloodstained_u_modifier_copy_status_efx", "heroes/bloodstained/bloodstained_u_modifier_copy_status_efx", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "bloodstained_u_modifier_hp_bonus", "heroes/bloodstained/bloodstained_u_modifier_hp_bonus", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "bloodstained_0_modifier_bleeding", "heroes/bloodstained/bloodstained_0_modifier_bleeding", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "_modifier_generic_custom_indicator", "modifiers/_modifier_generic_custom_indicator", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "_modifier_silence", "modifiers/_modifier_silence", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bloodstained_u__seal:CalcStatus(duration, caster, target)
        local time = duration
        local base_stats_caster = nil
        local base_stats_target = nil

        if caster ~= nil then
            base_stats_caster = caster:FindAbilityByName("base_stats")
        end

        if target ~= nil then
            base_stats_target = target:FindAbilityByName("base_stats")
        end

        if caster == nil then
            if target ~= nil then
                if base_stats_target then
                    local value = base_stats_target.stat_total["RES"] * 0.4
                    local calc = (value * 6) / (1 +  (value * 0.06))
                    time = time * (1 - (calc * 0.01))
                end
            end
        else
            if target == nil then
                if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
            else
                if caster:GetTeamNumber() == target:GetTeamNumber() then
                    if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
                else
                    if base_stats_caster and base_stats_target then
                        local value = (base_stats_caster.stat_total["INT"] - base_stats_target.stat_total["RES"]) * 0.7
                        if value > 0 then
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 + (calc * 0.01))
                        else
                            value = -1 * value
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 - (calc * 0.01))
                        end
                    end
                end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function bloodstained_u__seal:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function bloodstained_u__seal:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bloodstained_u__seal:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_shadow_demon" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[4][upgrade] end
    end

    function bloodstained_u__seal:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_demon" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then base_hero.ranks[4][0] = true end

        local charges = 1

        -- UP 4.11
        if self:GetRank(11) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function bloodstained_u__seal:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function bloodstained_u__seal:GetIntrinsicModifierName()
        return "_modifier_generic_custom_indicator"
    end

    function bloodstained_u__seal:OnSpellStart()
        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")
        local point = self:GetCursorPosition()

        local thinkers = Entities:FindAllByClassname("npc_dota_thinker")
        for _,seal in pairs(thinkers) do
            if seal:GetOwner() == caster and seal:HasModifier("bloodstained_u_modifier_seal") then
                seal:Kill(self, nil)
            end
        end

        CreateModifierThinker(caster, self, "bloodstained_u_modifier_seal", {
            duration = duration
        }, point, caster:GetTeamNumber(), false)

        if IsServer() then
            caster:EmitSound("hero_bloodseeker.bloodRite")
            caster:EmitSound("hero_bloodseeker.rupture.cast")
        end
    end

    function bloodstained_u__seal:CreateCopy(target, source)
        local caster = self:GetCaster()
        if target:IsHero() == false then return end
        if target:HasModifier("bloodstained_u_modifier_debuff_slow") then return end

        local illusion_duration = self:GetSpecialValueFor("illusion_duration")

        target:AddNewModifier(caster, self, "bloodstained_u_modifier_debuff_slow", {
            duration = illusion_duration,
            source = source:GetAbilityName()
        })
    end

    -- Ability Cast Filter (For custom indicator)
    function bloodstained_u__seal:CastFilterResultLocation( vLoc )
        -- Custom indicator block start
        if IsClient() then
            -- check custom indicator
            if self.custom_indicator then
                -- register cursor position
                self.custom_indicator:Register( vLoc )
            end
        end
        -- Custom indicator block end

        return UF_SUCCESS
    end

    -- Ability Custom Indicator
    function bloodstained_u__seal:CreateCustomIndicator()
        -- references
        local particle_cast = "particles/bloodstained/seal_finder_aoe.vpcf"

        -- get data
        local radius = self:GetSpecialValueFor( "radius" )

        -- create particle
        self.effect_indicator = ParticleManager:CreateParticle( particle_cast, PATTACH_CUSTOMORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl( self.effect_indicator, 1, Vector( radius, radius, radius ) )
    end

    function bloodstained_u__seal:UpdateCustomIndicator( loc )
        -- update particle position
        ParticleManager:SetParticleControl( self.effect_indicator, 0, loc )
        -- for i=0,7 do
        -- 	ParticleManager:SetParticleControl( self.effect_indicator, 2 + i, loc + self.locations[i] )
        -- end
    end

    function bloodstained_u__seal:DestroyCustomIndicator()
        -- destroy particle
        ParticleManager:DestroyParticle( self.effect_indicator, false )
        ParticleManager:ReleaseParticleIndex( self.effect_indicator )
    end

    function bloodstained_u__seal:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level =  (1 + ((self:GetLevel() - 1) * 0.1))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() % 2 == 0 then manacost = manacost - 60 end
        return manacost * level
    end

    -- init bramble locations
    -- local locations = {}
    -- local inner = Vector( 200, 0, 0 )
    -- local outer = Vector( 500, 0, 0 )
    -- outer = RotatePosition( Vector(0,0,0), QAngle( 0, 45, 0 ), outer )

    -- -- real men use 0-based
    -- for i=0,3 do
    -- 	locations[i] = RotatePosition( Vector(0,0,0), QAngle( 0, 90*i, 0 ), inner )
    -- 	locations[i+4] = RotatePosition( Vector(0,0,0), QAngle( 0, 90*i, 0 ), outer )
    -- end
    -- bloodstained_u__seal.locations = locations

-- EFFECTS
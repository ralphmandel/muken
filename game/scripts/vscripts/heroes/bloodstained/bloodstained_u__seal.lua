bloodstained_u__seal = class({})
LinkLuaModifier( "bloodstained_u_modifier_seal", "heroes/bloodstained/bloodstained_u_modifier_seal", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "bloodstained_u_modifier_status", "heroes/bloodstained/bloodstained_u_modifier_status", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "bloodstained_u_modifier_debuff_slow", "heroes/bloodstained/bloodstained_u_modifier_debuff_slow", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "bloodstained_u_modifier_copy", "heroes/bloodstained/bloodstained_u_modifier_copy", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "bloodstained_u_modifier_hp_bonus", "heroes/bloodstained/bloodstained_u_modifier_hp_bonus", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "bloodstained_0_modifier_bleeding", "heroes/bloodstained/bloodstained_0_modifier_bleeding", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_generic_custom_indicator", "modifiers/modifier_generic_custom_indicator", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "_modifier_silence", "modifiers/_modifier_silence", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bloodstained_u__seal:CalcStatus(duration, caster, target)
        local time = duration
        local caster_int = nil
        local caster_mnd = nil
        local target_res = nil

        if caster ~= nil then
            caster_int = caster:FindModifierByName("_1_INT_modifier")
            caster_mnd = caster:FindModifierByName("_2_MND_modifier")
        end

        if target ~= nil then
            target_res = target:FindModifierByName("_2_RES_modifier")
        end

        if caster == nil then
            if target ~= nil then
                if target_res then time = time * (1 - target_res:GetStatus()) end
            end
        else
            if target == nil then
                if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
            else
                if caster:GetTeamNumber() == target:GetTeamNumber() then
                    if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
                else
                    if caster_int then time = duration * (1 + caster_int:GetDebuffTime()) end
                    if target_res then time = time * (1 - target_res:GetStatus()) end
                end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function bloodstained_u__seal:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
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
        local att = caster:FindAbilityByName("bloodstained__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_demon" then return end

        return att.talents[4][upgrade]
    end

    function bloodstained_u__seal:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_demon" then return end

        local att = caster:FindAbilityByName("bloodstained__attributes")
        if att then
            if att:IsTrained() then
                att.talents[4][0] = true
            end
        end
        
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_DEX"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_DEF"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_RES"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_REC"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_MND"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_LCK"):CheckLevelUp(true) end

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
        return "modifier_generic_custom_indicator"
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

        CreateModifierThinker(
            caster, self, "bloodstained_u_modifier_seal", {duration = duration}, point, caster:GetTeamNumber(), false
        )

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
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() == 1 then return 160 + (16 * (self:GetLevel() - 1)) end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return 60 + (16 * (self:GetLevel() - 1)) end
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
slayer_2__shackles = class({})
LinkLuaModifier("slayer_2_modifier_buff", "heroes/slayer/slayer_2_modifier_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("slayer_2_modifier_debuff", "heroes/slayer/slayer_2_modifier_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function slayer_2__shackles:CalcStatus(duration, caster, target)
        local time = duration
        if caster == nil then return time end
        local caster_int = caster:FindModifierByName("_1_INT_modifier")
        local caster_mnd = caster:FindModifierByName("_2_MND_modifier")

        if target == nil then
            if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
        else
            if caster:GetTeamNumber() == target:GetTeamNumber() then
                if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
            else
                local target_res = target:FindModifierByName("_2_RES_modifier")
                if caster_int then time = duration * (1 + caster_int:GetDebuffTime()) end
                if target_res then time = time * (1 - target_res:GetStatus()) end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function slayer_2__shackles:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function slayer_2__shackles:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function slayer_2__shackles:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("slayer__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_razor" then return end

        return att.talents[2][upgrade]
    end

    function slayer_2__shackles:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_razor" then return end

        local att = caster:FindAbilityByName("slayer__attributes")
        if att then
            if att:IsTrained() then
                att.talents[2][0] = true
            end
        end
        
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_DEX"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_DEF"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_RES"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_REC"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_MND"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_LCK"):CheckLevelUp(true) end

        local charges = 1
        self:SetCurrentAbilityCharges(charges)
    end

    function slayer_2__shackles:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function slayer_2__shackles:OnSpellStart()
        local caster = self:GetCaster()
        local origin = caster:GetOrigin()
        local point = self:GetCursorPosition()

        local projectile_name = "particles/units/heroes/hero_clinkz/clinkz_searing_arrow_linear_proj.vpcf"
        local projectile_speed = self:GetSpecialValueFor("chain_speed")
        local projectile_distance = self:GetSpecialValueFor("chain_range")
        local projectile_start_radius = self:GetSpecialValueFor("chain_width")
        local projectile_end_radius = self:GetSpecialValueFor("chain_width")
        local projectile_vision = self:GetSpecialValueFor("chain_vision")
        local max_distance = self:GetSpecialValueFor( "chain_range" )

        local projectile_direction = (Vector( point.x-origin.x, point.y-origin.y, 0 )):Normalized()

        local info = {
            Source = caster,
            Ability = self,
            vSpawnOrigin = caster:GetOrigin(),
            
            bDeleteOnHit = true,
            
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            
            EffectName = projectile_name,
            fDistance = projectile_distance,
            fStartRadius = projectile_start_radius,
            fEndRadius =projectile_end_radius,
            vVelocity = projectile_direction * projectile_speed,
        
            bHasFrontalCone = true,
            bReplaceExisting = true,
            fExpireTime = GameRules:GetGameTime() + 10.0,
            
            bProvidesVision = true,
            iVisionRadius = projectile_vision,
            iVisionTeamNumber = caster:GetTeamNumber(),

            ExtraData = {
                originX = origin.x,
                originY = origin.y,
                originZ = origin.z,

                max_distance = max_distance,
                --min_stun = min_stun,
                --max_stun = max_stun,

                --min_damage = min_damage,
                --bonus_damage = bonus_damage,
            }
        }
        ProjectileManager:CreateLinearProjectile(info)

        if IsServer() then caster:EmitSound("soundname") end
    end

    function slayer_2__shackles:OnProjectileHit_ExtraData(hTarget, vLocation, extraData)
        if hTarget == nil then return end

        local caster = self:GetCaster()
        local shackle_duration = self:GetSpecialValueFor("shackle_duration")
    
        hTarget:AddNewModifier(caster, self, "slayer_2_modifier_debuff", {
            duration = self:CalcStatus(shackle_duration, caster, hTarget)
        })
    
        AddFOWViewer(caster:GetTeamNumber(), vLocation, 250, 1, false)
        if IsServer() then hTarget:EmitSound("soundname") end
    
        return true
    end

-- EFFECTS
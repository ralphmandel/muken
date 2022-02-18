dasdingo_3__hex = class({})
LinkLuaModifier("dasdingo_3_modifier_passive", "heroes/dasdingo/dasdingo_3_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_3_modifier_hex", "heroes/dasdingo/dasdingo_3_modifier_hex", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function dasdingo_3__hex:CalcStatus(duration, caster, target)
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

    function dasdingo_3__hex:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function dasdingo_3__hex:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function dasdingo_3__hex:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("dasdingo__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

        return att.talents[3][upgrade]
    end

    function dasdingo_3__hex:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

        local att = caster:FindAbilityByName("dasdingo__attributes")
        if att then
            if att:IsTrained() then
                att.talents[3][0] = true
            end
        end
        
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_DEX"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_DEF"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_RES"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_REC"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_MND"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_LCK"):CheckLevelUp(true) end

        local charges = 1

        -- UP 3.3
        if self:GetRank(3) then
            charges = charges * 2           
        end

        -- UP 3.5
        if self:GetRank(5) then
            charges = charges * 3
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function dasdingo_3__hex:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function dasdingo_3__hex:GetIntrinsicModifierName()
        return "dasdingo_3_modifier_passive"
    end

    function dasdingo_3__hex:GetAOERadius()
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() == 1 then return 0 end
        if self:GetCurrentAbilityCharges() % 3 == 0 then return 225 end
        return 0
    end

    function dasdingo_3__hex:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local duration = self:GetSpecialValueFor("duration")

        if target:TriggerSpellAbsorb(self) then return end

        -- UP 3.3
        if self:GetRank(3) then
            local damageTable = {
                victim = target,
                attacker = caster,
                damage = target:GetMaxHealth() * 0.1,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = self
            }
        
            local damage = ApplyDamage(damageTable)
            if damage >= 1 then self:PopupPure(target, damage) end
        end

        -- UP 3.4
        if self:GetRank(4) then
            duration = duration + 1
        end

        -- UP 3.5
        if self:GetRank(5) then
            local radius = 225
            local enemies = FindUnitsInRadius(
                caster:GetTeamNumber(), target:GetOrigin(), nil, radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NO_INVIS, 0, false
            )
            
            for _,enemy in pairs(enemies) do
                enemy:AddNewModifier(caster, self, "dasdingo_3_modifier_hex", {
                    duration = self:CalcStatus(2, caster, target)
                })
            end

            self:PlayEfxAoe(target, radius)
        end

        if target:IsAlive() then
            target:AddNewModifier(caster, self, "dasdingo_3_modifier_hex", {
                duration = self:CalcStatus(duration, caster, target)
            })
        end
        
        self:PlayEfxStart(target)
    end

    function dasdingo_3__hex:CastFilterResultTarget(hTarget)
        local caster = self:GetCaster()
        local flag = 0

        if caster == hTarget then
            return UF_FAIL_CUSTOM
        end

        -- UP 3.3
        if self:GetCurrentAbilityCharges() % 2 == 0 then
            flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
        end

        local result = UnitFilter(
            hTarget,	-- Target Filter
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
            flag,	-- Unit Flag
            caster:GetTeamNumber()	-- Team reference
        )
        
        if result ~= UF_SUCCESS then
            return result
        end

        return UF_SUCCESS
    end

    function dasdingo_3__hex:GetCustomCastErrorTarget( hTarget )
        if self:GetCaster() == hTarget then
            return "#dota_hud_error_cant_cast_on_self"
        end
    end

    function dasdingo_3__hex:GetBehavior()
        if self:GetCurrentAbilityCharges() == 0 then return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET end
        if self:GetCurrentAbilityCharges() == 1 then return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET end
        if self:GetCurrentAbilityCharges() % 3 == 0 then return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE end
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    end

-- EFFECTS

    function dasdingo_3__hex:PlayEfxStart(target)
        local particle_cast = "particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, target)
        ParticleManager:ReleaseParticleIndex(effect_cast)

        if IsServer() then target:EmitSound("Hero_Lion.Voodoo") end
    end

    function dasdingo_3__hex:PopupPure(target, damage)
        local pidx = ParticleManager:CreateParticle("particles/msg_fx/msg_crit.vpcf", PATTACH_ABSORIGIN_FOLLOW, target) -- target:GetOwner()
        local digits = 0
        if damage < 10 then digits = 1 end
        if damage > 9 and damage < 100 then digits = 2 end
        if damage > 99 and damage < 1000 then digits = 3 end
        if damage > 999 then digits = 4 end

        ParticleManager:SetParticleControl(pidx, 1, Vector(0, math.floor(damage), 0))
        ParticleManager:SetParticleControl(pidx, 2, Vector(3, digits, 0))
        ParticleManager:SetParticleControl(pidx, 3, Vector(225, 175, 255))

        if IsServer() then target:EmitSound("Hero_Juggernaut.BladeDance") end
    end

    function dasdingo_3__hex:PlayEfxAoe(target, radius)
        local particle_cast = "particles/dasdingo/dasdingo_aoe_hex.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(effect_cast, 2, Vector(radius, radius, radius))
        ParticleManager:SetParticleControlEnt(effect_cast, 1, target, PATTACH_POINT_FOLLOW, "attach_mouth", Vector(0,0,0), true)
        ParticleManager:ReleaseParticleIndex(effect_cast)
    end
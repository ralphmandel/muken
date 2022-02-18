strider_1__push = class({})
LinkLuaModifier( "strider_1_modifier_push", "heroes/strider/strider_1_modifier_push", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "strider_1_modifier_debuff", "heroes/strider/strider_1_modifier_debuff", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "strider_1_modifier_spirit", "heroes/strider/strider_1_modifier_spirit", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "strider_1_modifier_knockback", "heroes/strider/strider_1_modifier_knockback", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "shadow_2_modifier_vacuum", "heroes/shadow/shadow_2_modifier_vacuum", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier("_modifier_disarm", "modifiers/_modifier_disarm", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function strider_1__push:CalcStatus(duration, caster, target)
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

    function strider_1__push:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function strider_1__push:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function strider_1__push:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("strider__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_void_spirit" then return end

        return att.talents[1][upgrade]
    end

    function strider_1__push:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_void_spirit" then return end

        local att = caster:FindAbilityByName("strider__attributes")
        if att then
            if att:IsTrained() then
                att.talents[1][0] = true
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

    function strider_1__push:Spawn()
        self:SetCurrentAbilityCharges(0)
        self.cast = false
    end

-- SPELL START

    function strider_1__push:GetIntrinsicModifierName()
        return "strider_1_modifier_push"
    end

    function strider_1__push:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local debuff_duration = self:GetSpecialValueFor("debuff_duration")

        if target:TriggerSpellAbsorb(self) then return end

        if target:IsIllusion() then
            target:ForceKill(false)
            return
        end

        if target:IsHero() then
            self:DoPush(target)
        else
            target:AddNewModifier(caster, self, "_modifier_disarm", {
                duration = self:CalcStatus(debuff_duration, caster, target)
            })
        end
    end

    function strider_1__push:DoPush(target)
        local caster = self:GetCaster()
        local debuff_duration = self:GetSpecialValueFor("debuff_duration") * 2

        if target == nil then return end
        if IsValidEntity(target) == false then return end
        if target:IsAlive() == false then return end

        target:AddNewModifier(caster, self, "strider_1_modifier_debuff", {duration = debuff_duration})
        self:PlayEfxImpact(target)
    end

-- EFFECTS

    function strider_1__push:PlayEfxImpact(target)
        local caster = self:GetCaster()
        local origin = caster:GetOrigin()
        local direction = (target:GetOrigin() - origin):Normalized() * 50
        local pos = target:GetOrigin() + direction
        local new = pos - origin

        local particle_cast = "particles/strider/strider__push__caster.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(effect_cast, 0, pos)
        ParticleManager:SetParticleControlForward(effect_cast, 0, new:Normalized())
        ParticleManager:SetParticleControl(effect_cast, 1, pos)
        ParticleManager:SetParticleControl(effect_cast, 5, Vector(0, 90, 0))
        ParticleManager:SetParticleControlForward(effect_cast, 5, new:Normalized())
        ParticleManager:ReleaseParticleIndex(effect_cast)
    end
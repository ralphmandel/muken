bloodstained_1__rage = class({})
LinkLuaModifier( "bloodstained_1_modifier_rage", "heroes/bloodstained/bloodstained_1_modifier_rage", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "bloodstained_1_modifier_berserk", "heroes/bloodstained/bloodstained_1_modifier_berserk", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "bloodstained_1_modifier_rage_status_efx", "heroes/bloodstained/bloodstained_1_modifier_rage_status_efx", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "bloodstained_1_modifier_berserk_status_efx", "heroes/bloodstained/bloodstained_1_modifier_berserk_status_efx", LUA_MODIFIER_MOTION_NONE )

-- INIT

    function bloodstained_1__rage:CalcStatus(duration, caster, target)
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

    function bloodstained_1__rage:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function bloodstained_1__rage:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bloodstained_1__rage:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("bloodstained__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_demon" then return end

        return att.talents[1][upgrade]
    end

    function bloodstained_1__rage:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_demon" then return end

        local att = caster:FindAbilityByName("bloodstained__attributes")
        if att then
            if att:IsTrained() then
                att.talents[1][0] = true
            end
        end
        
        if self:GetLevel() == 1 then
			caster:FindAbilityByName("_2_DEX"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_DEF"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_RES"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_REC"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_MND"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_LCK"):CheckLevelUp(true)
		end

        local charges = 1

        -- UP 1.22
        if self:GetRank(22) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function bloodstained_1__rage:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function bloodstained_1__rage:OnSpellStart()
        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")

        caster:AddNewModifier(caster, self, "bloodstained_1_modifier_rage", {
            duration = self:CalcStatus(duration, caster, caster)
        })

        self:EndCooldown()
        self:SetActivated(false)

        -- UP 1.22
        if self:GetRank(22) then
            local radius = self:GetCastRange(caster:GetOrigin(), nil)
            self:PlayEfxBerserk(radius)

            local units = FindUnitsInRadius(
                caster:GetTeamNumber(), caster:GetOrigin(), nil, radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                0, 2, false
            )

            for _,unit in pairs(units) do
                unit:SetForceAttackTarget(caster)
                unit:MoveToTargetToAttack(caster)
                unit:AddNewModifier(caster, self, "bloodstained_1_modifier_berserk", {
                    duration = self:CalcStatus(4, caster, unit)
                })
            end
        end
    end

    function bloodstained_1__rage:GetCastRange(vLocation, hTarget)
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() == 1 then return 0 end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return 400 end
        return 0
    end

-- EFFECTS

    function bloodstained_1__rage:PlayEfxBerserk(radius)
        local caster = self:GetCaster()
        local particle_cast = "particles/econ/items/axe/axe_ti9_immortal/axe_ti9_call.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControl(effect_cast, 2, Vector(radius, radius, radius))
        ParticleManager:SetParticleControlEnt(effect_cast, 1, caster, PATTACH_POINT_FOLLOW, "attach_mouth", Vector(0,0,0), true)
        ParticleManager:ReleaseParticleIndex(effect_cast)
    end
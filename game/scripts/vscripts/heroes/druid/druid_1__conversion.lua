druid_1__conversion = class({})
LinkLuaModifier("druid_1_modifier_conversion", "heroes/druid/druid_1_modifier_conversion", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function druid_1__conversion:CalcStatus(duration, caster, target)
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

    function druid_1__conversion:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function druid_1__conversion:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function druid_1__conversion:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("druid__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

        return att.talents[1][upgrade]
    end

    function druid_1__conversion:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

        local att = caster:FindAbilityByName("druid__attributes")
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

    function druid_1__conversion:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function druid_1__conversion:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

    function druid_1__conversion:OnSpellStart()
        local caster = self:GetCaster()
        self.point = self:GetCursorPosition()
    end

    function druid_1__conversion:OnChannelFinish(bInterrupted)
        local caster = self:GetCaster()
        local radius = self:GetSpecialValueFor("radius")
        local duration = self:GetSpecialValueFor("duration")

        caster:FadeGesture(ACT_DOTA_CAST_ABILITY_2)

        if bInterrupted == false then
            local damageTable = {
                attacker = caster,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = self
            }

            local neutrals = FindUnitsInRadius(
                caster:GetTeamNumber(), self.point, nil, radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC,
                0, 0, false
            )
    
            for _,neutral in pairs(neutrals) do
                local chance = self:CalcChance(neutral:GetLevel())
                if neutral:GetUnitName() ~= "summon_spiders"
                and neutral:GetTeamNumber() == DOTA_TEAM_NEUTRALS then
                    if RandomInt(1, 10000) <= chance * 100 then
                        neutral:Purge( false, true, false, false, false )
                        neutral:Heal(9999, self)
                        neutral:AddNewModifier(caster, self, "druid_1_modifier_conversion", {
                            duration = self:CalcStatus(duration, caster, neutral)
                        })
                    else
                        damageTable.victim = neutral
                        damageTable.damage = neutral:GetMaxHealth() * chance * 0.01
                        ApplyDamage(damageTable)
                    end
                end
            end
        end
    end

    function druid_1__conversion:CalcChance(level)
        level = level - 1
        local chance = self:GetSpecialValueFor("chance")
        local chance_lvl = self:GetSpecialValueFor("chance_lvl")
        local chance_bonus = self:GetSpecialValueFor("chance_bonus")
        local chance_bonus_lvl = self:GetSpecialValueFor("chance_bonus_lvl")
        local calc = chance + (chance_lvl * level)
        local calc_bonus = chance_bonus + (chance_bonus_lvl * level)

        return (calc + calc_bonus)
    end

-- EFFECTS
flea_3__jump = class({})
LinkLuaModifier("flea_3_modifier_passive", "heroes/flea/flea_3_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_3_modifier_jump", "heroes/flea/flea_3_modifier_jump", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_3_modifier_effect", "heroes/flea/flea_3_modifier_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_3_modifier_attack", "heroes/flea/flea_3_modifier_attack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_silence", "modifiers/_modifier_silence", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_generic_arc", "modifiers/_modifier_generic_arc", LUA_MODIFIER_MOTION_BOTH)

-- INIT

    function flea_3__jump:CalcStatus(duration, caster, target)
        if caster == nil or target == nil then return duration end
        if IsValidEntity(caster) == false or IsValidEntity(target) == false then return duration end
        local base_stats = caster:FindAbilityByName("base_stats")

        if caster:GetTeamNumber() == target:GetTeamNumber() then
            if base_stats then duration = duration * (1 + base_stats:GetBuffAmp()) end
        else
            if base_stats then duration = duration * (1 + base_stats:GetDebuffAmp()) end
            duration = duration * (1 - target:GetStatusResistance())
        end
        
        return duration
    end

    function flea_3__jump:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function flea_3__jump:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function flea_3__jump:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_slark" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[3][upgrade] end
    end

    function flea_3__jump:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_slark" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[3][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function flea_3__jump:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function flea_3__jump:OnOwnerSpawned()
        self:SetActivated(true)
    end

    function flea_3__jump:GetIntrinsicModifierName()
        return "flea_3_modifier_passive"
    end

    function flea_3__jump:OnSpellStart()
        local caster = self:GetCaster()
        self.point = self:GetCursorPosition()

        ProjectileManager:ProjectileDodge(caster)
        caster:RemoveModifierByName("flea_3_modifier_jump")
        caster:AddNewModifier(caster, self, "flea_3_modifier_jump", {})
    end

    function flea_3__jump:FindTargets(radius_impact, point)
        local caster = self:GetCaster()
        local mod = caster:AddNewModifier(caster, self, "flea_3_modifier_attack", {})

        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), point, nil, radius_impact,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false
        )
    
        for _,enemy in pairs(enemies) do
            if enemy:HasModifier("bloodstained_u_modifier_copy") == false
            and enemy:IsIllusion() then
                enemy:ForceKill(false)
            else
                caster:PerformAttack(enemy, false, true, true, true, false, false, false)
            end
        end
    
        mod:Destroy()
    end

    function flea_3__jump:GetBehavior()
        local behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
        if self:GetCurrentAbilityCharges() % 2 == 0 then behavior = behavior + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE end
        return behavior
    end

    function flea_3__jump:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function flea_3__jump:CheckAbilityCharges(charges)
        -- UP 3.11
        if self:GetRank(11) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS
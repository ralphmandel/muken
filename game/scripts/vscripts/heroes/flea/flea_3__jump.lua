flea_3__jump = class({})
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

    function flea_3__jump:OnSpellStart()
        local caster = self:GetCaster()
        self.point = self:GetCursorPosition()

        caster:RemoveModifierByName("flea_3_modifier_jump")
        caster:AddNewModifier(caster, self, "flea_3_modifier_jump", {})
    end

    function flea_3__jump:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function flea_3__jump:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS
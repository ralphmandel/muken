flea_4__smoke = class({})
LinkLuaModifier("flea_4_modifier_passive", "heroes/flea/flea_4_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_4_modifier_smoke", "heroes/flea/flea_4_modifier_smoke", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_4_modifier_smoke_effect", "heroes/flea/flea_4_modifier_smoke_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible", "modifiers/_modifier_invisible", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible_cosmetics", "modifiers/_modifier_invisible_cosmetics", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_blind", "modifiers/_modifier_blind", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_blind_stack", "modifiers/_modifier_blind_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function flea_4__smoke:CalcStatus(duration, caster, target)
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

    function flea_4__smoke:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function flea_4__smoke:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function flea_4__smoke:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_slark" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[4][upgrade] end
    end

    function flea_4__smoke:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_slark" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[4][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function flea_4__smoke:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function flea_4__smoke:GetIntrinsicModifierName()
        return "flea_4_modifier_passive"
    end

    function flea_4__smoke:OnSpellStart()
        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")
        local point = self:GetCursorPosition()

        -- UP 4.12
        if self:GetRank(12) then
            duration = duration + 3
        end

        local smoke = CreateModifierThinker(
            caster, self, "flea_4_modifier_smoke", {duration = duration},
            point, caster:GetTeamNumber(), false
        )
    end

    function flea_4__smoke:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

    function flea_4__smoke:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function flea_4__smoke:CheckAbilityCharges(charges)
        -- UP 4.21
        if self:GetRank(21) then
            charges = charges * 2
        end

        -- UP 4.41
        if self:GetRank(41) then
            charges = charges * 3
        end

        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS
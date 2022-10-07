genuine_4__nightfall = class({})
LinkLuaModifier("genuine_4_modifier_aura", "heroes/genuine/genuine_4_modifier_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_4_modifier_aura_effect", "heroes/genuine/genuine_4_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible", "modifiers/_modifier_invisible", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible_cosmetics", "modifiers/_modifier_invisible_cosmetics", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function genuine_4__nightfall:CalcStatus(duration, caster, target)
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

    function genuine_4__nightfall:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function genuine_4__nightfall:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function genuine_4__nightfall:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[4][upgrade] end
    end

    function genuine_4__nightfall:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[4][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        if self:GetLevel() == 1 then self:SetCurrentAbilityCharges(1) return end
    end

    function genuine_4__nightfall:Spawn()
        self:SetCurrentAbilityCharges(0)
        self.invi = false
    end

-- SPELL START

function genuine_4__nightfall:GetIntrinsicModifierName()
        return "genuine_4_modifier_aura"
    end

    function genuine_4__nightfall:OnSpellStart()
        self.invi = true
        local caster = self:GetCaster()
        local charges = 1

        self:SetCurrentAbilityCharges(charges)
        caster:AddNewModifier(caster, self, "_modifier_invisible", {delay = 1})
        if IsServer() then caster:EmitSound("DOTA_Item.InvisibilitySword.Activate") end
    end

    function genuine_4__nightfall:GetCastRange(vLocation, hTarget)
        local day_radius = self:GetSpecialValueFor("day_radius")
        local night_radius = self:GetSpecialValueFor("night_radius")

        if self:GetCurrentAbilityCharges() == 0 then return 0 end

        if GameRules:IsDaytime() then return day_radius else return night_radius end
    end

    function genuine_4__nightfall:GetBehavior()
        local behavior = DOTA_ABILITY_BEHAVIOR_AURA + DOTA_ABILITY_BEHAVIOR_PASSIVE
        if self:GetCurrentAbilityCharges() == 0 then return behavior end
        if self:GetCurrentAbilityCharges() % 2 == 0 then
            behavior = DOTA_ABILITY_BEHAVIOR_AURA + DOTA_ABILITY_BEHAVIOR_NO_TARGET
        end

        return behavior
    end

    function genuine_4__nightfall:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return 100 end
        return manacost * level
    end

-- EFFECTS
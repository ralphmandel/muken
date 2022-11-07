flea_1__precision = class({})
LinkLuaModifier("flea_1_modifier_passive", "heroes/flea/flea_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_1_modifier_gesture", "heroes/flea/flea_1_modifier_gesture", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_1_modifier_precision", "heroes/flea/flea_1_modifier_precision", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_1_modifier_precision_stack", "heroes/flea/flea_1_modifier_precision_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_1_modifier_precision_status_efx", "heroes/flea/flea_1_modifier_precision_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_1_modifier_dark_pact", "heroes/flea/flea_1_modifier_dark_pact", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function flea_1__precision:CalcStatus(duration, caster, target)
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

    function flea_1__precision:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function flea_1__precision:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function flea_1__precision:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_slark" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[1][upgrade] end
    end

    function flea_1__precision:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_slark" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[1][0] = true
            Timers:CreateTimer(0.2, function()
				if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
			end)
        end

        self:CheckAbilityCharges(1)
    end

    function flea_1__precision:Spawn()
        self:CheckAbilityCharges(0)
        if self:IsTrained() == false then self:UpgradeAbility(true) end
    end

-- SPELL START

    function flea_1__precision:GetIntrinsicModifierName()
        return "flea_1_modifier_passive"
    end

    function flea_1__precision:OnSpellStart()
        local caster = self:GetCaster()
        caster:FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), caster):DecrementStackCount()
        caster:RemoveModifierByNameAndCaster("flea_1_modifier_gesture", self.caster)

        caster:AttackNoEarlierThan(10, 20)
        caster:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
        caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)

        -- UP 1.11
        if self:GetRank(11) then
            caster:AddNewModifier(caster, self, "flea_1_modifier_dark_pact", {})
        end

        Timers:CreateTimer(0.15, function()
            if caster:IsAlive() then
                -- UP 1.21
                if self:GetRank(21) then
                    caster:Purge(false, true, false, true, false)
                end

                caster:AddNewModifier(caster, self, "flea_1_modifier_precision", {})
                if IsServer() then caster:EmitSound("Fleaman.Precision") end
            end
        end)

        Timers:CreateTimer(0.7, function()
            if caster:IsAlive() then
                caster:AttackNoEarlierThan(1, 1)
                caster:AddNewModifier(caster, self, "flea_1_modifier_gesture", {duration = 1.2}) 
            end
        end)
    end

    function flea_1__precision:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function flea_1__precision:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS
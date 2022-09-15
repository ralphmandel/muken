druid_u__conversion = class({})
LinkLuaModifier("druid_u_modifier_channel", "heroes/druid/druid_u_modifier_channel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_u_modifier_conversion", "heroes/druid/druid_u_modifier_conversion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_u_modifier_passive", "heroes/druid/druid_u_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function druid_u__conversion:CalcStatus(duration, caster, target)
        if caster == nil or target == nil then return end
        if IsValidEntity(caster) == false or IsValidEntity(target) == false then return end
        local base_stats = caster:FindAbilityByName("base_stats")

        if caster:GetTeamNumber() == target:GetTeamNumber() then
            if base_stats then duration = duration * (1 + base_stats:GetBuffAmp()) end
        else
            if base_stats then duration = duration * (1 + base_stats:GetDebuffAmp()) end
            duration = duration * (1 - target:GetStatusResistance())
        end
        
        return duration
    end

    function druid_u__conversion:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function druid_u__conversion:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function druid_u__conversion:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[6][upgrade] end
    end

    function druid_u__conversion:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_furion" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[6][0] = true
            if self:GetLevel() == 1 then base_hero:SetHotkeys(self, true) end
        end

        self:CheckAbilityCharges(1)
    end

    function druid_u__conversion:Spawn()
        self:CheckAbilityCharges(0)
        self.DominateTable = {}
    end

-- SPELL START

    function druid_u__conversion:GetIntrinsicModifierName()
        return "druid_u_modifier_passive"
    end

    function druid_u__conversion:OnSpellStart()
        local caster = self:GetCaster()
        self.point = self:GetCursorPosition()

        caster:RemoveModifierByNameAndCaster("druid_u_modifier_channel", caster)
        caster:AddNewModifier(caster, self, "druid_u_modifier_channel", {})
    end

    function druid_u__conversion:OnChannelFinish(bInterrupted)
        local caster = self:GetCaster()
        caster:RemoveModifierByNameAndCaster("druid_u_modifier_channel", caster)
    end

    function druid_u__conversion:AddUnit(unit)
        local caster = self:GetCaster()
        local max_dominate = self:GetSpecialValueFor("max_dominate")
        local unit_lvl = unit:GetLevel()

        -- UP 6.32
        if self:GetRank(32) then
            max_dominate = max_dominate + 10
        end

        if self:GetCurrentTableLvl() + unit_lvl > max_dominate then
            self:GetWeakerUnit():Kill(nil, nil)
            self:AddUnit(unit)
            return
        end

        table.insert(self.DominateTable, unit)
        self:UpdateUnitCount()
    end

    function druid_u__conversion:RemoveUnit(unit)
        for i = #self.DominateTable, 1, -1 do
            if self.DominateTable[i] == unit then
                table.remove(self.DominateTable, i)
                break
            end
        end

        self:UpdateUnitCount()
    end

    function druid_u__conversion:GetWeakerUnit()
        local unit = nil
        local min_lvl = 100

        for _,unit_table in pairs(self.DominateTable) do
            if unit_table:GetLevel() < min_lvl then
                min_lvl = unit_table:GetLevel()
                unit = unit_table
            end
        end

        return unit
    end

    function druid_u__conversion:GetCurrentTableLvl()
        local lvl = 0

        for _,unit_table in pairs(self.DominateTable) do
            lvl = lvl + unit_table:GetLevel()
        end

        return lvl
    end

    function druid_u__conversion:UpdateUnitCount()
        local caster = self:GetCaster()
        caster:FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), caster):SetStackCount(self:GetCurrentTableLvl())
    end

    function druid_u__conversion:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

    function druid_u__conversion:GetCastRange(vLocation, hTarget)
        return self:GetSpecialValueFor("cast_range")
    end

    function druid_u__conversion:GetChannelAnimation()
        return ACT_DOTA_VICTORY
    end

    function druid_u__conversion:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function druid_u__conversion:CheckAbilityCharges(charges)
        -- UP 6.31
        if self:GetRank(31) then
            local item_tp = self:GetCaster():FindItemInInventory("item_tp")
            if item_tp then
                item_tp:SetCooldown(0)
                item_tp:SetCurrentAbilityCharges(2)
            end
        end

        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS

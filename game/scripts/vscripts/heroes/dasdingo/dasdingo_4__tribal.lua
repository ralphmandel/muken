dasdingo_4__tribal = class({})
LinkLuaModifier("dasdingo_4_modifier_tribal", "heroes/dasdingo/dasdingo_4_modifier_tribal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_4_modifier_bounce", "heroes/dasdingo/dasdingo_4_modifier_bounce", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_4_modifier_poison", "heroes/dasdingo/dasdingo_4_modifier_poison", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function dasdingo_4__tribal:CalcStatus(duration, caster, target)
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

    function dasdingo_4__tribal:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function dasdingo_4__tribal:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function dasdingo_4__tribal:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[4][upgrade] end
    end

    function dasdingo_4__tribal:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[4][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        local charges = 1

        -- UP 4.11
        if self:GetRank(11) then
            charges = charges * 2           
        end

        self:SetCurrentAbilityCharges(charges)
        self:CreateTribalTable()
    end

    function dasdingo_4__tribal:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function dasdingo_4__tribal:OnSpellStart()
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
        local summoned_unit = self:InsertTribal(
            CreateUnitByName("tribal_ward", point, true, caster, caster, caster:GetTeamNumber())
        )

        --summoned_unit:SetOwner(caster)
        if summoned_unit then
            summoned_unit:AddNewModifier(caster, self, "dasdingo_4_modifier_tribal", {})
            if IsServer() then summoned_unit:EmitSound("Hero_WitchDoctor.Paralyzing_Cask_Cast") end
        end
    end

    function dasdingo_4__tribal:CreateTribalTable()
        if self.tribals then return end
        self.tribals = {}

        for i = 1, self:GetSpecialValueFor("max"), 1 do table.insert(self.tribals, i, nil) end
    end

    function dasdingo_4__tribal:InsertTribal(summoned_unit)
        print(summoned_unit:GetUnitName(), #self.tribals)
        for i = 1, #self.tribals, 1 do
            print("oi", i)
            if self.tribals[i] == nil then
                print("é nil")
                self.tribals[i] = summoned_unit
                self:SortTribals()
                return summoned_unit
            end
        end

        for i = 1, #self.tribals, 1 do
            if self.tribals[i] then
                if IsValidEntity(self.tribals[i]) then
                    self.tribals[i]:RemoveModifierByNameAndCaster("dasdingo_4_modifier_tribal", self:GetCaster())
                    self.tribals[i] = nil
                    return self:InsertTribal(summoned_unit)
                end
            end
        end
    end

    function dasdingo_4__tribal:RemoveTribal(unit)
        for i = 1, #self.tribals, 1 do
            if self.tribals[i] == unit then
                self.tribals[i] = nil
                return
            end
        end
    end

    function dasdingo_4__tribal:SortTribals()
        local temp_table = {}
        for i = 1, #self.tribals, 1 do
            if #self.tribals == i then
                temp_table[1] = self.tribals[i]
            else
                temp_table[i + 1] = self.tribals[i]
            end
        end

        self.tribals = temp_table
    end

    function dasdingo_4__tribal:GetCastRange(vLocation, hTarget)
        local cast_range = self:GetSpecialValueFor("cast_range")
        if self:GetCurrentAbilityCharges() == 0 then return cast_range end
        if self:GetCurrentAbilityCharges() % 2 == 0 then cast_range = cast_range * 2 end
        return cast_range
    end

    function dasdingo_4__tribal:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS
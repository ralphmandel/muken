striker_2__shield = class({})
LinkLuaModifier("striker_2_modifier_shield", "heroes/striker/striker_2_modifier_shield", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("striker_2_modifier_burn_aura", "heroes/striker/striker_2_modifier_burn_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("striker_2_modifier_burn_aura_effect", "heroes/striker/striker_2_modifier_burn_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function striker_2__shield:CalcStatus(duration, caster, target)
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

    function striker_2__shield:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function striker_2__shield:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function striker_2__shield:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[2][upgrade] end
    end

    function striker_2__shield:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[2][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        local charges = 1
        self:SetCurrentAbilityCharges(charges)
    end

    function striker_2__shield:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function striker_2__shield:OnAbilityPhaseStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        if IsServer() then caster:EmitSound("Hero_Dawnbreaker.PreAttack") end

        if target == caster then
            caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)
            caster:StartGesture(ACT_DOTA_CAST_ABILITY_6)
        else
            caster:StartGesture(ACT_DOTA_GENERIC_CHANNEL_1)
        end

        return true
    end

    function striker_2__shield:OnAbilityPhaseInterrupted()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()

        if IsServer() then caster:StopSound("Hero_Dawnbreaker.PreAttack") end

        if target then
            if target == caster then
                caster:FadeGesture(ACT_DOTA_CAST_ABILITY_2)
                caster:FadeGesture(ACT_DOTA_CAST_ABILITY_6)
            else
                caster:FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)
            end
        end
    end

    function striker_2__shield:OnSpellStart()
        local caster = self:GetCaster()
		local target = self:GetCursorTarget()

        if target then
            if target == caster then
                Timers:CreateTimer((0.2), function()
                    caster:FadeGesture(ACT_DOTA_CAST_ABILITY_2)
                    caster:FadeGesture(ACT_DOTA_CAST_ABILITY_6)
                end)
            else
                caster:FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)
            end
        end

        self:PerformAbility(target)
    end

    function striker_2__shield:PerformAbility(target)
        local caster = self:GetCaster()
		local duration = self:CalcStatus(self:GetSpecialValueFor("duration"), caster, target)
        target:AddNewModifier(caster, self, "striker_2_modifier_shield", {duration = duration})

        return true
    end

    function striker_2__shield:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS
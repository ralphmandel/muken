icebreaker_3__skin = class({})
LinkLuaModifier("icebreaker_3_modifier_passive", "heroes/icebreaker/icebreaker_3_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_3_modifier_skin", "heroes/icebreaker/icebreaker_3_modifier_skin", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function icebreaker_3__skin:CalcStatus(duration, caster, target)
        local time = duration
        local base_stats_caster = nil
        local base_stats_target = nil

        if caster ~= nil then
            base_stats_caster = caster:FindAbilityByName("base_stats")
        end

        if target ~= nil then
            base_stats_target = target:FindAbilityByName("base_stats")
        end

        if caster == nil then
            if target ~= nil then
                if base_stats_target then
                    local value = base_stats_target.stat_total["RES"] * 0.4
                    local calc = (value * 6) / (1 +  (value * 0.06))
                    time = time * (1 - (calc * 0.01))
                end
            end
        else
            if target == nil then
                if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
            else
                if caster:GetTeamNumber() == target:GetTeamNumber() then
                    if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
                else
                    if base_stats_caster and base_stats_target then
                        local value = (base_stats_caster.stat_total["INT"] - base_stats_target.stat_total["RES"]) * 0.7
                        if value > 0 then
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 + (calc * 0.01))
                        else
                            value = -1 * value
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 - (calc * 0.01))
                        end
                    end
                end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function icebreaker_3__skin:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function icebreaker_3__skin:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function icebreaker_3__skin:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[3][upgrade] end
    end

    function icebreaker_3__skin:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[3][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        local charges = 1

        self.def_layer = self:GetSpecialValueFor("def_layer")

        -- UP 3.21
        if self:GetRank(21) then
            self.def_layer = self.def_layer + 1
            caster:FindModifierByName(self:GetIntrinsicModifierName()):UpdateBonusLayer()
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function icebreaker_3__skin:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function icebreaker_3__skin:GetIntrinsicModifierName()
        return "icebreaker_3_modifier_passive"
    end

    function icebreaker_3__skin:OnSpellStart()
        local caster = self:GetCaster()
        local frozen_duration = self:CalcStatus(self:GetSpecialValueFor("frozen_duration"), caster, caster) 
        caster:AddNewModifier(caster, self, "icebreaker_3_modifier_skin", {duration = frozen_duration})

        -- UP 4.11
        local mirror = caster:FindAbilityByName("icebreaker_4__mirror")
        if mirror ~= nil then
            if mirror:GetRank(11) then
                mirror:CreateMirrors(caster, 3)
            end
        end
    end

    function icebreaker_3__skin:ResetLayers()
        local caster = self:GetCaster()
        local max_layer = self:GetSpecialValueFor("max_layer")
        caster:FindModifierByName(self:GetIntrinsicModifierName()):SetStackCount(max_layer)
    end

    function icebreaker_3__skin:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS
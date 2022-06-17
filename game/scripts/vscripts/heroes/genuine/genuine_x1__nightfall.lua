genuine_x1__nightfall = class({})
LinkLuaModifier("genuine_x1_modifier_aura", "heroes/genuine/genuine_x1_modifier_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_x1_modifier_aura_effect", "heroes/genuine/genuine_x1_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible", "modifiers/_modifier_invisible", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible_cosmetics", "modifiers/_modifier_invisible_cosmetics", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function genuine_x1__nightfall:CalcStatus(duration, caster, target)
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

    function genuine_x1__nightfall:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function genuine_x1__nightfall:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function genuine_x1__nightfall:OnUpgrade()
        self:SetHidden(false)
    end

    function genuine_x1__nightfall:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function genuine_x1__nightfall:GetIntrinsicModifierName()
        return "genuine_x1_modifier_aura"
    end

    function genuine_x1__nightfall:OnSpellStart()
        local caster = self:GetCaster()
        caster:AddNewModifier(caster, self, "_modifier_invisible", {delay = 1})
        self:SetActivated(false)

        if IsServer() then caster:EmitSound("DOTA_Item.InvisibilitySword.Activate") end
    end

    function genuine_x1__nightfall:GetCastRange(vLocation, hTarget)
        if GameRules:IsDaytime() then
            return self:GetSpecialValueFor("day_radius")
        else
            return self:GetSpecialValueFor("night_radius")
        end

        return 0
    end

-- EFFECTS
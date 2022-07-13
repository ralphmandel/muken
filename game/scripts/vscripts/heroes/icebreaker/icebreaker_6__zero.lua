icebreaker_6__zero = class({})
LinkLuaModifier("icebreaker_6_modifier_charges", "heroes/icebreaker/icebreaker_6_modifier_charges", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_6_modifier_shard", "heroes/icebreaker/icebreaker_6_modifier_shard", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_6_modifier_aura_effect", "heroes/icebreaker/icebreaker_6_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_6_modifier_aura_effect_status_efx", "heroes/icebreaker/icebreaker_6_modifier_aura_effect_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function icebreaker_6__zero:CalcStatus(duration, caster, target)
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

    function icebreaker_6__zero:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function icebreaker_6__zero:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function icebreaker_6__zero:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[6][upgrade] end
    end

    function icebreaker_6__zero:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[6][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        -- UP 6.21
        if self:GetRank(21) then
            self.charges = self:GetSpecialValueFor("charges") + 1
        end

        local charges = 1

        -- UP 6.32
        if self:GetRank(32) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function icebreaker_6__zero:Spawn()
        self:SetCurrentAbilityCharges(0)
        self.shard = false
    end

-- SPELL START

    function icebreaker_6__zero:GetIntrinsicModifierName()
        return "icebreaker_6_modifier_charges"
    end

    function icebreaker_6__zero:OnSpellStart()
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
        local shard_duration = self:GetSpecialValueFor("shard_duration")

        self:DestroyShard()
        local shard = CreateUnitByName("ice_shard", point, true, caster, caster, caster:GetTeamNumber())
        shard:AddNewModifier(caster, self, "icebreaker_6_modifier_shard", {duration = shard_duration})

        caster:FindModifierByName(self:GetIntrinsicModifierName()):DecrementStackCount()

        self.shard = true
        if IsServer() then caster:EmitSound("Hero_Ancient_Apparition.ColdFeetCast") end
    end

    function icebreaker_6__zero:DestroyShard()
        local caster = self:GetCaster()
        local units = Entities:FindAllByClassname("npc_dota_creature")
        for _,shard in pairs(units) do
            if shard:GetPlayerOwner() == caster:GetPlayerOwner()
            and shard:IsAlive() and shard:GetUnitName() == "ice_shard" then
                shard:RemoveModifierByName("icebreaker_6_modifier_shard")
            end
        end

        self.shard = false
    end

    function icebreaker_6__zero:CastFilterResultLocation( vec )
        local caster = self:GetCaster()

        if caster:HasModifier("icebreaker_3_modifier_skin") then
            return UF_FAIL_CUSTOM
        end

        return UF_SUCCESS
    end

    function icebreaker_6__zero:GetCustomCastErrorLocation( vec )
        return "FROZEN"
    end

    function icebreaker_6__zero:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

    function icebreaker_6__zero:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS
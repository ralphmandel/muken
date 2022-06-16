bocuse_u__mise = class ({})
LinkLuaModifier("bocuse_u_modifier_mise", "heroes/bocuse/bocuse_u_modifier_mise", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_u_modifier_autocast", "heroes/bocuse/bocuse_u_modifier_autocast", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_u_modifier_jump", "heroes/bocuse/bocuse_u_modifier_jump", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("bocuse_u_modifier_exhaustion", "heroes/bocuse/bocuse_u_modifier_exhaustion", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("bocuse_u_modifier_exhaustion_status_efx", "heroes/bocuse/bocuse_u_modifier_exhaustion_status_efx", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("bocuse_u_modifier_mise_status_efx", "heroes/bocuse/bocuse_u_modifier_mise_status_efx", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_break", "modifiers/_modifier_break", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bocuse_u__mise:CalcStatus(duration, caster, target)
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
                    local value = base_stats_target.res_total * 0.01
                    local calc = (value * 6) / (1 +  (value * 0.06))
                    time = time * (1 - calc)
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
                        local value = (base_stats_caster.int_total - base_stats_target.res_total) * 0.01
                        if value > 0 then
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 + calc)
                        else
                            value = -1 * value
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 - calc)
                        end
                    end
                end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function bocuse_u__mise:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function bocuse_u__mise:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bocuse_u__mise:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_pudge" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[4][upgrade] end
    end

    function bocuse_u__mise:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_pudge" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then base_hero.ranks[4][0] = true end
        
		local charges = 1

		-- UP 4.31
		if self:GetRank(31) then
			charges = charges * 2
		end

		self:SetCurrentAbilityCharges(charges)
    end

    function bocuse_u__mise:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function bocuse_u__mise:GetIntrinsicModifierName()
        return "bocuse_u_modifier_autocast"
    end

    function bocuse_u__mise:OnSpellStart()
        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")

        -- UP 4.11
        if self:GetRank(11) then
            caster:AddNewModifier(caster, self, "bocuse_u_modifier_jump", {duration = 0.5})
        end

        caster:AddNewModifier(caster, self, "bocuse_u_modifier_mise", {duration = self:CalcStatus(duration, caster, caster)})
        self:EndCooldown()
        self:SetActivated(false)
    end

    function bocuse_u__mise:GetCastRange(vLocation, hTarget)
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() == 1 then return 0 end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return 350 end
    end

-- EFFECTS
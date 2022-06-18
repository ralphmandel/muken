shadow_3__walk = class({})
LinkLuaModifier("shadow_3_modifier_recharge", "heroes/shadow/shadow_3_modifier_recharge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_3_modifier_passive", "heroes/shadow/shadow_3_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_3_modifier_walk", "heroes/shadow/shadow_3_modifier_walk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_3_modifier_walk_cosmetic", "heroes/shadow/shadow_3_modifier_walk_cosmetic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function shadow_3__walk:CalcStatus(duration, caster, target)
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

    function shadow_3__walk:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function shadow_3__walk:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function shadow_3__walk:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_spectre" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[3][upgrade] end
    end

    function shadow_3__walk:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_spectre" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then base_hero.ranks[3][0] = true end

        local charges = 1
        self:SetCurrentAbilityCharges(charges)
    end

    function shadow_3__walk:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function shadow_3__walk:GetIntrinsicModifierName()
        return "shadow_3_modifier_passive"
    end

    function shadow_3__walk:CreateShadow(target, shadow_duration, shadow_number, bSwapLoc)
        local caster = self:GetCaster()
        ProjectileManager:ProjectileDodge(caster)
        if caster:IsIllusion() then return end -- VERY IMPORTANT !
        
        local shadow_incoming = self:GetSpecialValueFor("shadow_incoming") -100
        local shadow_outgoing = self:GetSpecialValueFor("shadow_outgoing") -100

        local illu = CreateIllusions(
			caster, caster,
			{
				outgoing_damage = shadow_outgoing,
				incoming_damage = shadow_incoming,
				bounty_base = 0,
				bounty_growth = 0,
				duration = shadow_duration
			},
			shadow_number, 64, false, true
		)

        for i = 1, #illu, 1 do
            local loc = target:GetAbsOrigin() + RandomVector(150)
            illu[i]:SetAbsOrigin(loc)
            illu[i]:SetForwardVector((target:GetAbsOrigin() - loc):Normalized())
            illu[i]:SetControllableByPlayer(caster:GetPlayerID(), false)
            FindClearSpaceForUnit(illu[i], loc, true)
        end

        if bSwapLoc then
            local rand_pos = RandomInt(0, #illu)
            if rand_pos > 0 then 
                local caster_origin = caster:GetAbsOrigin()
                caster:SetAbsOrigin(illu[rand_pos]:GetAbsOrigin())
                caster:SetForwardVector((target:GetAbsOrigin() - illu[rand_pos]:GetAbsOrigin()):Normalized())
                illu[rand_pos]:SetAbsOrigin(caster_origin)
                illu[rand_pos]:SetForwardVector((target:GetAbsOrigin() - caster_origin):Normalized())

                CenterCameraOnUnit(caster:GetPlayerID(), caster)
            end
        end
    end

    function shadow_3__walk:StartRechargeTime()
        local caster = self:GetCaster()
        local delay = self:GetSpecialValueFor("delay")

        -- UP 3.11
        if self:GetRank(11) then
            delay = delay - 1
        end
        
        if self:IsActivated() then
            self:StartCooldown(delay)
            caster:AddNewModifier(caster, self, "shadow_3_modifier_recharge", {
                duration = delay
            })
        end
    end

    function shadow_3__walk:OnOwnerSpawned()
        local caster = self:GetCaster()
        caster:RemoveModifierByName("shadow_3_modifier_walk")
        self:SetActivated(true)
        self:StartRechargeTime()
    end

    function shadow_3__walk:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level =  (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS
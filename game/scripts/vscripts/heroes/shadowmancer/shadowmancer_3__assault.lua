shadowmancer_3__assault = class({})
LinkLuaModifier("shadowmancer_3_modifier_passive", "heroes/shadowmancer/shadowmancer_3_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function shadowmancer_3__assault:CalcStatus(duration, caster, target)
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

    function shadowmancer_3__assault:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function shadowmancer_3__assault:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function shadowmancer_3__assault:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_spectre" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[3][upgrade] end
    end

    function shadowmancer_3__assault:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_spectre" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[3][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function shadowmancer_3__assault:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function shadowmancer_3__assault:GetIntrinsicModifierName()
        return "shadowmancer_3_modifier_passive"
    end

    function shadowmancer_3__assault:CreateShadow(target, shadow_duration, shadow_number, bSwapLoc, bIllusion)
        local caster = self:GetCaster()
        local weapon = caster:FindModifierByNameAndCaster("shadowmancer_1_modifier_weapon", caster)
        if bIllusion == false and caster:IsIllusion() then return end

        ProjectileManager:ProjectileDodge(caster)
        
        local illu = CreateIllusions(
			caster, caster,
			{
				outgoing_damage = -100,
				incoming_damage = 400,
				bounty_base = 0,
				bounty_growth = 0,
				duration = shadow_duration
			},
			shadow_number, 64, false, true
		)

        for i = 1, #illu, 1 do
            local loc = target:GetAbsOrigin() + RandomVector(130)
            illu[i]:SetAbsOrigin(loc)
            illu[i]:SetForwardVector((target:GetAbsOrigin() - loc):Normalized())
            illu[i]:SetControllableByPlayer(caster:GetPlayerID(), false)
            FindClearSpaceForUnit(illu[i], loc, true)

            if weapon then
                illu[i]:AddNewModifier(caster, weapon:GetAbility(), "shadowmancer_1_modifier_weapon", {
                    duration = weapon:GetRemainingTime()
                })
            end
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

    function shadowmancer_3__assault:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function shadowmancer_3__assault:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS
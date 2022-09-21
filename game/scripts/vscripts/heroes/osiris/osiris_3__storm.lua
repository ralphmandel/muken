osiris_3__storm = class({})
LinkLuaModifier("osiris_3_modifier_storm", "heroes/osiris/osiris_3_modifier_storm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("osiris_3_modifier_aura_effect", "heroes/osiris/osiris_3_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_blind", "modifiers/_modifier_blind", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_blind_stack", "modifiers/_modifier_blind_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function osiris_3__storm:CalcStatus(duration, caster, target)
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

    function osiris_3__storm:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function osiris_3__storm:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function osiris_3__storm:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_undying" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[3][upgrade] end
    end

    function osiris_3__storm:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_undying" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[3][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function osiris_3__storm:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function osiris_3__storm:OnSpellStart()
        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")

        local thinkers = Entities:FindAllByClassname("npc_dota_thinker")
		for _,storm in pairs(thinkers) do
			if storm:GetOwner() == caster and storm:HasModifier("osiris_3_modifier_storm") then
                storm:FindModifierByName("osiris_3_modifier_storm"):Destroy()
			end
		end

        self.mod_thinker = CreateModifierThinker(
            caster, self, "osiris_3_modifier_storm", {duration = duration},
            caster:GetOrigin(), caster:GetTeamNumber(), false
        )

        if IsServer() then caster:EmitSound("Ability.SandKing_SandStorm.start") end
    end

    function osiris_3__storm:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

    function osiris_3__storm:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function osiris_3__storm:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS
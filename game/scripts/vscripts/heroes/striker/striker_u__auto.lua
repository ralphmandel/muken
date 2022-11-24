striker_u__auto = class({})
LinkLuaModifier("striker_u_modifier_autocast", "heroes/striker/striker_u_modifier_autocast", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function striker_u__auto:CalcStatus(duration, caster, target)
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

    function striker_u__auto:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function striker_u__auto:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function striker_u__auto:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[6][upgrade] end
    end

    function striker_u__auto:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[6][0] = true
            if self:GetLevel() == 1 then base_hero:SetHotkeys(self, true) end
        end

        local charges = 1
        self:SetCurrentAbilityCharges(charges)
    end

    function striker_u__auto:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function striker_u__auto:GetIntrinsicModifierName()
        return "striker_u_modifier_autocast"
    end

    function striker_u__auto:OnSpellStart()
        local caster = self:GetCaster()
        self:ToggleAutoCast()
        self:OnAutoCastChange(true)
    end

    function striker_u__auto:OnAutoCastChange(state)
        local caster = self:GetCaster()
        local cosmetics = caster:FindAbilityByName("cosmetics")

        self:RemoveBonus("_1_INT", caster)

        if self:GetAutoCastState() == state then
            -- UP 6.12
            if self:GetRank(12) then
                self:AddBonus("_1_INT", caster, 5, 0, nil)
            end

            if cosmetics then
                local model = "models/items/dawnbreaker/judgment_of_light_weapon/judgment_of_light_weapon.vmdl"
                local ambients = {["particles/econ/items/dawnbreaker/dawnbreaker_judgement_of_light/dawnbreaker_judgement_of_light_weapon_ambient.vpcf"] = "nil"}
                cosmetics:ApplyAmbient(ambients, caster, cosmetics:FindModifierByModel(model))
            end
        else
            if cosmetics then
                cosmetics:DestroyAmbient(
                    "models/items/dawnbreaker/judgment_of_light_weapon/judgment_of_light_weapon.vmdl",
                    "particles/econ/items/dawnbreaker/dawnbreaker_judgement_of_light/dawnbreaker_judgement_of_light_weapon_ambient.vpcf",
                    false
                )
            end
        end
    end

    function striker_u__auto:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS

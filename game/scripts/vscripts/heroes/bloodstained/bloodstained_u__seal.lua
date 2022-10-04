bloodstained_u__seal = class({})
LinkLuaModifier("bloodstained_u_modifier_seal", "heroes/bloodstained/bloodstained_u_modifier_seal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_u_modifier_aura_effect", "heroes/bloodstained/bloodstained_u_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_u_modifier_copy", "heroes/bloodstained/bloodstained_u_modifier_copy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_u_modifier_copy_status_efx", "heroes/bloodstained/bloodstained_u_modifier_copy_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained__modifier_extra_hp", "heroes/bloodstained/bloodstained__modifier_extra_hp", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_generic_custom_indicator", "modifiers/_modifier_generic_custom_indicator", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bloodstained_u__seal:CalcStatus(duration, caster, target)
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

    function bloodstained_u__seal:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function bloodstained_u__seal:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bloodstained_u__seal:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_shadow_demon" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[6][upgrade] end
    end

    function bloodstained_u__seal:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_demon" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[6][0] = true
            if self:GetLevel() == 1 then base_hero:SetHotkeys(self, true) end
        end

        self:CheckAbilityCharges(1)
    end

    function bloodstained_u__seal:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function bloodstained_u__seal:GetIntrinsicModifierName()
        return "_modifier_generic_custom_indicator"
    end

    function bloodstained_u__seal:OnSpellStart()
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
        local duration = self:GetSpecialValueFor("duration")

        CreateModifierThinker(
            caster, self, "bloodstained_u_modifier_seal", {duration = duration},
            point, caster:GetTeamNumber(), false
        )

        if IsServer() then
            caster:EmitSound("hero_bloodseeker.bloodRite")
            caster:EmitSound("hero_bloodseeker.rupture.cast")
        end
    end

    function bloodstained_u__seal:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function bloodstained_u__seal:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS
-- CUSTOM INDICATOR

    function bloodstained_u__seal:CastFilterResultLocation(vLoc)
        if IsClient() then
            if self.custom_indicator then
                self.custom_indicator:Register(vLoc)
            end
        end

        return UF_SUCCESS
    end

    function bloodstained_u__seal:CreateCustomIndicator()
        local particle_cast = "particles/bloodstained/seal_finder_aoe.vpcf"
        local radius = self:GetSpecialValueFor("radius")

        self.effect_indicator = ParticleManager:CreateParticle(particle_cast, PATTACH_CUSTOMORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(self.effect_indicator, 1, Vector( radius, radius, radius ))
    end

    function bloodstained_u__seal:UpdateCustomIndicator( loc )
        ParticleManager:SetParticleControl(self.effect_indicator, 0, loc)
    end

    function bloodstained_u__seal:DestroyCustomIndicator()
        ParticleManager:DestroyParticle(self.effect_indicator, false)
        ParticleManager:ReleaseParticleIndex(self.effect_indicator)
    end
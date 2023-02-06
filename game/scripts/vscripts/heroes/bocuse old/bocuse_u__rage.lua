bocuse_u__rage = class({})
LinkLuaModifier("bocuse_u_modifier_rage", "heroes/bocuse/bocuse_u_modifier_rage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_u_modifier_rage_status_efx", "heroes/bocuse/bocuse_u_modifier_rage_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_u_modifier_exhaustion", "heroes/bocuse/bocuse_u_modifier_exhaustion", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("bocuse_u_modifier_exhaustion_status_efx", "heroes/bocuse/bocuse_u_modifier_exhaustion_status_efx", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("bocuse_u_modifier_passive", "heroes/bocuse/bocuse_u_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_u_modifier_jump", "heroes/bocuse/bocuse_u_modifier_jump", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bocuse_u__rage:CalcStatus(duration, caster, target)
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

    function bocuse_u__rage:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function bocuse_u__rage:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bocuse_u__rage:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_pudge" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[6][upgrade] end
    end

    function bocuse_u__rage:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_pudge" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[6][0] = true
            if self:GetLevel() == 1 then base_hero:SetHotkeys(self, true) end
        end

        self:CheckAbilityCharges(self.base_charges)
        self:CheckAbilityCharges(1)
    end

    function bocuse_u__rage:Spawn()
        self.kills = 0
        self.base_charges = 1
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function bocuse_u__rage:GetIntrinsicModifierName()
        return "bocuse_u_modifier_passive"
    end

    function bocuse_u__rage:OnSpellStart()
        local caster = self:GetCaster()
        local duration = CalcStatus(self:GetSpecialValueFor("duration"), caster, caster)

        -- UP 6.11
        if self:GetRank(11) then
            caster:AddNewModifier(caster, self, "bocuse_u_modifier_jump", {duration = 0.5})
        end

        caster:AddNewModifier(caster, self, "bocuse_u_modifier_rage", {duration = duration})
    end

    function bocuse_u__rage:AddKillPoint(pts)
        local caster = self:GetCaster()
        self.kills = self.kills + pts

        local base_stats = caster:FindAbilityByName("base_stats")
	    if base_stats then base_stats:AddBaseStat("CON", 1) end

        self:PlayEfxKill(caster)
    end

    function bocuse_u__rage:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function bocuse_u__rage:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS

    function bocuse_u__rage:PlayEfxKill(target)
        local particle_cast = "particles/econ/items/techies/techies_arcana/techies_suicide_kills_arcana.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_OVERHEAD_FOLLOW, target)
        ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())

        local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
        ParticleManager:SetParticleControl(nFXIndex, 1, Vector(1, 0, 0))
        ParticleManager:ReleaseParticleIndex(nFXIndex)
    end
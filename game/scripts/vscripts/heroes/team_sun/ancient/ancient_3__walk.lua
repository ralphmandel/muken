ancient_3__walk = class({})
LinkLuaModifier("ancient_3_modifier_walk", "heroes/ancient/ancient_3_modifier_walk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_3_modifier_debuff", "heroes/ancient/ancient_3_modifier_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_3_modifier_avatar", "heroes/ancient/ancient_3_modifier_avatar", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_3_modifier_channel", "heroes/ancient/ancient_3_modifier_channel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_3_modifier_efx_hands", "heroes/ancient/ancient_3_modifier_efx_hands", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_3_modifier_walk_status_efx", "heroes/ancient/ancient_3_modifier_walk_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_petrified", "modifiers/_modifier_petrified", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_petrified_status_efx", "modifiers/_modifier_petrified_status_efx", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function ancient_3__walk:CalcStatus(duration, caster, target)
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

    function ancient_3__walk:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function ancient_3__walk:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function ancient_3__walk:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_elder_titan" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[3][upgrade] end
    end

    function ancient_3__walk:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_elder_titan" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[3][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function ancient_3__walk:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function ancient_3__walk:OnSpellStart()
        local caster = self:GetCaster()
        local time = self:GetChannelTime()

        if caster:HasModifier("ancient_3_modifier_walk") then
            caster:Interrupt()
            return
        end

        caster:RemoveModifierByName("ancient_3_modifier_walk")
        caster:RemoveModifierByName("ancient_3_modifier_channel")
        caster:AddNewModifier(caster, self, "ancient_3_modifier_channel", {duration = time})
        
        self:EndCooldown()
        self:SetActivated(false)
    end

    function ancient_3__walk:OnChannelFinish(bInterrupted)
        local caster = self:GetCaster()
        self:SetActivated(true)
        self:StartCooldown(5)

        caster:RemoveModifierByName("ancient_3_modifier_channel")
        caster:RemoveModifierByName("ancient_3_modifier_walk")

        if bInterrupted == false then
            caster:AddNewModifier(caster, self, "ancient_3_modifier_walk", {})

            if IsServer() then
                caster:EmitSound("Ancient.Aura.Cast")
                caster:EmitSound("Ancient.Aura.Effect")
                caster:EmitSound("Ancient.Aura.Layer")
            end
        end
    end

    function ancient_3__walk:GetChannelTime()
        local channel = self:GetCaster():FindAbilityByName("_channel")
        local channel_time = self:GetSpecialValueFor("channel_time")
        return channel_time * (1 - (channel:GetLevel() * channel:GetSpecialValueFor("channel") * 0.01))
    end

    function ancient_3__walk:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

    function ancient_3__walk:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function ancient_3__walk:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS
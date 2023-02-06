bocuse_4__enhance = class({})
LinkLuaModifier("bocuse_4_modifier_enhance", "heroes/bocuse/bocuse_4_modifier_enhance", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_4_modifier_end", "heroes/bocuse/bocuse_4_modifier_end", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bocuse_4__enhance:CalcStatus(duration, caster, target)
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

    function bocuse_4__enhance:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function bocuse_4__enhance:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bocuse_4__enhance:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_pudge" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[4][upgrade] end
    end

    function bocuse_4__enhance:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_pudge" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[4][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(self.base_charges)
    end

    function bocuse_4__enhance:Spawn()
        self.base_charges = 1
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function bocuse_4__enhance:OnSpellStart()
        -- UP 4.22
        if self:GetRank(22) then
            self:StartBuff()
        else
            self:StartPreBuff()
        end
    end

    function bocuse_4__enhance:OnChannelFinish(bInterrupted)
        local caster = self:GetCaster()

        caster:FindModifierByName("base_hero_mod"):ChangeActivity("trapper")
        caster:FadeGesture(ACT_DOTA_VICTORY)

        if bInterrupted == true then
            self:SetActivated(true)
            self:StartCooldown(5)
            return
        end

        self:StartBuff()
    end

    function bocuse_4__enhance:StartPreBuff()
        local caster = self:GetCaster()
        caster:FindModifierByName("base_hero_mod"):ChangeActivity("ftp_dendi_back")
        caster:StartGesture(ACT_DOTA_VICTORY)

        if IsServer() then
            caster:EmitSound("DOTA_Item.Cheese.Activate")
            caster:EmitSound("DOTA_Item.RepairKit.Target")
        end

        self:EndCooldown()
        self:SetActivated(false)
    end

    function bocuse_4__enhance:StartBuff()
        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")

        caster:AddNewModifier(caster, self, "bocuse_4_modifier_enhance", {
            duration = CalcStatus(duration, caster, caster)
        })
    end

    function bocuse_4__enhance:GetBehavior()
        local behavior = DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_NO_TARGET

        if self:GetCurrentAbilityCharges() == 0 then return behavior end

        if self:GetCurrentAbilityCharges() % 2 == 0 then
            behavior = DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET
        end

        return behavior
    end

    function bocuse_4__enhance:GetChannelTime()
        local channel = self:GetCaster():FindAbilityByName("_channel")
        local channel_time = self:GetSpecialValueFor("channel_time")
        return channel_time * (1 - (channel:GetLevel() * channel:GetSpecialValueFor("channel") * 0.01))
    end

    function bocuse_4__enhance:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function bocuse_4__enhance:CheckAbilityCharges(charges)
        -- UP 4.22
        if self:GetRank(22) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS
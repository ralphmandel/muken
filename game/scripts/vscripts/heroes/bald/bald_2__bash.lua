bald_2__bash = class({})
LinkLuaModifier("bald_2_modifier_heap", "heroes/bald/bald_2_modifier_heap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bald_2_modifier_dash", "heroes/bald/bald_2_modifier_dash", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("bald_2_modifier_impact", "heroes/bald/bald_2_modifier_impact", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("bald_2_modifier_gesture", "heroes/bald/bald_2_modifier_gesture", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bald_2__bash:CalcStatus(duration, caster, target)
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

    function bald_2__bash:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function bald_2__bash:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bald_2__bash:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_bristleback" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[2][upgrade] end
    end

    function bald_2__bash:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_bristleback" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[2][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function bald_2__bash:Spawn()
        self.spin_range = 0
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function bald_2__bash:OnSpellStart()
        local caster = self:GetCaster()

        if caster:HasModifier("bald_2_modifier_heap") then
            self:PerformDash()
        else
            self:PrepareDash()
        end
    end

    function bald_2__bash:PrepareDash()
        local caster = self:GetCaster()
        local max_charge = self:GetSpecialValueFor("max_charge")

        caster:AddNewModifier(caster, self, "bald_2_modifier_heap", {
            duration = max_charge
        })

        self:EndCooldown()
        self:StartCooldown(0.5)
    end

    function bald_2__bash:PerformDash()
        local caster = self:GetCaster()
        self.target = self:GetCursorTarget()

        local heap = caster:FindModifierByName("bald_2_modifier_heap")
        if heap then
            local elapsed_time = heap:GetDuration() - heap.time

            caster:AddNewModifier(caster, self, "bald_2_modifier_dash", {
                duration = (elapsed_time + 1) * 0.1
            })

            heap.dash = true
            heap:Destroy()
        end
    end

    function bald_2__bash:OnOwnerSpawned()
        self:SetActivated(true)
    end

    function bald_2__bash:GetAbilityTextureName()
        if self:GetCaster():HasModifier("bald_2_modifier_heap") then
            return "bald_bash_2"
        else
            return "bald_bash"
        end
    end

    function bald_2__bash:GetCastRange(vLocation, hTarget)
        return self:GetCurrentAbilityCharges() * 50
    end

    function bald_2__bash:GetBehavior()
        if self:GetCaster():HasModifier("bald_2_modifier_heap") then
            return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
        else
            return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
        end
    end

    function bald_2__bash:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end

        if self:GetCaster():HasModifier("bald_2_modifier_heap") then
            return 0
        end

        return manacost * level
    end

    function bald_2__bash:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(self.spin_range + charges)
    end

-- EFFECTS
bloodstained_5__tear = class({})
LinkLuaModifier("bloodstained_5_modifier_tear", "heroes/bloodstained/bloodstained_5_modifier_tear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_5_modifier_blood", "heroes/bloodstained/bloodstained_5_modifier_blood", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bloodstained_5__tear:CalcStatus(duration, caster, target)
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

    function bloodstained_5__tear:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function bloodstained_5__tear:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bloodstained_5__tear:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_shadow_demon" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[5][upgrade] end
    end

    function bloodstained_5__tear:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_demon" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[5][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function bloodstained_5__tear:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function bloodstained_5__tear:OnToggle()
        local caster = self:GetCaster()

        if self:GetToggleState() then
            caster:AddNewModifier(caster, self, "bloodstained_5_modifier_tear", {})
            self:SetActivated(false)

            -- UP 5.41
            if self:GetRank(41) then
                Timers:CreateTimer(0.35, function()
                    self:PlayEfxShake()
                end)             
            end

            Timers:CreateTimer(1.5, function()
                self:SetActivated(true)
            end)
        else
            local refresh = self:GetSpecialValueFor("refresh")

            -- UP 5.12
            if self:GetRank(12) then
                refresh = refresh - 10
            end

            self:StartCooldown(refresh)

            caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
            caster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
            caster:AttackNoEarlierThan(0.6, 99)

            Timers:CreateTimer(0.6, function()
                caster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
            end)

            Timers:CreateTimer(0.45, function()
                caster:RemoveModifierByName("bloodstained_5_modifier_tear")
            end)
        end
    end

    function bloodstained_5__tear:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function bloodstained_5__tear:GetAOERadius()
        local radius = self:GetSpecialValueFor("radius")
        if self:GetCurrentAbilityCharges() == 0 then return radius end
        if self:GetCurrentAbilityCharges() % 2 == 0 then radius = radius + 100 end
        return radius
    end

    function bloodstained_5__tear:CheckAbilityCharges(charges)
        -- UP 5.21
        if self:GetRank(21) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS

    function bloodstained_5__tear:PlayEfxShake()
        local caster = self:GetCaster()
        local string_3 = "particles/osiris/poison_alt/osiris_poison_splash_shake.vpcf"
        local particle_3 = ParticleManager:CreateParticle(string_3, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(particle_3, 0, caster:GetOrigin())
        ParticleManager:SetParticleControl(particle_3, 1, Vector(500, 0, 0))
    end


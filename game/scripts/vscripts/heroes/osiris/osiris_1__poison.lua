osiris_1__poison = class({})
LinkLuaModifier("osiris_1_modifier_passive", "heroes/osiris/osiris_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("osiris_1_modifier_poison", "heroes/osiris/osiris_1_modifier_poison", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("osiris_1_modifier_poison_stack", "heroes/osiris/osiris_1_modifier_poison_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("osiris_1_modifier_poison_status_efx", "heroes/osiris/osiris_1_modifier_poison_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function osiris_1__poison:CalcStatus(duration, caster, target)
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

    function osiris_1__poison:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function osiris_1__poison:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function osiris_1__poison:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_undying" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[1][upgrade] end
    end

    function osiris_1__poison:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_undying" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[1][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function osiris_1__poison:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function osiris_1__poison:GetIntrinsicModifierName()
        return "osiris_1_modifier_passive"
    end

    function osiris_1__poison:CalcHPLost(amount)
        local caster = self:GetCaster()
        if not self.current_hp then self.current_hp = 0 end
        if not self.delay then self.delay = false end

        self.current_hp = self.current_hp + amount

        if self.current_hp >= self:GetSpecialValueFor("hp")
        and caster:IsAlive() and self.delay == false then
            self.current_hp = 0
            self.delay = true

            caster:AttackNoEarlierThan(10, 20)
            caster:FadeGesture(ACT_DOTA_UNDYING_TOMBSTONE)
            caster:StartGesture(ACT_DOTA_UNDYING_TOMBSTONE)

            Timers:CreateTimer(0.5, function()
                self.delay = false
                if caster:IsAlive() then
                    self:Release()
                end
            end)

            Timers:CreateTimer(1.2, function()
                if self.delay == false then
                    caster:AttackNoEarlierThan(1, 1)
                end
            end)
        end
    end

    function osiris_1__poison:Release()
        local caster = self:GetCaster()
        local poison_duration = self:GetSpecialValueFor("poison_duration")
        local poison_radius = self:GetSpecialValueFor("poison_radius")

        caster:Purge(false, true, false, false, false)
        self:PlayEfxRelease(poison_radius)
    
        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), caster:GetOrigin(), nil, poison_radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false
        )
    
        for _,enemy in pairs(enemies) do
            enemy:AddNewModifier(caster, self, "osiris_1_modifier_poison", {
                duration = self:CalcStatus(poison_duration, caster, enemy)
            })
        end
    end

    function osiris_1__poison:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function osiris_1__poison:CheckAbilityCharges(charges)
        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS

    function osiris_1__poison:PlayEfxRelease(poison_radius)
        local caster = self:GetCaster()
        local effect = ParticleManager:CreateParticle("particles/osiris/poison_alt/osiris_poison_splash.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(effect, 0, caster:GetOrigin())
        ParticleManager:SetParticleControl(effect, 1, Vector(poison_radius, 0, 0))

        -- local string = "particles/osiris/osiris_poison.vpcf"
        -- local particle = ParticleManager:CreateParticle(string, PATTACH_WORLDORIGIN, nil)
        -- ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
        -- ParticleManager:SetParticleControl(particle, 1, self.parent:GetOrigin())
        -- ParticleManager:ReleaseParticleIndex(particle)

        if IsServer() then caster:EmitSound("Hero_Venomancer.VenomousGale") end
    end
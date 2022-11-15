bloodstained_1__rage = class({})
LinkLuaModifier("bloodstained_1_modifier_rage", "heroes/bloodstained/bloodstained_1_modifier_rage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_1_modifier_rage_status_efx", "heroes/bloodstained/bloodstained_1_modifier_rage_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_1_modifier_call", "heroes/bloodstained/bloodstained_1_modifier_call", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_1_modifier_call_status_efx", "heroes/bloodstained/bloodstained_1_modifier_call_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_1_modifier_passive_status_efx", "heroes/bloodstained/bloodstained_1_modifier_passive_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bloodstained_1__rage:CalcStatus(duration, caster, target)
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

    function bloodstained_1__rage:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function bloodstained_1__rage:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bloodstained_1__rage:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_shadow_demon" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[1][upgrade] end
    end

    function bloodstained_1__rage:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_demon" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[1][0] = true
            Timers:CreateTimer(0.2, function()
				if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
			end)
        end

        self:CheckAbilityCharges(1)
    end

    function bloodstained_1__rage:Spawn()
        self:CheckAbilityCharges(0)
        if self:IsTrained() == false then self:UpgradeAbility(true) end
    end

-- SPELL START

    function bloodstained_1__rage:GetIntrinsicModifierName()
        return "bloodstained_1_modifier_passive_status_efx"
    end

    function bloodstained_1__rage:OnOwnerSpawned()
        self:SetActivated(true)
    end

    function bloodstained_1__rage:OnSpellStart()
        local caster = self:GetCaster()

        --caster:StartGesture(1591)
        --caster:StartGesture(1784)
        if IsServer() then caster:StartGesture(1784) end
        caster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
        caster:AttackNoEarlierThan(0.7, 99)

        self:EndCooldown()
        self:SetActivated(false)

        Timers:CreateTimer(0.7, function()
            caster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
        end)

        Timers:CreateTimer(0.35, function()
            if caster:IsAlive() then
                self:ApllyBuff()
            else
                self:StartCooldown(self:GetEffectiveCooldown(self:GetLevel()))
                self:SetActivated(true)
            end
        end)
    end

    function bloodstained_1__rage:ApllyBuff()
        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")

        -- UP 1.21
        if self:GetRank(21) then
            caster:Purge(false, true, false, true, false)
        end

        -- UP 1.31
        if self:GetRank(31) then
            self:PerformCall()
        end

        caster:AddNewModifier(caster, self, "bloodstained_1_modifier_rage", {
            duration = self:CalcStatus(duration, caster, caster)
        })

        if IsServer() then
            caster:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
            caster:EmitSound("Bloodstained.fury")
            caster:EmitSound("Bloodstained.rage")
        end
    end

    function bloodstained_1__rage:PerformCall()
        local caster = self:GetCaster()
        self:PlayEfxCall(self:GetAOERadius())

        local units = FindUnitsInRadius(
			caster:GetTeamNumber(), caster:GetOrigin(), nil, self:GetAOERadius(),
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false
		)

        for _,unit in pairs(units) do
            unit:AddNewModifier(caster, self, "bloodstained_1_modifier_call", {
                duration = self:CalcStatus(5, caster, unit)
            })
        end
    end

    function bloodstained_1__rage:GetBehavior()
        if self:GetCurrentAbilityCharges() == 0 then return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE end
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end

    function bloodstained_1__rage:GetAOERadius()
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() % 3 == 0 then return 375 end
        return 0
    end

    function bloodstained_1__rage:GetCooldown(iLevel)
        local cooldown = self:GetSpecialValueFor("cooldown")
        if self:GetCurrentAbilityCharges() == 0 then return cooldown end
        if self:GetCurrentAbilityCharges() % 5 == 0 then return 0 end
        return cooldown
    end

    function bloodstained_1__rage:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function bloodstained_1__rage:CheckAbilityCharges(charges)
        -- UP 1.21
        if self:GetRank(21) then
            charges = charges * 2
        end

        -- UP 1.31
        if self:GetRank(31) then
            charges = charges * 3
        end

        -- UP 1.32
        if self:GetRank(32) then
            charges = charges * 5
        end

        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS

    function bloodstained_1__rage:PlayEfxCall(radius)
        local caster = self:GetCaster()
        local particle_cast = "particles/econ/items/axe/axe_ti9_immortal/axe_ti9_call.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControl(effect_cast, 2, Vector(radius, radius, radius))
        ParticleManager:SetParticleControlEnt(effect_cast, 1, caster, PATTACH_POINT_FOLLOW, "attach_mouth", Vector(0,0,0), true)
        ParticleManager:ReleaseParticleIndex(effect_cast)
    end
icebreaker_u__blink = class({})
LinkLuaModifier("icebreaker_u_modifier_blink", "heroes/icebreaker/icebreaker_u_modifier_blink", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function icebreaker_u__blink:CalcStatus(duration, caster, target)
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

    function icebreaker_u__blink:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function icebreaker_u__blink:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function icebreaker_u__blink:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[7][upgrade] end
    end

    function icebreaker_u__blink:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[7][0] = true
            if self:GetLevel() == 1 then base_hero:SetHotkeys(self, true) end
        end

        local charges = 1

        -- UP 7.11
        if self:GetRank(11) then
            charges = charges * 2 -- manacost
        end

		-- UP 7.21
        if self:GetRank(21) then
            charges = charges * 3 -- range
        end

		-- UP 7.41
        if self:GetRank(41) then
            charges = charges * 5 -- aoe
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function icebreaker_u__blink:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function icebreaker_u__blink:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local origin = caster:GetOrigin()
        local point = self:GetCursorPosition()
        --local direction = (point - origin)

        if target:GetTeamNumber()~=caster:GetTeamNumber() then
            if target:TriggerSpellAbsorb(self) then
                return
            end
        end

        if IsServer() then caster:EmitSound("Hero_QueenOfPain.Blink_out") end

        local direction = target:GetForwardVector() * (-1)
        local blink_point = target:GetAbsOrigin() + direction * 130
        caster:SetAbsOrigin(blink_point)
        caster:SetForwardVector(-direction)
        FindClearSpaceForUnit(caster, blink_point, true)

        ProjectileManager:ProjectileDodge(caster)
        caster:MoveToTargetToAttack(target)

        self:PlayEfxBlink(direction, origin, target)
    end

    function icebreaker_u__blink:CastFilterResultTarget(hTarget)
        local caster = self:GetCaster()
        if caster == hTarget then return UF_FAIL_CUSTOM end

        if caster:HasModifier("icebreaker_3_modifier_skin") then
            if caster:GetRangeToUnit(hTarget) > self:GetCastRange(caster:GetOrigin(), hTarget) then
                return UF_FAIL_CUSTOM
            end
        end

        if hTarget:GetTeamNumber() ~= caster:GetTeamNumber()
        and hTarget:HasModifier("icebreaker_1_modifier_frozen") then
            return UF_SUCCESS
        end

        local result = UnitFilter(
            hTarget, DOTA_UNIT_TARGET_TEAM_BOTH,DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
            0, caster:GetTeamNumber()
        )
        
        if result ~= UF_SUCCESS then return result end

        return UF_SUCCESS
    end

    function icebreaker_u__blink:GetCustomCastErrorTarget(hTarget)
        if self:GetCaster() == hTarget then
            return "#dota_hud_error_cant_cast_on_self"
        end

        return "No Range"
    end

    function icebreaker_u__blink:GetBehavior()
        local behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
        if self:GetCurrentAbilityCharges() == 0 then return behavior end

        if self:GetCurrentAbilityCharges() % 3 == 0 then
            behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
        end

        if self:GetCurrentAbilityCharges() % 5 == 0 then
            behavior = behavior + DOTA_ABILITY_BEHAVIOR_AOE
        end

        return behavior
    end

    function icebreaker_u__blink:GetAOERadius()
        local radius = 0
        if self:GetCurrentAbilityCharges() == 0 then return radius end
        if self:GetCurrentAbilityCharges() % 5 == 0 then radius = 275 end
        return radius
    end

    function icebreaker_u__blink:GetCastRange(vLocation, hTarget)
        local cast_range = self:GetSpecialValueFor("cast_range")
        if self:GetCurrentAbilityCharges() == 0 then return cast_range end
        if self:GetCurrentAbilityCharges() % 3 == 0 then return cast_range + 1000 end
        return cast_range
    end

    function icebreaker_u__blink:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() % 2 == 0 then manacost = manacost - 15 end
        return manacost * level
    end

-- EFFECTS

    function icebreaker_u__blink:PlayEfxBlink(direction, origin, target)
        local caster = self:GetCaster()
        local particle_cast_a = "particles/econ/events/winter_major_2017/blink_dagger_start_wm07.vpcf" 
        local particle_cast_b = "particles/econ/events/winter_major_2017/blink_dagger_end_wm07.vpcf"

        local effect_cast_a = ParticleManager:CreateParticle(particle_cast_a, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(effect_cast_a, 0, origin)
        ParticleManager:SetParticleControlForward(effect_cast_a, 0, direction:Normalized())
        ParticleManager:SetParticleControl(effect_cast_a, 1, origin + direction)
        ParticleManager:ReleaseParticleIndex(effect_cast_a)

        local effect_cast_b = ParticleManager:CreateParticle(particle_cast_b, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(effect_cast_b, 0, caster:GetOrigin())
        ParticleManager:SetParticleControlForward(effect_cast_b, 0, direction:Normalized())
        ParticleManager:ReleaseParticleIndex(effect_cast_b)

        if IsServer() then caster:EmitSound("Hero_Antimage.Blink_in.Persona") end
    end

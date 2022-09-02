dasdingo_3__hex = class({})
LinkLuaModifier("dasdingo_3_modifier_passive", "heroes/dasdingo/dasdingo_3_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_3_modifier_hex", "heroes/dasdingo/dasdingo_3_modifier_hex", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function dasdingo_3__hex:CalcStatus(duration, caster, target)
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

    function dasdingo_3__hex:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function dasdingo_3__hex:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function dasdingo_3__hex:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[3][upgrade] end
    end

    function dasdingo_3__hex:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[3][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        local charges = 1

        -- UP 3.41
        if self:GetRank(41) then
            charges = charges * 3
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function dasdingo_3__hex:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function dasdingo_3__hex:GetIntrinsicModifierName()
        return "dasdingo_3_modifier_passive"
    end

    function dasdingo_3__hex:GetAOERadius()
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() == 1 then return 0 end
        if self:GetCurrentAbilityCharges() % 3 == 0 then return 225 end
        return 0
    end

    function dasdingo_3__hex:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local duration = self:GetSpecialValueFor("duration")
        local gold_chance = self:GetSpecialValueFor("gold_chance")
        local gold_bonus = self:GetSpecialValueFor("gold_bonus")

	    local base_stats = caster:FindAbilityByName("base_stats")
	    if base_stats then gold_chance = gold_chance * base_stats:GetCriticalChance() end

        if target:TriggerSpellAbsorb(self) then return end

        if target:HasModifier("strider_1_modifier_spirit") == false
        and target:HasModifier("bloodstained_u_modifier_copy") == false
        and target:IsIllusion() then
            target:Kill(self, caster)
        end

        local level = target:GetLevel()
        if RandomFloat(1, 100) <= (gold_chance - (level * 3))
        and target:GetTeamNumber() == DOTA_TEAM_NEUTRALS then
            local gold = gold_bonus + (level * 3)
            target:Kill(self, caster)
            caster:ModifyGold(gold, false, 18)
            
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, caster, gold, caster)
            self:PlayEfxStart(target)
            return
        end

        -- UP 3.21
        if self:GetRank(21) then
            local damageTable = {
                victim = target,
                attacker = caster,
                damage = target:GetMaxHealth() * 0.1,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = self
            }
            ApplyDamage(damageTable)
            
            if IsServer() then target:EmitSound("Hero_Juggernaut.BladeDance") end
        end

        -- UP 3.41
        if self:GetRank(41) then
            local radius = 225
            local enemies = FindUnitsInRadius(
                caster:GetTeamNumber(), target:GetOrigin(), nil, radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
                DOTA_UNIT_TARGET_FLAG_NO_INVIS, 0, false
            )
            
            for _,enemy in pairs(enemies) do
                enemy:AddNewModifier(caster, self, "dasdingo_3_modifier_hex", {
                    duration = self:CalcStatus(duration, caster, target)
                })
            end

            self:PlayEfxAoe(target, radius)
        end

        -- UP 3.22
        if self:GetRank(22) then
            duration = duration + 0.75
        end

        if target:IsAlive() then
            target:AddNewModifier(caster, self, "dasdingo_3_modifier_hex", {
                duration = self:CalcStatus(duration, caster, target)
            })
        end
        
        self:PlayEfxStart(target)
    end

    function dasdingo_3__hex:CastFilterResultTarget(hTarget)
        local caster = self:GetCaster()
        local flag = 0

        if caster == hTarget then
            return UF_FAIL_CUSTOM
        end

        local result = UnitFilter(
            hTarget,	-- Target Filter
            DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
            flag,	-- Unit Flag
            caster:GetTeamNumber()	-- Team reference
        )
        
        if result ~= UF_SUCCESS then
            return result
        end

        return UF_SUCCESS
    end

    function dasdingo_3__hex:GetCustomCastErrorTarget( hTarget )
        if self:GetCaster() == hTarget then
            return "#dota_hud_error_cant_cast_on_self"
        end
    end

    function dasdingo_3__hex:GetBehavior()
        if self:GetCurrentAbilityCharges() == 0 then return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET end
        if self:GetCurrentAbilityCharges() == 1 then return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET end
        if self:GetCurrentAbilityCharges() % 3 == 0 then return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE end
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    end

    function dasdingo_3__hex:GetCastRange(vLocation, hTarget)
        local cast_range = self:GetSpecialValueFor("cast_range")
        if self:GetCurrentAbilityCharges() == 0 then return cast_range end
        return cast_range
    end

    function dasdingo_3__hex:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS

    function dasdingo_3__hex:PlayEfxStart(target)
        local particle_cast = "particles/units/heroes/hero_lion/lion_spell_voodoo.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, target)
        ParticleManager:ReleaseParticleIndex(effect_cast)

        if IsServer() then target:EmitSound("Hero_Lion.Voodoo") end
    end

    function dasdingo_3__hex:PlayEfxAoe(target, radius)
        local particle_cast = "particles/dasdingo/dasdingo_aoe_hex.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(effect_cast, 2, Vector(radius, radius, radius))
        ParticleManager:SetParticleControlEnt(effect_cast, 1, target, PATTACH_POINT_FOLLOW, "attach_mouth", Vector(0,0,0), true)
        ParticleManager:ReleaseParticleIndex(effect_cast)
    end
ancient_2__leap = class({})
LinkLuaModifier("ancient_2_modifier_passive", "heroes/ancient/ancient_2_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_2_modifier_combo", "heroes/ancient/ancient_2_modifier_combo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_2_modifier_jump", "heroes/ancient/ancient_2_modifier_jump", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("_modifier_generic_arc", "modifiers/_modifier_generic_arc", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function ancient_2__leap:CalcStatus(duration, caster, target)
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

    function ancient_2__leap:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function ancient_2__leap:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function ancient_2__leap:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_elder_titan" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[2][upgrade] end
    end

    function ancient_2__leap:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_elder_titan" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[2][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        self:CheckAbilityCharges(1)
    end

    function ancient_2__leap:Spawn()
        self:CheckAbilityCharges(0)
    end

-- SPELL START

    function ancient_2__leap:GetIntrinsicModifierName()
        return "ancient_2_modifier_passive"
    end

    function ancient_2__leap:OnAbilityPhaseStart()
        -- UP 2.32
        if self:GetRank(32) then
            self:PrepareJump()
            return true
        end

        if IsServer() then self:GetCaster():EmitSound("Hero_ElderTitan.PreAttack") end

        return true
    end

    function ancient_2__leap:PrepareJump()
        local caster = self:GetCaster()
        self.point = self:GetCursorPosition()
        local jump_range = 900
        local distance = (caster:GetOrigin() - self.point):Length2D()
        local percent = distance / jump_range
        self.duration = percent * 1.5
        self.height = jump_range * 0.4 * percent

        caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)

        if self.duration < 0.4 then
            Timers:CreateTimer((self.duration), function()
                caster:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
                caster:StartGesture(ACT_DOTA_CAST_ABILITY_5)
                if IsServer() then caster:EmitSound("Hero_ElderTitan.PreAttack") end
            end)
        end

        if self.duration >= 0.6 then
            Timers:CreateTimer((0.2), function()
                if IsServer() then caster:EmitSound("Ancient.Jump") end
            end)
        end
    end

    function ancient_2__leap:OnSpellStart()
        -- UP 2.32
        if self:GetRank(32) then
            self:PerformJump()
            return
        end

        -- UP 2.41
        if self:GetRank(41) then
            self:PerformCombo()
            return
        end

        self:DoImpact()
    end

    function ancient_2__leap:PerformJump()
        local caster = self:GetCaster()
        caster:RemoveModifierByName("ancient_2_modifier_jump")
        caster:AddNewModifier(caster, self, "ancient_2_modifier_jump", {})
    end

    function ancient_2__leap:PerformCombo()
        local caster = self:GetCaster()
        caster:RemoveModifierByName("ancient_2_modifier_combo")
        caster:AddNewModifier(caster, self, "ancient_2_modifier_combo", {})
    end

    function ancient_2__leap:DoImpact()
        local caster = self:GetCaster()
        local radius = self:GetAOERadius()
        local crit = self:RollCritical()

        self:PlayEfxStart(radius)
        if crit then self:PlayEfxCrit(caster) end
        GridNav:DestroyTreesAroundPoint(caster:GetOrigin(), radius, false)

        local damageTable = {
            attacker = caster, ability = self,
            damage = self:GetAbilityDamage(),
            damage_type = self:GetAbilityDamageType()
        }

        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), caster:GetOrigin(), nil, radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            self:GetAbilityTargetFlags(), 0, false
        )

        for _,enemy in pairs(enemies) do
            local base_stats = caster:FindAbilityByName("base_stats")
            if base_stats then base_stats:SetForceCritSpell(0, crit, self:GetAbilityDamageType()) end         

            damageTable.victim = enemy
            ApplyDamage(damageTable)
        end
    end

    function ancient_2__leap:RollCritical()
        local result = nil
        local base_stats = self:GetCaster():FindAbilityByName("base_stats")
        
        if base_stats then
            if base_stats:RollChance() then
                return true
            end
        end

        return result
    end

    function ancient_2__leap:GetAOERadius()
        if self:GetCurrentAbilityCharges() == 0 then return self:GetSpecialValueFor("radius") end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return self:GetSpecialValueFor("radius") + 50 end
        return self:GetSpecialValueFor("radius")
    end

    function ancient_2__leap:GetCastRange(vLocation, hTarget)
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() % 3 == 0 and self:GetCurrentAbilityCharges() % 7 == 0 then return 250 end
        if self:GetCurrentAbilityCharges() % 3 == 0 then return 1000 end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return self:GetSpecialValueFor("radius") + 50 end
        return self:GetSpecialValueFor("radius")
    end

    function ancient_2__leap:GetBehavior()
        if self:GetCurrentAbilityCharges() == 0 then return DOTA_ABILITY_BEHAVIOR_NO_TARGET end
        if self:GetCurrentAbilityCharges() % 3 == 0 then return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES end
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    end

    function ancient_2__leap:GetCastAnimation()
        if self:GetCurrentAbilityCharges() == 0 then return ACT_DOTA_CAST_ABILITY_5 end
        if self:GetCurrentAbilityCharges() % 3 == 0 then return end
        return ACT_DOTA_CAST_ABILITY_5
    end

    function ancient_2__leap:GetAbilityDamage()
        local damage = self:GetSpecialValueFor("damage")
        if self:GetCurrentAbilityCharges() == 0 then return damage end
        if self:GetCurrentAbilityCharges() % 5 == 0 then damage = damage - 60 end
        return damage
    end

    function ancient_2__leap:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

    function ancient_2__leap:CheckAbilityCharges(charges)
        -- UP 2.11
        if self:GetRank(11) then
            charges = charges * 2
        end

        -- UP 2.32
        if self:GetRank(32) then
            charges = charges * 3
        end

        -- UP 2.41
        if self:GetRank(41) then
            charges = charges * 5
        end

        if self:GetCaster():HasModifier("ancient_3_modifier_walk") then
            charges = charges * 7
        end

        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS

    function ancient_2__leap:PlayEfxStart(radius)
        local caster = self:GetCaster()
        local particle_cast = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_v2.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(effect_cast, 0, caster:GetOrigin())
        ParticleManager:SetParticleControl(effect_cast, 1, Vector(radius, radius, radius))

        if IsServer() then caster:EmitSound("Hero_ElderTitan.EchoStomp") end
    end

    function ancient_2__leap:PlayEfxCrit(target)
        if target:GetPlayerOwner() == nil then return end
        local particle_screen = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_screen.vpcf"
        local effect_screen = ParticleManager:CreateParticleForPlayer(particle_screen, PATTACH_WORLDORIGIN, nil, target:GetPlayerOwner())

        local effect = ParticleManager:CreateParticle("particles/osiris/poison_alt/osiris_poison_splash_shake.vpcf", PATTACH_ABSORIGIN, target)
        ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
        ParticleManager:SetParticleControl(effect, 1, Vector(500, 0, 0))
    end
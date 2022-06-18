genuine_1__shooting = class({})
LinkLuaModifier("genuine_1_modifier_orb", "heroes/genuine/genuine_1_modifier_orb", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_1_modifier_starfall_stack", "heroes/genuine/genuine_1_modifier_starfall_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_0_modifier_fear", "heroes/genuine/genuine_0_modifier_fear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_0_modifier_fear_status_efx", "heroes/genuine/genuine_0_modifier_fear_status_efx", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function genuine_1__shooting:CalcStatus(duration, caster, target)
        local time = duration
        local base_stats_caster = nil
        local base_stats_target = nil

        if caster ~= nil then
            base_stats_caster = caster:FindAbilityByName("base_stats")
        end

        if target ~= nil then
            base_stats_target = target:FindAbilityByName("base_stats")
        end

        if caster == nil then
            if target ~= nil then
                if base_stats_target then
                    local value = base_stats_target.stat_total["RES"] * 0.4
                    local calc = (value * 6) / (1 +  (value * 0.06))
                    time = time * (1 - (calc * 0.01))
                end
            end
        else
            if target == nil then
                if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
            else
                if caster:GetTeamNumber() == target:GetTeamNumber() then
                    if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
                else
                    if base_stats_caster and base_stats_target then
                        local value = (base_stats_caster.stat_total["INT"] - base_stats_target.stat_total["RES"]) * 0.7
                        if value > 0 then
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 + (calc * 0.01))
                        else
                            value = -1 * value
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 - (calc * 0.01))
                        end
                    end
                end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function genuine_1__shooting:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function genuine_1__shooting:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function genuine_1__shooting:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[1][upgrade] end
    end

    function genuine_1__shooting:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then base_hero.ranks[1][0] = true end

        local charges = 1

        -- UP 1.21
        if self:GetRank(21) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function genuine_1__shooting:Spawn()
        self:SetCurrentAbilityCharges(0)
        self.spell_lifesteal = false
    end

-- SPELL START

    function genuine_1__shooting:GetIntrinsicModifierName()
        return "genuine_1_modifier_orb"
    end

    function genuine_1__shooting:GetProjectileName()
        return "particles/genuine/shooting_star/genuine_shooting.vpcf"
    end

    function genuine_1__shooting:OnOrbFire(keys)
        local caster = self:GetCaster()
        if IsServer() then caster:EmitSound("Hero_DrowRanger.FrostArrows") end
    end

    function genuine_1__shooting:OnOrbFail(keys)
        local caster = self:GetCaster()
        local target = keys.target
        
        -- UP 1.31
        if self:GetRank(31) then
            local stacks = 0
            local starfall_stack_mods = target:FindAllModifiersByName("genuine_1_modifier_starfall_stack")
            for _,mod in pairs(starfall_stack_mods) do
                stacks = stacks + 1
            end

            if stacks > 1 then
                for _,mod in pairs(starfall_stack_mods) do mod:Destroy() end
                self:PlayEfxStarfall(target)

                Timers:CreateTimer((0.5), function()
                    if target ~= nil then
                        if IsValidEntity(target) then
                            self:ApplyStarfall(target)
                        end
                    end
                end)
            else
                target:AddNewModifier(caster, self, "genuine_1_modifier_starfall_stack", {duration = 7})
            end
        end
    end

    function genuine_1__shooting:OnOrbImpact(keys)
        local caster = self:GetCaster()
        local bonus_damage = self:GetSpecialValueFor("bonus_damage")
        local target = keys.target

        -- UP 1.31
        if self:GetRank(31) then
            local stacks = 0
            local starfall_stack_mods = target:FindAllModifiersByName("genuine_1_modifier_starfall_stack")
            for _,mod in pairs(starfall_stack_mods) do
                stacks = stacks + 1
            end

            if stacks > 1 then
                for _,mod in pairs(starfall_stack_mods) do mod:Destroy() end
                self:PlayEfxStarfall(target)

                Timers:CreateTimer((0.5), function()
                    if target ~= nil then
                        if IsValidEntity(target) then
                            self:ApplyStarfall(target)
                        end
                    end
                end)
            else
                target:AddNewModifier(caster, self, "genuine_1_modifier_starfall_stack", {duration = 5})
            end
        end

        local damageTable = {
            victim = target,
            attacker = caster,
            damage = bonus_damage,
            damage_type = self:GetAbilityDamageType(),
            ability = self
        }

        self.spell_lifesteal = true
        ApplyDamage(damageTable)

        -- UP 1.41
        if self:GetRank(41) and target:IsAlive()
        and RandomInt(1, 100) <= 25 then
            target:AddNewModifier(caster, self, "genuine_0_modifier_fear", {
                duration = self:CalcStatus(1.5, caster, target)
            })

            Timers:CreateTimer((0.25), function()
                if target ~= nil then
                    if IsValidEntity(target) then
                        if target:IsAlive() == false then
                            if IsServer() then target:StopSound("Genuine.Fear.Loop") end
                        end
                    end
                end
            end)
        end

        if IsServer() then target:EmitSound("Hero_DrowRanger.Marksmanship.Target") end
    end

    function genuine_1__shooting:ApplyStarfall(target)
        local caster = self:GetCaster()
        local starfall_damage = 50
        local starfall_radius = 175
        local damageTable = {
            attacker = caster,
            damage = starfall_damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        }
        
        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), target:GetOrigin(), nil, starfall_radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            0, 0, false
        )

        for _,enemy in pairs(enemies) do
            damageTable.victim = enemy
            ApplyDamage(damageTable)
        end

        if IsServer() then target:EmitSound("Hero_Mirana.Starstorm.Impact") end
    end

    function genuine_1__shooting:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() == 1 then return manacost * level end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return (manacost - 20) * level end
        return manacost * level
    end

-- EFFECTS

    function genuine_1__shooting:PlayEfxStarfall(target)
        local particle_cast = "particles/genuine/starfall/genuine_starfall_attack.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
        ParticleManager:ReleaseParticleIndex(effect_cast)

        if IsServer() then target:EmitSound("Hero_Mirana.Starstorm.Cast") end
    end
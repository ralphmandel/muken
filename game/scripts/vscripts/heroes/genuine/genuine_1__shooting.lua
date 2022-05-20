genuine_1__shooting = class({})
LinkLuaModifier("genuine_1_modifier_orb", "heroes/genuine/genuine_1_modifier_orb", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_1_modifier_starfall_stack", "heroes/genuine/genuine_1_modifier_starfall_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_0_modifier_fear", "heroes/genuine/genuine_0_modifier_fear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_0_modifier_fear_status_effect", "heroes/genuine/genuine_0_modifier_fear_status_effect", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function genuine_1__shooting:CalcStatus(duration, caster, target)
        local time = duration
        local caster_int = nil
        local caster_mnd = nil
        local target_res = nil

        if caster ~= nil then
            caster_int = caster:FindModifierByName("_1_INT_modifier")
            caster_mnd = caster:FindModifierByName("_2_MND_modifier")
        end

        if target ~= nil then
            target_res = target:FindModifierByName("_2_RES_modifier")
        end

        if caster == nil then
            if target ~= nil then
                if target_res then time = time * (1 - target_res:GetStatus()) end
            end
        else
            if target == nil then
                if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
            else
                if caster:GetTeamNumber() == target:GetTeamNumber() then
                    if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
                else
                    if caster_int then time = duration * (1 + caster_int:GetDebuffTime()) end
                    if target_res then time = time * (1 - target_res:GetStatus()) end
                end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function genuine_1__shooting:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
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
        local att = caster:FindAbilityByName("genuine__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

        return att.talents[1][upgrade]
    end

    function genuine_1__shooting:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

        local att = caster:FindAbilityByName("genuine__attributes")
        if att then
            if att:IsTrained() then
                att.talents[1][0] = true
            end
        end
        
        if self:GetLevel() == 1 then
			caster:FindAbilityByName("_2_DEX"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_DEF"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_RES"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_REC"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_MND"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_LCK"):CheckLevelUp(true)
		end

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
                target:AddNewModifier(caster, self, "genuine_1_modifier_starfall_stack", {duration = 5})
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

        -- UP 1.41
        if self:GetRank(41) and RandomInt(1, 100) <= 25 then
            target:AddNewModifier(caster, self, "genuine_0_modifier_fear", {
                duration = self:CalcStatus(1.5, caster, target)
            })
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

        if IsServer() then target:EmitSound("Hero_DrowRanger.Marksmanship.Target") end
    end

    function genuine_1__shooting:ApplyStarfall(target)
        local caster = self:GetCaster()
        local starfall_damage = 125
        local starfall_radius = 300
        local damageTable = {
            attacker = caster,
            damage = starfall_damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        }
        
        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), target:GetOrigin(), nil, starfall_radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false
        )

        for _,enemy in pairs(enemies) do
            damageTable.victim = enemy
            ApplyDamage(damageTable)
        end

        if IsServer() then target:EmitSound("Hero_Mirana.Starstorm.Impact") end
    end

    function genuine_1__shooting:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = self:GetLevel() - 1
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() == 1 then return manacost * (1 + (level* 0.1)) end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return (manacost - 20) * (1 + (level * 0.1)) end
        return manacost * (1 + (level* 0.1))
    end

-- EFFECTS

    function genuine_1__shooting:PlayEfxStarfall(target)
        local particle_cast = "particles/genuine/starfall/genuine_starfall_attack.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
        ParticleManager:ReleaseParticleIndex(effect_cast)

        if IsServer() then target:EmitSound("Hero_Mirana.Starstorm.Cast") end
    end
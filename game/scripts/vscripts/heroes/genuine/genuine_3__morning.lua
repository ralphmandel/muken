genuine_3__morning = class({})
LinkLuaModifier("genuine_3_modifier_morning", "heroes/genuine/genuine_3_modifier_morning", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_3_modifier_passive", "heroes/genuine/genuine_3_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function genuine_3__morning:CalcStatus(duration, caster, target)
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

    function genuine_3__morning:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function genuine_3__morning:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function genuine_3__morning:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[3][upgrade] end
    end

    function genuine_3__morning:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[3][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        local charges = 1
        self:SetCurrentAbilityCharges(charges)
    end

    function genuine_3__morning:Spawn()
        self:SetCurrentAbilityCharges(0)
        self.kills = 0
    end

-- SPELL START

    function genuine_3__morning:GetIntrinsicModifierName()
        return "genuine_3_modifier_passive"
    end

    function genuine_3__morning:OnAbilityPhaseStart()
        local caster = self:GetCaster()
        local passive = caster:FindModifierByName("genuine_3_modifier_passive")
        if passive then passive:PlayEfxBuff() end

        return true
    end

    function genuine_3__morning:OnAbilityPhaseInterrupted()
        local caster = self:GetCaster()
        local passive = caster:FindModifierByName("genuine_3_modifier_passive")
        if passive then passive:StopEfxBuff() end
    end

    function genuine_3__morning:OnOwnerDied()
        local caster = self:GetCaster()
        local passive = caster:FindModifierByName("genuine_3_modifier_passive")
        if passive then passive:StopEfxBuff() end
    end

    function genuine_3__morning:OnSpellStart()
        local caster = self:GetCaster()
        local duration = self:CalcStatus(self:GetSpecialValueFor("duration"), caster, caster)

        local chance = 40
        local base_stats = caster:FindAbilityByName("base_stats")
        if base_stats then chance = chance * base_stats:GetCriticalChance() end

        -- UP 3.41
        if self:GetRank(41)
        and GameRules:IsDaytime()
        and RandomFloat(1, 100) <= chance then
            GameRules:BeginTemporaryNight(duration)
        end

        Timers:CreateTimer((0.1), function()
            if GameRules:IsDaytime() == false or GameRules:IsTemporaryNight() then self:FindEnemies() end
            caster:AddNewModifier(caster, self, "genuine_3_modifier_morning", {duration = duration})
        end)

        if IsServer() then caster:EmitSound("Genuine.Morning") end
    end

    function genuine_3__morning:FindEnemies()
        local caster = self:GetCaster()
        local number = 1

        -- UP 3.41
        if self:GetRank(41) then
            number = 3
        end

        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), caster:GetOrigin(), nil, FIND_UNITS_EVERYWHERE,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, 0, false
        )

        for _,enemy in pairs(enemies) do
            self:PlayEfxStarfall(enemy)

            Timers:CreateTimer((0.5), function()
                if enemy ~= nil then
                    if IsValidEntity(enemy) then
                        self:ApplyStarfall(enemy)
                    end
                end
            end)

            number = number - 1
            if number < 1 then return end
        end

        enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), caster:GetOrigin(), nil, FIND_UNITS_EVERYWHERE,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, 0, false
        )

        for _,enemy in pairs(enemies) do
            self:PlayEfxStarfall(enemy)

            Timers:CreateTimer((0.5), function()
                if enemy ~= nil then
                    if IsValidEntity(enemy) then
                        self:ApplyStarfall(enemy)
                    end
                end
            end)

            number = number - 1
            if number < 1 then return end
        end
    end

    function genuine_3__morning:ApplyStarfall(target)
        local caster = self:GetCaster()
        local star_damage = self:GetSpecialValueFor("star_damage")
        local star_radius = self:GetSpecialValueFor("star_radius")

        local damageTable = {
            attacker = caster,
            damage = star_damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        }
        
        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), target:GetOrigin(), nil, star_radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            0, 0, false
        )

        for _,enemy in pairs(enemies) do
            damageTable.victim = enemy
            ApplyDamage(damageTable)
        end

        if IsServer() then target:EmitSound("Hero_Mirana.Starstorm.Impact") end
    end

    function genuine_3__morning:AddKillPoint(pts)
        local caster = self:GetCaster()
        self.kills = self.kills + pts

        local base_stats = caster:FindAbilityByName("base_stats")
	    if base_stats then base_stats:AddBaseStat("INT", 1) end

        self:PlayEfxKill(caster)
    end

    function genuine_3__morning:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS

    function genuine_3__morning:PlayEfxStarfall(target)
        local particle_cast = "particles/genuine/starfall/genuine_starfall_attack.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
        ParticleManager:ReleaseParticleIndex(effect_cast)

        if IsServer() then target:EmitSound("Hero_Mirana.Starstorm.Cast") end
    end

    function genuine_3__morning:PlayEfxKill(target)
        local particle_cast = "particles/econ/items/techies/techies_arcana/techies_suicide_kills_arcana.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_OVERHEAD_FOLLOW, target)
        ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())

        local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
        ParticleManager:SetParticleControl(nFXIndex, 1, Vector(1, 0, 0))
        ParticleManager:ReleaseParticleIndex(nFXIndex)
    end
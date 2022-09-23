genuine_2__fallen = class({})
LinkLuaModifier("genuine_0_modifier_fear", "heroes/genuine/genuine_0_modifier_fear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_0_modifier_fear_status_efx", "heroes/genuine/genuine_0_modifier_fear_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_2_modifier_dispel", "heroes/genuine/genuine_2_modifier_dispel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function genuine_2__fallen:CalcStatus(duration, caster, target)
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

    function genuine_2__fallen:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function genuine_2__fallen:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function genuine_2__fallen:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[2][upgrade] end
    end

    function genuine_2__fallen:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[2][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end

        local charges = 1
        self:SetCurrentAbilityCharges(charges)
    end

    function genuine_2__fallen:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function genuine_2__fallen:OnSpellStart()
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()

        local projectile_name = "particles/econ/items/drow/drow_ti6_gold/drow_ti6_silence_gold_wave.vpcf"
        local speed = self:GetSpecialValueFor("speed")
        local distance = self:GetSpecialValueFor("distance")
        local radius = self:GetSpecialValueFor("radius")
        local direction = point - caster:GetOrigin()
        direction.z = 0
        direction = direction:Normalized()

        -- UP 2.22
        if self:GetRank(22) then
            speed = speed * 2
            distance = distance * 2
            radius = radius + 150
            projectile_name = "particles/econ/items/drow/drow_ti6_gold/drow_ti6_silence_gold_wave_wide.vpcf"
        end

        local info = {
            Source = caster,
            Ability = self,
            vSpawnOrigin = caster:GetAbsOrigin(),
            
            bDeleteOnHit = false,
            
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            
            EffectName = projectile_name,
            fDistance = distance,
            fStartRadius = radius,
            fEndRadius = radius,
            vVelocity = direction * speed,

            bProvidesVision = true,
            iVisionRadius = radius,
            iVisionTeamNumber = caster:GetTeamNumber()
        }
        ProjectileManager:CreateLinearProjectile(info)
        if IsServer() then caster:EmitSound("Hero_DrowRanger.Silence") end
    end

    function genuine_2__fallen:OnProjectileHit(hTarget, vLocation)
        if not hTarget then return end
        if hTarget:IsInvulnerable() then return end
        
        local caster = self:GetCaster()
        local fear_duration = self:GetSpecialValueFor("fear_duration")

        hTarget:AddNewModifier(caster, self, "genuine_0_modifier_fear", {
            duration = self:CalcStatus(fear_duration, caster, hTarget)
        })

        -- UP 2.11
        if self:GetRank(11) then
            local mana_steal = 100
            if mana_steal > hTarget:GetMana() then mana_steal = hTarget:GetMana() end
            
            if mana_steal > 0 then
                hTarget:ReduceMana(mana_steal)
                caster:GiveMana(mana_steal)
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, hTarget, mana_steal, caster)
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, caster, mana_steal, caster)
            end
        end

        -- UP 2.21
        if self:GetRank(21) then
            hTarget:AddNewModifier(caster, self, "genuine_2_modifier_dispel", {
                duration = self:CalcStatus(5, caster, hTarget)
            })
        end

        -- UP 2.31
        local starfall_chance = 50
        if hTarget:IsHero() then starfall_chance = 100 end
        if hTarget:IsIllusion() then starfall_chance = 25 end

        if self:GetRank(31) and RandomFloat(1, 100) <= starfall_chance then
            if caster:HasModifier("genuine_u_modifier_caster") == false 
            or hTarget:HasModifier("genuine_u_modifier_target") then
                self:PlayEfxStarfall(hTarget)

                Timers:CreateTimer((0.5), function()
                    if hTarget ~= nil then
                        if IsValidEntity(hTarget) then
                            self:ApplyStarfall(hTarget)
                        end
                    end
                end)
            end
        end

        self:PlayEffects(hTarget)
    end

    function genuine_2__fallen:ApplyStarfall(target)
        local caster = self:GetCaster()
        local starfall_damage = 75
        local starfall_radius = 250
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

    function genuine_2__fallen:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS

    function genuine_2__fallen:PlayEffects(target)
        local particle_cast = "particles/genuine/genuine_fallen_hit.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:ReleaseParticleIndex(effect_cast)
    end

    function genuine_2__fallen:PlayEfxStarfall(target)
        local particle_cast = "particles/genuine/starfall/genuine_starfall_attack.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
        ParticleManager:ReleaseParticleIndex(effect_cast)

        if IsServer() then target:EmitSound("Hero_Mirana.Starstorm.Cast") end
    end
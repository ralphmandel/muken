ancient_u__final = class({})
LinkLuaModifier("ancient_u_modifier_passive", "heroes/ancient/ancient_u_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_break", "modifiers/_modifier_movespeed_break", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function ancient_u__final:CalcStatus(duration, caster, target)
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

    function ancient_u__final:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function ancient_u__final:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function ancient_u__final:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_elder_titan" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[6][upgrade] end
    end

    function ancient_u__final:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_elder_titan" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[6][0] = true
            if self:GetLevel() == 1 then
                base_hero:SetHotkeys(self, true)
                self:DisableManaSystem()
            end
        end

        self:CheckAbilityCharges(0)
    end

    function ancient_u__final:Spawn()
        local caster = self:GetCaster()
        self:CheckAbilityCharges(0)
        self.casting = false
        self.energy = 0

        Timers:CreateTimer((0.3), function()
            if self:IsTrained() == false then self:UpgradeAbility(true) end
			if caster:IsIllusion() == false then
				caster:SetMana(0)
			end
		end)
    end

-- SPELL START

    function ancient_u__final:OnHeroLevelUp()
        self:CheckAbilityCharges(0)
    end

    function ancient_u__final:GetIntrinsicModifierName()
        return "ancient_u_modifier_passive"
    end

    function ancient_u__final:OnAbilityPhaseStart()
        self.damage = self:GetCaster():GetMana()
        self.distance = self:GetCastRange(self:GetCursorPosition(), nil)
        self:PlayEfxPre()

        return true
    end
    
    function ancient_u__final:OnAbilityPhaseInterrupted()
        self:StopEfxPre(true)
    end

    function ancient_u__final:OnSpellStart()
        local caster = self:GetCaster()
        local caster_position = caster:GetAbsOrigin()
        local target_point = self:GetCursorPosition()
    
        local effect_delay = self:GetSpecialValueFor("crack_time")
        local crack_width = self:GetSpecialValueFor("crack_width")
        local crack_distance = self.distance
        local caster_fw = caster:GetForwardVector()
        local crack_ending = caster_position + caster_fw * crack_distance

        GridNav:DestroyTreesAroundPoint(target_point, crack_width, false)
        self:PlayEfxStart(caster_position, crack_ending, effect_delay)
        self:StopEfxPre(false)
        
        Timers:CreateTimer(effect_delay, function()
            local enemies = FindUnitsInLine(
                caster:GetTeamNumber(), caster_position, crack_ending, nil, crack_width,
                DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
                self:GetAbilityTargetFlags()
            )

            for _, enemy in pairs(enemies) do
                ApplyDamage({
                    victim = enemy, attacker = caster, damage = self.damage,
                    damage_type = self:GetAbilityDamageType(), ability = self,
                    damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK
                })

                enemy:Interrupt()
                local closest_point = self:FindNearestPointFromLine(caster_position, caster_fw, enemy:GetAbsOrigin())
                FindClearSpaceForUnit(enemy, closest_point, false)

                -- UP 6.21
                if self:GetRank(21) and enemy:IsAlive() then
                    enemy:AddNewModifier(caster, self, "_modifier_movespeed_debuff", {
                        duration = self:CalcStatus(10, caster, enemy),
                        percent = 50
                    })
                    enemy:AddNewModifier(caster, self, "_modifier_break", {
                        duration = self:CalcStatus(10, caster, enemy)
                    })
                end
            end
    
            self:PlayEfxDestroy()
        end)
    end

    function ancient_u__final:FindNearestPointFromLine(caster, dir, affected)
        local castertoaffected = affected - caster
        local len = castertoaffected:Dot(dir)
        local ntgt = Vector(dir.x * len, dir.y * len, caster.z)
        return caster + ntgt
    end

    function ancient_u__final:DisableManaSystem()
        local base_stats = self:GetCaster():FindAbilityByName("base_stats")
        if base_stats then base_stats:SetMPRegenState(-1) end
    end

    function ancient_u__final:OnOwnerSpawned()
        local mana = 0
        
        -- UP 6.11
        if self:GetRank(11) then
            mana = self:GetCaster():GetMaxMana() * 0.5
        end

        self:GetCaster():SetMana(mana)
        self:UpdateResistance()
    end

    function ancient_u__final:AddEnergy(ability, target)
        local caster = self:GetCaster()
        local berserk = caster:FindAbilityByName("ancient_1__berserk")
        local leap = caster:FindAbilityByName("ancient_2__leap")
        local lotus = caster:FindAbilityByName("ancient_4__lotus")
        local heal = caster:FindAbilityByName("ancient_5__heal")
        local energy_gain = self:GetSpecialValueFor("energy_gain") * 0.01

        if ability == self and target then
            local percent = 5
            if target:IsHero() then percent = 20 end
            self.energy = self.energy + (caster:GetMaxMana() * percent * 0.01)
            caster:Heal(caster:GetMaxHealth() * percent * 0.01, self)
        end
        
        if ability == nil and berserk then
            local damage = 40 * (1 + (berserk:GetSpecialValueFor("damage_percent") * 0.01))
            damage = damage + berserk:GetSpecialValueFor("damage")
            self.energy = self.energy + (damage * energy_gain)
        end

        if ability == leap and leap then
            self.energy = self.energy + (leap:GetAbilityDamage() * energy_gain)
        end

        if ability == lotus and lotus then
            self.energy = self.energy + 1
        end

        if ability == heal and heal then
            local energy_deficit = caster:GetMaxMana() - caster:GetMana()
            self.energy = self.energy + (energy_deficit * 0.15)
        end

        self.energy = math.floor(self.energy)

        Timers:CreateTimer(0.1, function()
            if self.energy > 0 then
                caster:GiveMana(self.energy)
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, caster, self.energy, caster)
                self:UpdateResistance()
                self.energy = 0
            end
        end)
    end

    function ancient_u__final:UpdateResistance()
        local caster = self:GetCaster()
        local res = self:GetSpecialValueFor("res")
        local mana_percent = (caster:GetMana() * 100) / caster:GetMaxMana()
        local lotus = caster:FindAbilityByName("ancient_4__lotus")

        -- UP 4.31
        if lotus then
            if lotus:GetRank(31)
            and lotus:IsTrained() then
                lotus:ApplyRadiance()
            end
        end

        -- UP 6.31
        if self:GetRank(31) then
            res = res + 15
        end

        local total_res = math.ceil(mana_percent * res * 0.01)

        self:RemoveBonus("_2_RES", caster)
        if caster:IsAlive() and total_res > 0 then self:AddBonus("_2_RES", caster, total_res, 0, nil) end
        caster:FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), caster):UpdateAmbients()
    end

    function ancient_u__final:GetCastRange(vLocation, hTarget)
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        
        local cast_range_mult = self:GetSpecialValueFor("cast_range_mult")
        if self:GetCurrentAbilityCharges() % 2 == 0 then cast_range_mult = cast_range_mult + 200 end
        return self:GetManaCost(self:GetLevel()) * cast_range_mult * 0.01

        --local current = self:GetCaster():GetMana()
        --local min_cost = self:GetSpecialValueFor("min_cost")
        --if self:GetCurrentAbilityCharges() % 3 == 0 then min_cost = min_cost - 10 end

        --local manacost = self:GetCaster():GetMaxMana() * min_cost * 0.01
        --if manacost > current then return manacost * cast_range_mult * 0.01 end
        --return current * cast_range_mult * 0.01
    end

    function ancient_u__final:GetBehavior()
        if self:GetCurrentAbilityCharges() == 0 then return DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE + DOTA_ABILITY_BEHAVIOR_PASSIVE end
        return DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE + DOTA_ABILITY_BEHAVIOR_DIRECTIONAL + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_POINT
    end

    function ancient_u__final:GetManaCost(iLevel)
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        local min_cost = self:GetSpecialValueFor("min_cost")
        local current = self:GetCaster():GetMana()

        if self:GetCurrentAbilityCharges() % 3 == 0 then min_cost = min_cost - 10 end
        min_cost = self:GetCaster():GetMaxMana() * min_cost * 0.01
        if min_cost > current then return min_cost end
        
        return current
    end

    function ancient_u__final:CheckAbilityCharges(charges)
        if self:GetCaster():GetLevel() >= 8 then charges = 1 end

        -- UP 6.12
        if self:GetRank(12) then
            charges = charges * 2 -- cast range
        end

        -- UP 6.21
        if self:GetRank(21) then
            charges = charges * 3 -- manacost
        end


        self:SetCurrentAbilityCharges(charges)
    end

-- EFFECTS

    function ancient_u__final:PlayEfxPre()
        local caster = self:GetCaster()

        local particle_cast = "particles/units/heroes/hero_magnataur/magnataur_shockwave_cast.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(effect_cast, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack1", Vector(0,0,0), true)
        self.effect_cast = effect_cast
        self.casting = true

        caster:FindModifierByName("base_hero_mod"):ChangeActivity("")

        if IsServer() then caster:EmitSound("Ancient.Final.Pre") end
    end

    function ancient_u__final:StopEfxPre(interrupted)
        local caster = self:GetCaster()
        ParticleManager:DestroyParticle(self.effect_cast, interrupted)
        ParticleManager:ReleaseParticleIndex(self.effect_cast)
        self.casting = false

        caster:FindModifierByName("base_hero_mod"):ChangeActivity("et_2021")
    end

    function ancient_u__final:PlayEfxStart(caster_position, crack_ending, effect_delay)
        local caster = self:GetCaster()
        local string = "particles/units/heroes/hero_elder_titan/elder_titan_earth_splitter.vpcf"
        self.pfx_start = ParticleManager:CreateParticle(string, PATTACH_WORLDORIGIN, caster)
        ParticleManager:SetParticleControl(self.pfx_start, 0, caster_position)
        ParticleManager:SetParticleControl(self.pfx_start, 1, crack_ending)
        ParticleManager:SetParticleControl(self.pfx_start, 3, Vector(0, effect_delay, 0))
        EmitSoundOn("Hero_ElderTitan.EarthSplitter.Cast", caster)
    end

    function ancient_u__final:PlayEfxDestroy()
        local caster = self:GetCaster()
        if self.pfx_start then ParticleManager:ReleaseParticleIndex(self.pfx_start) end
        EmitSoundOn("Hero_ElderTitan.EarthSplitter.Destroy", caster)
    end
ancient_u__final = class({})
LinkLuaModifier("ancient_u_modifier_passive", "heroes/ancient/ancient_u_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function ancient_u__final:CalcStatus(duration, caster, target)
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
                    damage_type = self:GetAbilityDamageType(), ability = self
                })

                enemy:Interrupt()
                local closest_point = self:FindNearestPointFromLine(caster_position, caster_fw, enemy:GetAbsOrigin())
                FindClearSpaceForUnit(enemy, closest_point, false)
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
        self:GetCaster():SetMana(0)
        self:UpdateResistance()
    end

    function ancient_u__final:AddEnergy(ability)
        local caster = self:GetCaster()
        local energy_gain = self:GetSpecialValueFor("energy_gain") * 0.01
        local energy = 0
        
        if ability == nil then
            local berserk = caster:FindAbilityByName("ancient_1__berserk")
            if berserk then
                local damage = 40 * (1 + (berserk:GetSpecialValueFor("damage") * 0.01))
                energy = damage * energy_gain
            end
        end

        if energy > 0 then
            caster:GiveMana(energy)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, caster, energy, caster)
            self:UpdateResistance()
        end
    end

    function ancient_u__final:UpdateResistance()
        local caster = self:GetCaster()
        local res = self:GetSpecialValueFor("res") * 0.01
        local total_res = math.floor(caster:GetMana() * res)

        self:RemoveBonus("_2_RES", caster)
        if caster:IsAlive() and total_res > 0 then self:AddBonus("_2_RES", caster, total_res, 0, nil) end
        caster:FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), caster):UpdateAmbients()
    end

    function ancient_u__final:GetCastRange(vLocation, hTarget)
        local min_cost = self:GetSpecialValueFor("min_cost")
        local current = self:GetCaster():GetMana()

        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if min_cost > current then return min_cost * self:GetSpecialValueFor("cast_range_mult") * 0.01 end

        return current * self:GetSpecialValueFor("cast_range_mult") * 0.01
    end

    function ancient_u__final:GetBehavior()
        if self:GetCurrentAbilityCharges() == 0 then return DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE + DOTA_ABILITY_BEHAVIOR_PASSIVE end
        return DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE + DOTA_ABILITY_BEHAVIOR_DIRECTIONAL + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_POINT
    end

    function ancient_u__final:GetManaCost(iLevel)
        local min_cost = self:GetSpecialValueFor("min_cost")
        local current = self:GetCaster():GetMana()

        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if min_cost > current then return min_cost end
        
        return current
    end

    function ancient_u__final:CheckAbilityCharges(charges)
        if self:GetCaster():GetLevel() >= 7 then charges = 1 end
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
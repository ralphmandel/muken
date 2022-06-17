shadow_x1__heart = class({})
LinkLuaModifier( "shadow_x1_modifier_heart", "heroes/shadow/shadow_x1_modifier_heart", LUA_MODIFIER_MOTION_NONE )

-- INIT

    function shadow_x1__heart:CalcStatus(duration, caster, target)
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
                    local value = base_stats_target.stat_total["RES"] * 0.7
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

    function shadow_x1__heart:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function shadow_x1__heart:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function shadow_x1__heart:OnUpgrade()
        self:SetHidden(false)
    end

    function shadow_x1__heart:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function shadow_x1__heart:OnAbilityPhaseStart()
        local caster = self:GetCaster()
        if IsServer() then caster:EmitSound("Hero_PhantomAssassin.PreAttack") end

        return true
    end

    function shadow_x1__heart:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        if target:TriggerSpellAbsorb(self) then return end

        local crit = nil
        local damage = self:GetSpecialValueFor("damage")
        local critical_damage = self:GetSpecialValueFor("critical_damage")
        local toxin_target = target:FindModifierByName("shadow_0_modifier_toxin")
        local base_stats = caster:FindAbilityByName("base_stats")

        if base_stats then
            if (base_stats:RollChance() == true or self:CheckAngle(target))
            and toxin_target then
                toxin_target:PlayEfxHeart(caster, toxin_target:IsPurgable())
                toxin_target.purge = false
                crit = true
            end
        end

        local damageTable = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self
		}
		
        if base_stats then base_stats:SetForceCritSpell(critical_damage, crit, DAMAGE_TYPE_PHYSICAL) end   
		local total = ApplyDamage(damageTable)

        self:PlayEfxHit(target)
    end

    function shadow_x1__heart:CheckAngle(target)
        local caster = self:GetCaster()
        local angle = 60

        -- Find targets back
        local victim_angle = target:GetAnglesAsVector().y
        local origin_difference = target:GetAbsOrigin() - caster:GetAbsOrigin()
        local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
        origin_difference_radian = origin_difference_radian * 180

        local attacker_angle = origin_difference_radian / math.pi

        -- For some reason Dota mechanics read the result as 30 degrees anticlockwise, need to adjust it down to appropriate angles for backstabbing.
        attacker_angle = attacker_angle + 180.0 + 30.0

        local result_angle = attacker_angle - victim_angle
        result_angle = math.abs(result_angle)

        if result_angle >= (180 - angle)
        and result_angle <= (180 + angle) then
            return true
        end

        return false
    end

    function shadow_x1__heart:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level =  (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS

    function shadow_x1__heart:PlayEfxHit(target)
        local caster = self:GetCaster()
        local particle_cast = "particles/econ/items/void_spirit/void_spirit_immortal_2021/void_spirit_immortal_2021_astral_step_dmg.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, target)
        ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())

        if IsServer() then target:EmitSound("Hero_PhantomAssassin.FanOfKnives.Cast") end
    end
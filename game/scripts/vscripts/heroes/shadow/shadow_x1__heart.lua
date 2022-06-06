shadow_x1__heart = class({})
LinkLuaModifier( "shadow_x1_modifier_heart", "heroes/shadow/shadow_x1_modifier_heart", LUA_MODIFIER_MOTION_NONE )

-- INIT

    function shadow_x1__heart:CalcStatus(duration, caster, target)
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

    function shadow_x1__heart:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
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
        local str = caster:FindModifierByName("_1_STR_modifier")

        if str then
            if (str:RollChance() == true or self:CheckAngle(target))
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
		
        if str then str:EnableForceSpellCrit(critical_damage, crit) end   
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
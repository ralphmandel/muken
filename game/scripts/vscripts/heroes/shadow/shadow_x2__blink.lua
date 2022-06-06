shadow_x2__blink = class({})

-- INIT

    function shadow_x2__blink:CalcStatus(duration, caster, target)
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

    function shadow_x2__blink:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function shadow_x2__blink:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function shadow_x2__blink:OnUpgrade()
        self:SetHidden(false)
    end

    function shadow_x2__blink:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function shadow_x2__blink:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local origin = caster:GetOrigin()
        local point = target:GetOrigin()
        local direction = (point - origin)
        local distance = self:GetSpecialValueFor("distance") * 0.01

        local blinkDirection = (caster:GetOrigin() - target:GetOrigin()):Normalized()
        local blinkPosition = target:GetOrigin() + blinkDirection
        if IsServer() then caster:EmitSound("Hero_PhantomAssassin.Strike.Start") end

        caster:SetOrigin(blinkPosition)
        FindClearSpaceForUnit(caster, blinkPosition, true)
        ProjectileManager:ProjectileDodge(caster)
        self:PlayEfxBlink(direction, origin, target)

        local distance_traveled = (blinkPosition - origin):Length2D()
        local cooldown = distance_traveled * distance
        self:StartCooldown(cooldown)
        target:ForceKill(false)
    end

    function shadow_x2__blink:CastFilterResultTarget(hTarget)
        local caster = self:GetCaster()
    
        if caster == hTarget then
            return UF_FAIL_CUSTOM
        end
    
        if hTarget:HasModifier("shadow_0_modifier_passive") == false
        or hTarget:GetTeam() ~= caster:GetTeam() then
            return UF_FAIL_CUSTOM
        end
    
        return UF_SUCCESS
    end
    
    function shadow_x2__blink:GetCustomCastErrorTarget(hTarget)
        local caster = self:GetCaster()
        if caster == hTarget then
            return "#dota_hud_error_cant_cast_on_self"
        end
        
        return "INVALID TARGET"
    end

    function shadow_x2__blink:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level =  (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS

    function shadow_x2__blink:PlayEfxBlink(direction, origin, target)
        local caster = self:GetCaster()
        local particle_cast_a = "particles/econ/events/ti9/blink_dagger_ti9_start_lvl2.vpcf"
        local particle_cast_b = "particles/econ/events/ti9/blink_dagger_ti9_lvl2_end.vpcf"

        local effect_cast_a = ParticleManager:CreateParticle(particle_cast_a, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(effect_cast_a, 0, origin)
        ParticleManager:SetParticleControlForward(effect_cast_a, 0, direction:Normalized())
        ParticleManager:SetParticleControl(effect_cast_a, 1, origin + direction)
        ParticleManager:ReleaseParticleIndex(effect_cast_a)

        local effect_cast_b = ParticleManager:CreateParticle(particle_cast_b, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(effect_cast_b, 0, caster:GetOrigin())
        ParticleManager:SetParticleControlForward(effect_cast_b, 0, direction:Normalized())
        ParticleManager:ReleaseParticleIndex(effect_cast_b)

        if IsServer() then caster:EmitSound("Hero_PhantomAssassin.Strike.End") end
    end
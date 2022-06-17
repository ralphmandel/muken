shadow_x2__blink = class({})

-- INIT

    function shadow_x2__blink:CalcStatus(duration, caster, target)
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

    function shadow_x2__blink:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
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
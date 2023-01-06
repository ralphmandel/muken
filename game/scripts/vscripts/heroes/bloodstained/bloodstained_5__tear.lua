bloodstained_5__tear = class({})
LinkLuaModifier("bloodstained_5_modifier_tear", "heroes/bloodstained/bloodstained_5_modifier_tear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_5_modifier_blood", "heroes/bloodstained/bloodstained_5_modifier_blood", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

    function bloodstained_5__tear:OnToggle()
        local caster = self:GetCaster()
        local init_loss = self:GetSpecialValueFor("special_init_loss")

        if self:GetToggleState() then
            caster:AddNewModifier(caster, self, "bloodstained_5_modifier_tear", {})
            self:SetActivated(false)

            Timers:CreateTimer(0.35, function()
                self:PlayEfxShake(init_loss)
            end)

            Timers:CreateTimer(1.5, function()
                self:SetActivated(true)
            end)
        else
            caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
            caster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
            caster:AttackNoEarlierThan(0.6, 99)

            Timers:CreateTimer(0.6, function()
                caster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
            end)

            Timers:CreateTimer(0.45, function()
                caster:RemoveModifierByName("bloodstained_5_modifier_tear")
            end)
        end
    end

    function bloodstained_5__tear:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

-- EFFECTS

    function bloodstained_5__tear:PlayEfxShake(init_loss)
        local caster = self:GetCaster()
        local string_3 = "particles/osiris/poison_alt/osiris_poison_splash_shake.vpcf"
        local particle_3 = ParticleManager:CreateParticle(string_3, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(particle_3, 0, caster:GetOrigin())
        ParticleManager:SetParticleControl(particle_3, 1, Vector(init_loss, 0, 0))
    end


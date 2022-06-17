bloodstained_x2__soulsteal = class({})
LinkLuaModifier( "bloodstained_x2_modifier_soulsteal", "heroes/bloodstained/bloodstained_x2_modifier_soulsteal", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "bloodstained_x2_modifier_blood", "heroes/bloodstained/bloodstained_x2_modifier_blood", LUA_MODIFIER_MOTION_NONE )

-- INIT

    function bloodstained_x2__soulsteal:CalcStatus(duration, caster, target)
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

    function bloodstained_x2__soulsteal:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function bloodstained_x2__soulsteal:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bloodstained_x2__soulsteal:OnUpgrade()
        self:SetHidden(false)
    end

    function bloodstained_x2__soulsteal:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function bloodstained_x2__soulsteal:GetIntrinsicModifierName()
        return "bloodstained_x2_modifier_soulsteal"
    end

    function bloodstained_x2__soulsteal:OnSpellStart()
        local caster = self:GetCaster()
        local heal = 0

        local thinkers = Entities:FindAllByClassname("npc_dota_thinker")
        for _,blood in pairs(thinkers) do
            if blood:GetOwner() == caster and blood:HasModifier("bloodstained_x2_modifier_blood") then
                local mod = blood:FindModifierByName("bloodstained_x2_modifier_blood")
                if mod ~= nil then
                    if mod.damage ~= nil then heal = heal + (mod.damage * 0.5) end
                    self:PlayEfxBlood(blood)
                    blood:Destroy()
                end
            end
        end

        --heal = heal * 0.5 --reduces only 5v5 game

        if heal >= 1 then
            caster:Heal(heal, self)
            self:PlayEfxHeal()
        end
    end

-- EFFECTS

    function bloodstained_x2__soulsteal:PlayEfxBlood(blood)
        local caster = self:GetCaster()

        local particle_cast = "particles/units/heroes/hero_undying/undying_soul_rip_damage.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControl(effect_cast, 0, caster:GetOrigin())
        ParticleManager:SetParticleControl(effect_cast, 1, blood:GetOrigin())
        ParticleManager:SetParticleControl(effect_cast, 2, caster:GetOrigin())
    end

    function bloodstained_x2__soulsteal:PlayEfxHeal(blood)
        local caster = self:GetCaster()

        local particle_cast = "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)

        if IsServer() then
            caster:EmitSound("hero_bloodseeker.bloodRite.silence")
            caster:EmitSound("hero_bloodseeker.rupture.cast")
        end
    end
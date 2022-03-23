bloodstained_x2__soulsteal = class({})
LinkLuaModifier( "bloodstained_x2_modifier_soulsteal", "heroes/bloodstained/bloodstained_x2_modifier_soulsteal", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "bloodstained_x2_modifier_blood", "heroes/bloodstained/bloodstained_x2_modifier_blood", LUA_MODIFIER_MOTION_NONE )

-- INIT

    function bloodstained_x2__soulsteal:CalcStatus(duration, caster, target)
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

    function bloodstained_x2__soulsteal:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
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
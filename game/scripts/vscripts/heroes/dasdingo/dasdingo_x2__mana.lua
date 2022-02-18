dasdingo_x2__mana = class({})
LinkLuaModifier( "dasdingo_x2_modifier_mana", "heroes/dasdingo/dasdingo_x2_modifier_mana", LUA_MODIFIER_MOTION_NONE )

-- INIT

    function dasdingo_x2__mana:CalcStatus(duration, caster, target)
        local time = duration
        if caster == nil then return time end
        local caster_int = caster:FindModifierByName("_1_INT_modifier")
        local caster_mnd = caster:FindModifierByName("_2_MND_modifier")

        if target == nil then
            if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
        else
            if caster:GetTeamNumber() == target:GetTeamNumber() then
                if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
            else
                local target_res = target:FindModifierByName("_2_RES_modifier")
                if caster_int then time = duration * (1 + caster_int:GetDebuffTime()) end
                if target_res then time = time * (1 - target_res:GetStatus()) end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function dasdingo_x2__mana:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function dasdingo_x2__mana:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function dasdingo_x2__mana:OnUpgrade()
        self:SetHidden(false)
    end

    function dasdingo_x2__mana:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function dasdingo_x2__mana:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local mana = self:GetSpecialValueFor("mana")

        local mnd = caster:FindModifierByName("_2_MND_modifier")
        if mnd then mana = mana * mnd:GetHealPower() end
        target:GiveMana(mana)

        self:PopupMana(target, mana)
        self:PlayEfxStart(target)
    end

    function dasdingo_x2__mana:CastFilterResultTarget(hTarget)
        local caster = self:GetCaster()

        if caster == hTarget then
            return UF_FAIL_CUSTOM
        end

        local result = UnitFilter(
            hTarget,	-- Target Filter
            DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- Team Filter
            DOTA_UNIT_TARGET_HERO,	-- Unit Filter
            0,	-- Unit Flag
            caster:GetTeamNumber()	-- Team reference
        )
        
        if result ~= UF_SUCCESS then
            return result
        end

        return UF_SUCCESS
    end

    function dasdingo_x2__mana:GetCustomCastErrorTarget( hTarget )
        if self:GetCaster() == hTarget then
            return "#dota_hud_error_cant_cast_on_self"
        end
    end

-- EFFECTS

    function dasdingo_x2__mana:PlayEfxStart(target)
        local particle = "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_chakra_magic.vpcf"
        local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
        ParticleManager:SetParticleControl(effect, 1, target:GetOrigin())
        ParticleManager:ReleaseParticleIndex(effect)

        if IsServer() then target:EmitSound("Hero_KeeperOfTheLight.ChakraMagic.Target") end
    end

    function dasdingo_x2__mana:PopupMana(target, value)
        local pidx = ParticleManager:CreateParticle("particles/msg_fx/msg_mana_add.vpcf", PATTACH_ABSORIGIN_FOLLOW, target) -- target:GetOwner()
        local digits = 3
        if value < 10 then digits = digits + 1 end
        if value > 9 and value < 100 then digits = digits + 1 end
        if value > 99 and value < 1000 then digits = digits + 1 end
        if value > 999 then digits = digits + 1 end

        ParticleManager:SetParticleControl(pidx, 1, Vector(0, math.floor(value), 0))
        ParticleManager:SetParticleControl(pidx, 2, Vector(2, digits, 0))
        ParticleManager:SetParticleControl(pidx, 3, Vector(0, 0, 255))
    end
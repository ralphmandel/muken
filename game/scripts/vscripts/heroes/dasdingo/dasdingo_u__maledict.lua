dasdingo_u__maledict = class({})
LinkLuaModifier("dasdingo_u_modifier_maledict", "heroes/dasdingo/dasdingo_u_modifier_maledict", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_u_modifier_overtime", "heroes/dasdingo/dasdingo_u_modifier_overtime", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)


-- INIT

    function dasdingo_u__maledict:CalcStatus(duration, caster, target)
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

    function dasdingo_u__maledict:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function dasdingo_u__maledict:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function dasdingo_u__maledict:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("dasdingo__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

        return att.talents[4][upgrade]
    end

    function dasdingo_u__maledict:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_shadow_shaman" then return end

        local att = caster:FindAbilityByName("dasdingo__attributes")
        if att then
            if att:IsTrained() then
                att.talents[4][0] = true
            end
        end
        
        if self:GetLevel() == 1 then
			caster:FindAbilityByName("_2_DEX"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_DEF"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_RES"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_REC"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_MND"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_LCK"):CheckLevelUp(true)
		end

        local charges = 1

        -- UP 4.11
        if self:GetRank(11) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function dasdingo_u__maledict:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function dasdingo_u__maledict:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

    function dasdingo_u__maledict:OnSpellStart()
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
        local radius = self:GetSpecialValueFor("radius")
        local flag = 0

        -- UP 4.21
        if self:GetRank(21) then
            flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
        end

        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), point, nil, radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            flag, 0, false
        )

        for _,enemy in pairs(enemies) do
            enemy:AddNewModifier(caster, self, "dasdingo_u_modifier_maledict", {})
        end

        self:PlayEfxStart(point, radius)
    end

	function dasdingo_u__maledict:GetCooldown(iLevel)
		if self:GetCurrentAbilityCharges() == 0 then return 60 end
		if self:GetCurrentAbilityCharges() == 1 then return 60 end
		if self:GetCurrentAbilityCharges() % 2 == 0 then return 45 end
	end

-- EFFECTS

    function dasdingo_u__maledict:PlayEfxStart(point, radius)
        local caster = self:GetCaster()
        local particle = "particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell.vpcf"
        local effect = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(effect, 0, point)
        ParticleManager:SetParticleControl(effect, 1, Vector(radius, 2, radius * 2))
        ParticleManager:SetParticleControl(effect, 60, Vector(25, 5, 15))
        ParticleManager:SetParticleControl(effect, 61, Vector(1, 0, 0))
        ParticleManager:ReleaseParticleIndex(effect)

        if IsServer() then
            EmitSoundOnLocationWithCaster(point, "Hero_Dazzle.BadJuJu.Cast", caster)
            EmitSoundOnLocationWithCaster(point, "Hero_Oracle.FalsePromise.Damaged", caster)
        end

        AddFOWViewer(caster:GetTeamNumber(), point, radius, 2, false)
    end
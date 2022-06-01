shadow_2__puddle = class({})
LinkLuaModifier("shadow_2_modifier_puddle", "heroes/shadow/shadow_2_modifier_puddle", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_2_modifier_vacuum", "heroes/shadow/shadow_2_modifier_vacuum", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function shadow_2__puddle:CalcStatus(duration, caster, target)
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

    function shadow_2__puddle:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function shadow_2__puddle:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function shadow_2__puddle:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("shadow__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_spectre" then return end

        return att.talents[2][upgrade]
    end

    function shadow_2__puddle:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_spectre" then return end

        local att = caster:FindAbilityByName("shadow__attributes")
        if att then
            if att:IsTrained() then
                att.talents[2][0] = true
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
        self:SetCurrentAbilityCharges(charges)
    end

    function shadow_2__puddle:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function shadow_2__puddle:OnSpellStart()
        local caster = self:GetCaster()
		local point = self:GetCursorPosition()
        
		local thinkers = Entities:FindAllByClassname("npc_dota_thinker")
		for _,smoke in pairs(thinkers) do
			if smoke:GetOwner() == caster and smoke:HasModifier("shadow_2_modifier_puddle") then
				smoke:Kill(self, nil)
			end
		end

		CreateModifierThinker(caster, self, "shadow_2_modifier_puddle", {}, point, caster:GetTeamNumber(), false)
    end

    function shadow_2__puddle:GetAOERadius()
        return self:GetSpecialValueFor("radius")
    end

    function shadow_2__puddle:GetCooldown(iLevel)
        local cooldown = self:GetSpecialValueFor("cooldown")
		if self:GetCurrentAbilityCharges() == 0 then return cooldown end
		if self:GetCurrentAbilityCharges() == 1 then return cooldown end
		if self:GetCurrentAbilityCharges() % 2 == 0 then return cooldown - 4 end
        return cooldown
	end

    function shadow_2__puddle:GetCastRange(vLocation, hTarget)
        local cast_range = self:GetSpecialValueFor("cast_range")
        if self:GetCurrentAbilityCharges() == 0 then return cast_range end
        if self:GetCurrentAbilityCharges() == 1 then return cast_range end
        if self:GetCurrentAbilityCharges() % 3 == 0 then return 0 end
        return cast_range
    end

    function shadow_2__puddle:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.1))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS
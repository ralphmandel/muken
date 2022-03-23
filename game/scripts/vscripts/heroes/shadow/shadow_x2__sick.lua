shadow_x2__sick = class({})
LinkLuaModifier("shadow_x2_modifier_sick", "heroes/shadow/shadow_x2_modifier_sick", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_3_modifier_illusion", "heroes/shadow/shadow_3_modifier_illusion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_no_bar", "modifiers/_modifier_no_bar", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function shadow_x2__sick:CalcStatus(duration, caster, target)
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

    function shadow_x2__sick:AddBonus(string, target, const, percent, time)
		local att = target:FindAbilityByName(string)
		if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
	end

	function shadow_x2__sick:RemoveBonus(string, target)
		local stringFormat = string.format("%s_modifier_stack", string)
		local mod = target:FindAllModifiersByName(stringFormat)
		for _,modifier in pairs(mod) do
			if modifier:GetAbility() == self then modifier:Destroy() end
		end
	end

    function shadow_x2__sick:OnUpgrade()
        self:SetHidden(false)
        self:CheckUnits()
    end

    function shadow_x2__sick:Spawn()
		self:SetCurrentAbilityCharges(0)
	end

-- SPELL START

    function shadow_x2__sick:OnSpellStart()
        local caster = self:GetCaster()
        local duration = self:CalcStatus(self:GetSpecialValueFor("assault_duration"), caster, nil)
        
        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), caster:GetOrigin(), nil, FIND_UNITS_EVERYWHERE,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false
        )

        for _,enemy in pairs(enemies) do
            if enemy:HasModifier("shadow_0_modifier_poison") then
                self:CreateShadow(enemy, duration)
            end
        end

        caster:AddNewModifier(caster, self, "shadow_x2_modifier_sick", {duration = duration})
        if IsServer() then caster:EmitSoundParams("Hero_Spectre.Reality", 1, 1, 0) end
    end

    function shadow_x2__sick:CreateShadow(target, duration)
        local caster = self:GetCaster()
        local cursor = target:GetOrigin()
        local illu = CreateIllusions(
            caster, caster, {
                outgoing_damage = -100,
                incoming_damage = 200,
                bounty_base = 0,
                bounty_growth = 0,
                duration = duration
            }, 1, 64, false, false
        )

        illu = illu[1]
        illu:AddNewModifier(caster, self, "shadow_3_modifier_illusion", {ignore_order = 1, aspd = 50})
        if caster:HasModifier("shadow_1_modifier_weapon") then
            local weapon = caster:FindAbilityByName("shadow_1__weapon")
            if weapon then illu:AddNewModifier(caster, weapon, "shadow_1_modifier_weapon", {}) end
        end

        local area = 200
        local quarter = RandomInt(1, 4)
        local variable = RandomInt(0, area)
        local random_x
        local random_y

        if quarter == 1 then
            random_x = -area
            random_y = variable
        elseif quarter == 2 then
            random_x = variable
            random_y = area
        elseif quarter == 3 then
            random_x = area
            random_y = -variable
        elseif quarter == 4 then
            random_x = -variable
            random_y = -area
        end

        local x = self:Calculate( random_x, random_y)
        local y = self:Calculate( random_y, random_x)

        cursor.x = cursor.x + x
        cursor.y = cursor.y + y

        FindClearSpaceForUnit(illu, cursor, true)
        illu:SetForceAttackTarget(target)
    end

    function shadow_x2__sick:Calculate( a, b)
        if a < 0 then
            if b > 0 then b = -b end
        else
            if b < 0 then b = -b end
        end

        return a - math.floor(b/4)
    end

    function shadow_x2__sick:CheckUnits()
        local caster = self:GetCaster()
        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), caster:GetOrigin(), nil, FIND_UNITS_EVERYWHERE,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false
        )

        local pass = false
        for _,enemy in pairs(enemies) do
            if enemy:HasModifier("shadow_0_modifier_poison") then pass = true end
        end
        if pass == false then self:SetActivated(false) else self:SetActivated(true) end
    end

-- EFFECTS
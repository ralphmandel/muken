ancient_1__berserk = class({})
LinkLuaModifier("ancient_1_modifier_berserk", "heroes/ancient/ancient_1_modifier_berserk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_disarm", "modifiers/_modifier_disarm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function ancient_1__berserk:CalcStatus(duration, caster, target)
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

    function ancient_1__berserk:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function ancient_1__berserk:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function ancient_1__berserk:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("ancient__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_elder_titan" then return end

        return att.talents[1][upgrade]
    end

    function ancient_1__berserk:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_elder_titan" then return end

        local att = caster:FindAbilityByName("ancient__attributes")
        if att then
            if att:IsTrained() then
                att.talents[1][0] = true
            end
        end
        
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_DEX"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_DEF"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_RES"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_REC"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_MND"):CheckLevelUp(true) end
        if self:GetLevel() == 1 then caster:FindAbilityByName("_2_LCK"):CheckLevelUp(true) end

        local str = caster:FindAbilityByName("_1_STR")
        
        if self:GetLevel() == 1 then
            local strenght = self:GetSpecialValueFor("strenght")
            if str ~= nil then str:BonusPermanent(strenght) end
        end

        -- UP 1.31
        if self:GetRank(31) and self.bonus_str == false then
            if str ~= nil then str:BonusPermanent(10) end
            self.bonus_str = true
        end

        local charges = 1

        -- UP 1.32
        if self:GetRank(32) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function ancient_1__berserk:Spawn()
        self:SetCurrentAbilityCharges(0)
        self.bonus_str = false
    end

-- SPELL START

    function ancient_1__berserk:GetIntrinsicModifierName()
        return "ancient_1_modifier_berserk"
    end

    function ancient_1__berserk:GetCooldown(iLevel)
		if self:GetCurrentAbilityCharges() == 0 then return 0 end
		if self:GetCurrentAbilityCharges() == 1 then return 0 end
		if self:GetCurrentAbilityCharges() % 2 == 0 then return 15 end
	end

-- EFFECTS
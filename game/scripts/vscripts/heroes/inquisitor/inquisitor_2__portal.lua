inquisitor_2__portal = class({})
LinkLuaModifier("inquisitor_2_modifier_portal", "heroes/inquisitor/inquisitor_2_modifier_portal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("inquisitor_2_modifier_portal_effect", "heroes/inquisitor/inquisitor_2_modifier_portal_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_pull", "modifiers/_modifier_pull", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function inquisitor_2__portal:CalcStatus(duration, caster, target)
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

    function inquisitor_2__portal:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function inquisitor_2__portal:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function inquisitor_2__portal:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("inquisitor__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

        return att.talents[2][upgrade]
    end

    function inquisitor_2__portal:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

        local att = caster:FindAbilityByName("inquisitor__attributes")
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

        -- UP 2.2
        if self:GetRank(2) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function inquisitor_2__portal:Spawn()
        self:SetCurrentAbilityCharges(0)
        self.autocast = false
    end

-- SPELL START

    function inquisitor_2__portal:GetAOERadius()
        return 110
    end

    function inquisitor_2__portal:OnSpellStart()
        local caster = self:GetCaster()
        local pos = self:GetCursorPosition()
        local duration = self:GetSpecialValueFor("duration")

        if self.autocast == true then
            local area = self:GetSpecialValueFor("range") - 50
            pos = caster:GetOrigin()
            local random_x
            local random_y

            local quarter = RandomInt(1,4)
            if quarter == 1 then
                random_x = RandomInt(-area, area)
                random_y = RandomInt(-area, 0)
            elseif quarter == 2 then
                random_x = RandomInt(-area, area)
                random_y = RandomInt(0, area)
            elseif quarter == 3 then
                random_x = RandomInt(-area, 0)
                random_y = RandomInt(-area, area)
            elseif quarter == 4 then
                random_x = RandomInt(0, area)
                random_y = RandomInt(-area, area)
            end

            local x = self:Calculate( random_x, random_y)
            local y = self:Calculate( random_y, random_x)

            pos.x = pos.x + x
            pos.y = pos.y + y
        end

        CreateModifierThinker(caster, self, "inquisitor_2_modifier_portal", {duration = duration}, pos, caster:GetTeamNumber(), false)
        
        -- UP 2.7
        if self:GetRank(7) then
            local range = self:GetSpecialValueFor("range")
            self:CreateExtraPortal(range * 0.75, 5)
        end

        self.autocast = false
    end

    function inquisitor_2__portal:CreateExtraPortal(area, duration)
        local caster = self:GetCaster()
        local point = self:GetCursorPosition()
        local random_x
        local random_y

        local quarter = RandomInt(1,4)
        if quarter == 1 then
            random_x = RandomInt(-area, area)
            random_y = -area
        elseif quarter == 2 then
            random_x = RandomInt(-area, area)
            random_y = area
        elseif quarter == 3 then
            random_x = -area
            random_y = RandomInt(-area, area)
        elseif quarter == 4 then
            random_x = area
            random_y = RandomInt(-area, area)
        end

        local x = self:Calculate( random_x, random_y)
        local y = self:Calculate( random_y, random_x)

        point.x = point.x + x
        point.y = point.y + y
        CreateModifierThinker(caster, self, "inquisitor_2_modifier_portal", {duration = duration}, point, caster:GetTeamNumber(), false)
    end

    function inquisitor_2__portal:Calculate(a, b)
        if a < 0 then
            if b > 0 then
                b = -b
            end
        elseif b < 0 then
            b = -b
        end
        local result = a - math.floor(b/4)

        return result
    end

    function inquisitor_2__portal:EnableAutoCast()
        self.autocast = true
    end

    function inquisitor_2__portal:GetCastRange(vLocation, hTarget)
        if self:GetCurrentAbilityCharges() == 0 then return 600 end
        if self:GetCurrentAbilityCharges() == 1 then return 600 end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return 900 end
    end

-- EFFECTS
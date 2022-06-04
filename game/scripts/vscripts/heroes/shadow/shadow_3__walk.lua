shadow_3__walk = class({})
LinkLuaModifier("shadow_3_modifier_recharge", "heroes/shadow/shadow_3_modifier_recharge", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_3_modifier_passive", "heroes/shadow/shadow_3_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_3_modifier_walk", "heroes/shadow/shadow_3_modifier_walk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_3_modifier_walk_cosmetic", "heroes/shadow/shadow_3_modifier_walk_cosmetic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function shadow_3__walk:CalcStatus(duration, caster, target)
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

    function shadow_3__walk:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function shadow_3__walk:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function shadow_3__walk:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("shadow__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_spectre" then return end

        return att.talents[3][upgrade]
    end

    function shadow_3__walk:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_spectre" then return end

        local att = caster:FindAbilityByName("shadow__attributes")
        if att then
            if att:IsTrained() then
                att.talents[3][0] = true
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

    function shadow_3__walk:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function shadow_3__walk:GetIntrinsicModifierName()
        return "shadow_3_modifier_passive"
    end

    function shadow_3__walk:CreateShadow(target, shadow_duration, shadow_number)
        local caster = self:GetCaster()
        local shadow_incoming = self:GetSpecialValueFor("shadow_incoming") -100
        local shadow_outgoing = self:GetSpecialValueFor("shadow_outgoing") -100
        
        if caster:IsIllusion() then return end -- VERY IMPORTANT !

        local illu = CreateIllusions(
			caster, caster,
			{
				outgoing_damage = shadow_outgoing,
				incoming_damage = shadow_incoming,
				bounty_base = 0,
				bounty_growth = 0,
				duration = self:CalcStatus(shadow_duration, caster, nil)
			},
			shadow_number, 64, false, true
		)

        for i = 1, #illu, 1 do
            illu[i]:SetControllableByPlayer(caster:GetPlayerID(), false)
            FindClearSpaceForUnit(illu[i], target:GetAbsOrigin() + RandomVector(150), true)
        end

        local rand_pos = RandomInt(0, #illu)
        if rand_pos > 0 then 
            local caster_origin = caster:GetOrigin()
            caster:SetOrigin(illu[rand_pos]:GetOrigin())
            illu[rand_pos]:SetOrigin(caster_origin)
        end

        CenterCameraOnUnit(caster:GetPlayerID(), caster)
    end

    function shadow_3__walk:StartRechargeTime()
        local caster = self:GetCaster()
        local delay = self:GetSpecialValueFor("delay")

        -- UP 3.11
        if self:GetRank(11) then
            delay = delay - 1
        end
        
        if self:IsActivated() then
            self:StartCooldown(delay)
            caster:AddNewModifier(caster, self, "shadow_3_modifier_recharge", {
                duration = delay
            })
        end
    end

    function shadow_3__walk:OnOwnerSpawned()
        local caster = self:GetCaster()
        caster:RemoveModifierByName("shadow_3_modifier_walk")
        self:SetActivated(true)
        self:StartRechargeTime()
    end

    function shadow_3__walk:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level =  (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS
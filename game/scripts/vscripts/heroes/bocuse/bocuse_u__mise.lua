bocuse_u__mise = class ({})
LinkLuaModifier("bocuse_u_modifier_mise", "heroes/bocuse/bocuse_u_modifier_mise", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_u_modifier_autocast", "heroes/bocuse/bocuse_u_modifier_autocast", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_u_modifier_jump", "heroes/bocuse/bocuse_u_modifier_jump", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("bocuse_u_modifier_exhaustion", "heroes/bocuse/bocuse_u_modifier_exhaustion", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("bocuse_u_modifier_exhaustion_status_efx", "heroes/bocuse/bocuse_u_modifier_exhaustion_status_efx", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("bocuse_u_modifier_mise_status_efx", "heroes/bocuse/bocuse_u_modifier_mise_status_efx", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_break", "modifiers/_modifier_break", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bocuse_u__mise:CalcStatus(duration, caster, target)
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

    function bocuse_u__mise:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function bocuse_u__mise:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bocuse_u__mise:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("bocuse__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_pudge" then return end

        return att.talents[4][upgrade]
    end

    function bocuse_u__mise:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_pudge" then return end

        local att = caster:FindAbilityByName("bocuse__attributes")
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

		-- UP 4.31
		if self:GetRank(31) then
			charges = charges * 2
		end

		self:SetCurrentAbilityCharges(charges)
    end

    function bocuse_u__mise:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function bocuse_u__mise:GetIntrinsicModifierName()
        return "bocuse_u_modifier_autocast"
    end

    function bocuse_u__mise:OnSpellStart()
        local caster = self:GetCaster()
        local duration = self:GetSpecialValueFor("duration")

        -- UP 4.11
        if self:GetRank(11) then
            caster:AddNewModifier(caster, self, "bocuse_u_modifier_jump", {duration = 0.5})
        end

        -- UP 4.42
        if self:GetRank(42) then
            duration = duration + 1.5
        end

        caster:AddNewModifier(caster, self, "bocuse_u_modifier_mise", {duration = self:CalcStatus(duration, caster, caster)})
        self:EndCooldown()
        self:SetActivated(false)
    end

    function bocuse_u__mise:GetCastRange(vLocation, hTarget)
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() == 1 then return 0 end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return 350 end
    end

-- EFFECTS
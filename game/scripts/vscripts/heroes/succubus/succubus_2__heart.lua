succubus_2__heart = class({})
LinkLuaModifier("succubus_2_modifier_heart", "heroes/succubus/succubus_2_modifier_heart", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("succubus_2_modifier_gesture", "heroes/succubus/succubus_2_modifier_gesture", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function succubus_2__heart:CalcStatus(duration, caster, target)
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

    function succubus_2__heart:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function succubus_2__heart:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function succubus_2__heart:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("succubus__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_queenofpain" then return end

        return att.talents[2][upgrade]
    end

    function succubus_2__heart:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_queenofpain" then return end

        local att = caster:FindAbilityByName("succubus__attributes")
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

    function succubus_2__heart:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function succubus_2__heart:OnAbilityPhaseStart()
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "succubus_2_modifier_gesture", {})
        return true
    end

    function succubus_2__heart:OnAbilityPhaseInterrupted()
        self:GetCaster():RemoveModifierByName("succubus_2_modifier_gesture")
    
    end

    function succubus_2__heart:OnSpellStart()

        Timers:CreateTimer((0.15), function()
            self:GetCaster():RemoveModifierByName("succubus_2_modifier_gesture")
		end)

        self:PlayEfxStart()

        local caster = self:GetCaster()
        local info = {
			Target = self:GetCursorTarget(),
			Source = caster,
			Ability = self,	
			EffectName = "particles/succubus/succubus_2_heart.vpcf",
			iMoveSpeed = 300,
			bReplaceExisting = false,                         -- Optional
			bProvidesVision = true,                           -- Optional
			iVisionRadius = 300,				-- Optional
			iVisionTeamNumber = caster:GetTeamNumber()        -- Optional
		}

		ProjectileManager:CreateTrackingProjectile(info)

         

    end

    function succubus_2__heart:OnProjectileHit(hTarget, vLocation)
        local duration = self:GetSpecialValueFor("duration")
        hTarget:AddNewModifier(self:GetCaster(), self, "succubus_2_modifier_heart", {duration = duration})
    end

-- EFFECTS

function succubus_2__heart:PlayEfxStart()
    local string = "particles/succubus/succubus_2_heart_cast.vpcf"
    local effect_aura = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:SetParticleControl(effect_aura, 0, self:GetCaster():GetOrigin())
    --self:AddParticle(effect_aura, false, false, -1, false, false)
end
succubus_2__heart = class({})
LinkLuaModifier("succubus_2_modifier_heart", "heroes/succubus/succubus_2_modifier_heart", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("succubus_2_modifier_gesture", "heroes/succubus/succubus_2_modifier_gesture", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function succubus_2__heart:CalcStatus(duration, caster, target)
        local time = duration
        local base_stats_caster = nil
        local base_stats_target = nil

        if caster ~= nil then
            base_stats_caster = caster:FindAbilityByName("base_stats")
        end

        if target ~= nil then
            base_stats_target = target:FindAbilityByName("base_stats")
        end

        if caster == nil then
            if target ~= nil then
                if base_stats_target then
                    local value = base_stats_target.res_total * 0.01
                    local calc = (value * 6) / (1 +  (value * 0.06))
                    time = time * (1 - calc)
                end
            end
        else
            if target == nil then
                if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
            else
                if caster:GetTeamNumber() == target:GetTeamNumber() then
                    if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
                else
                    if base_stats_caster and base_stats_target then
                        local value = (base_stats_caster.int_total - base_stats_target.res_total) * 0.01
                        if value > 0 then
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 + calc)
                        else
                            value = -1 * value
                            local calc = (value * 6) / (1 +  (value * 0.06))
                            time = time * (1 - calc)
                        end
                    end
                end
            end
        end

        if time < 0 then time = 0 end
        return time
    end

    function succubus_2__heart:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
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
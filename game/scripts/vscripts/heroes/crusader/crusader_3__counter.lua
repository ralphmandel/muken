crusader_3__counter = class({})
LinkLuaModifier("crusader_3_modifier_passive", "heroes/crusader/crusader_3_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("crusader_3_modifier_leech", "heroes/crusader/crusader_3_modifier_leech", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("crusader_3_modifier_call", "heroes/crusader/crusader_3_modifier_call", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("crusader_3_modifier_buff", "heroes/crusader/crusader_3_modifier_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_disarm", "modifiers/_modifier_disarm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_silence", "modifiers/_modifier_silence", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("crusader_3_modifier_pull_trigger", "heroes/crusader/crusader_3_modifier_pull_trigger", LUA_MODIFIER_MOTION_HORIZONTAL)

-- INIT

    function crusader_3__counter:CalcStatus(duration, caster, target)
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

    function crusader_3__counter:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function crusader_3__counter:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function crusader_3__counter:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("crusader__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_abaddon" then return end

        return att.talents[3][upgrade]
    end

    function crusader_3__counter:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_abaddon" then return end

        local att = caster:FindAbilityByName("crusader__attributes")
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

        -- UP 3.4
        if self:GetRank(4)
        and self.bonus_agi == false then
            self.bonus_agi = true
            local agi = caster:FindAbilityByName("_1_AGI")
            if agi then agi:BonusPermanent(10) end
        end

        local charges = 1

        -- UP 3.2
        if self:GetRank(2) then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function crusader_3__counter:Spawn()
        self:SetCurrentAbilityCharges(0)
        self.tHeroes = {}
        self.bonus_agi = false
    end

-- SPELL START

    function crusader_3__counter:GetIntrinsicModifierName()
        return "crusader_3_modifier_passive"
    end

    function crusader_3__counter:OnSpellStart()
        local caster = self:GetCaster()
        local origin = caster:GetOrigin()
        local target_trigger = self:GetCursorTarget()
        local duration = self:GetSpecialValueFor("duration")
    
        if target_trigger:TriggerSpellAbsorb(self) then return end
        self:PlayEfxTarget(target_trigger)
    
        local forward = (target_trigger:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
        origin = origin + (forward * 100)
    
        target_trigger:AddNewModifier(caster, self, "crusader_3_modifier_call", {duration = duration})
        target_trigger:AddNewModifier(caster, self, "crusader_3_modifier_pull_trigger", {
            duration = 0.3,
            x = origin.x,
            y = origin.y,
        })

        caster:MoveToTargetToAttack(target_trigger)
    
        self:EndCooldown()
        self:SetActivated(false)
    end

    function crusader_3__counter:GetCastRange(vLocation, hTarget)
        if self:GetCurrentAbilityCharges() == 0 then return 300 end
        if self:GetCurrentAbilityCharges() == 1 then return 300 end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return 450 end
    end

-- EFFECTS

    function crusader_3__counter:PlayEfxTarget(target)
        local caster = self:GetCaster()

        local particle_cast = "particles/econ/items/terrorblade/terrorblade_back_ti8/terrorblade_sunder_ti8.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
        ParticleManager:SetParticleControl(effect_cast, 1, caster:GetOrigin())
        ParticleManager:SetParticleControl(effect_cast, 2, caster:GetOrigin())
        ParticleManager:SetParticleControl(effect_cast, 15, Vector(75, 255, 150))
        -- ParticleManager:ReleaseParticleIndex(effect_cast)

        if IsServer() then caster:EmitSound("Hero_Abaddon.BorrowedTime") end
    end
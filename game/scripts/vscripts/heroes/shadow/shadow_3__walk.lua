shadow_3__walk = class({})
LinkLuaModifier("shadow_0_modifier_poison", "heroes/shadow/shadow_0_modifier_poison", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_0_modifier_poison_stack", "heroes/shadow/shadow_0_modifier_poison_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_3_modifier_walk", "heroes/shadow/shadow_3_modifier_walk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_3_modifier_invisible", "heroes/shadow/shadow_3_modifier_invisible", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_3_modifier_illusion", "heroes/shadow/shadow_3_modifier_illusion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_3_modifier_night", "heroes/shadow/shadow_3_modifier_night", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_3_modifier_stun", "heroes/shadow/shadow_3_modifier_stun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

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
        if caster:GetUnitName() ~= "npc_dota_hero_phantom_assassin" then return end

        return att.talents[3][upgrade]
    end

    function shadow_3__walk:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_phantom_assassin" then return end

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

        -- UP 3.1
        if self:GetRank(1) then
            caster:AddNewModifier(caster, self, "shadow_3_modifier_night", {})
        end

        local charges = 1
        self:SetCurrentAbilityCharges(charges)
    end

    function shadow_3__walk:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function shadow_3__walk:GetIntrinsicModifierName()
        return "shadow_3_modifier_walk"
    end

    function shadow_3__walk:OnSpellStart()
        -- Get Data
        local caster = self:GetCaster()
        local origin = caster:GetOrigin()
        local target = self:GetCursorTarget()
        local point = target:GetOrigin()
        local direction = (point - origin)
        local avoid_duration = self:GetSpecialValueFor("avoid_duration")
    
        -- Calculate Blink
        local blinkDirection = (caster:GetOrigin() - target:GetOrigin()):Normalized()
        local blinkPosition = target:GetOrigin() + blinkDirection
    
        -- Emit Origin Sound
        if IsServer() then caster:EmitSound("Hero_PhantomAssassin.Strike.Start") end
    
        -- Perform Blink
        caster:SetOrigin(blinkPosition)
        FindClearSpaceForUnit(caster, blinkPosition, true)
        self:PlayEfxBlink(direction, origin, target)
    
        -- Reset Location
        local walk_mod = caster:FindModifierByName("shadow_3_modifier_walk")
        if walk_mod then walk_mod:SetLocation(blinkPosition) end
    
        -- Define Cooldown
        local distance_traveled = (blinkPosition - origin):Length2D()
        local cooldown = self:GetEffectiveCooldown(self:GetLevel()) * (0 + (distance_traveled * 0.001))
        self:EndCooldown()
        self:StartCooldown(cooldown)

        -- UP 3.2
        if self:GetRank(2) then
            caster:AddNewModifier(caster, self, "shadow_3_modifier_stun", {
                duration = 3,
                distance = distance_traveled
            })
        end
    
        -- Kill Illusion
        target:ForceKill(false)
    end

    function shadow_3__walk:OnOwnerSpawned()
        local caster = self:GetCaster()

        -- UP 3.1
        if self:GetRank(1) then
            caster:AddNewModifier(caster, self, "shadow_3_modifier_night", {})
        end
    end

    --function shadow_3__walk:OnOwnerDied()
        -- local caster = self:GetCaster()

        -- -- UP 3.3
        -- if self:GetRank(3) then
        --     local illu = CreateIllusions(
        --         caster, caster, {
        --             outgoing_damage = -100,
        --             incoming_damage = -50,
        --             bounty_base = 0,
        --             bounty_growth = 0,
        --             duration = 60,
        --         }, 1, 64, false, false
        --     )
        
        --     illu = illu[1]
        --     illu:AddNewModifier(caster, self, "shadow_3_modifier_illusion", {ignore_order = 2, aspd = 50})
        --     illu:SetOrigin(caster:GetOrigin())
        -- end
    --end

    function shadow_3__walk:CastFilterResultTarget(hTarget)
        local caster = self:GetCaster()
    
        if caster == hTarget then
            return UF_FAIL_CUSTOM
        end
    
        if hTarget:HasModifier("shadow_3_modifier_illusion") == false
        or hTarget:GetTeam() ~= caster:GetTeam() then
            return UF_FAIL_CUSTOM
        end
    
        return UF_SUCCESS
    end
    
    function shadow_3__walk:GetCustomCastErrorTarget(hTarget)
        local caster = self:GetCaster()
        if caster == hTarget then
            return "#dota_hud_error_cant_cast_on_self"
        end
        if caster:HasModifier("shadow_3_modifier_illusion") == false then
            return "INVALID TARGET"
        end
    end

-- EFFECTS

    function shadow_3__walk:PlayEfxBlink(direction, origin, target)
        local caster = self:GetCaster()
        local particle_cast_a = "particles/econ/events/ti9/blink_dagger_ti9_start_lvl2.vpcf"
        local particle_cast_b = "particles/econ/events/ti9/blink_dagger_ti9_lvl2_end.vpcf"

        local effect_cast_a = ParticleManager:CreateParticle(particle_cast_a, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(effect_cast_a, 0, origin)
        ParticleManager:SetParticleControlForward(effect_cast_a, 0, direction:Normalized())
        ParticleManager:SetParticleControl(effect_cast_a, 1, origin + direction)
        ParticleManager:ReleaseParticleIndex(effect_cast_a)

        local effect_cast_b = ParticleManager:CreateParticle(particle_cast_b, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(effect_cast_b, 0, caster:GetOrigin())
        ParticleManager:SetParticleControlForward(effect_cast_b, 0, direction:Normalized())
        ParticleManager:ReleaseParticleIndex(effect_cast_b)

        if IsServer() then caster:EmitSound("Hero_PhantomAssassin.Strike.End") end
    end
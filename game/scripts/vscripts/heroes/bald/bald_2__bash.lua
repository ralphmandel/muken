bald_2__bash = class({})
LinkLuaModifier("bald_2_modifier_heap", "heroes/bald/bald_2_modifier_heap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bald_2_modifier_dash", "heroes/bald/bald_2_modifier_dash", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("bald_2_modifier_impact", "heroes/bald/bald_2_modifier_impact", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("bald_2_modifier_gesture", "heroes/bald/bald_2_modifier_gesture", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function bald_2__bash:CalcStatus(duration, caster, target)
        if caster == nil or target == nil then return duration end
        if IsValidEntity(caster) == false or IsValidEntity(target) == false then return duration end
        local base_stats = caster:FindAbilityByName("base_stats")

        if caster:GetTeamNumber() == target:GetTeamNumber() then
            if base_stats then duration = duration * (1 + base_stats:GetBuffAmp()) end
        else
            if base_stats then duration = duration * (1 + base_stats:GetDebuffAmp()) end
            duration = duration * (1 - target:GetStatusResistance())
        end
        
        return duration
    end

    function bald_2__bash:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

    function bald_2__bash:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function bald_2__bash:GetRank(upgrade)
        local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_bristleback" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[2][upgrade] end
    end

    function bald_2__bash:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_bristleback" then return end

        local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then
            base_hero.ranks[2][0] = true
            if self:GetLevel() == 1 then base_hero:CheckSkills(1, self) end
        end
    end

    function bald_2__bash:Spawn()
    end

-- SPELL START

    function bald_2__bash:OnSpellStart()
        local caster = self:GetCaster()

        if caster:HasModifier("bald_2_modifier_heap") then
            self:PerformDash()
        else
            self:PrepareDash()
        end
    end

    function bald_2__bash:PrepareDash()
        local caster = self:GetCaster()
        local max_charge = self:GetSpecialValueFor("max_charge")

        caster:AddNewModifier(caster, self, "bald_2_modifier_heap", {})
    end

    function bald_2__bash:PerformDash()
        local caster = self:GetCaster()
        self.target = self:GetCursorTarget()

        local heap = caster:FindModifierByName("bald_2_modifier_heap")
        if heap then
            caster:AddNewModifier(caster, self, "bald_2_modifier_dash", {
                duration = (heap.time + heap.max_charge) * 0.06
            })

            heap:Destroy()
        end
    end

    function bald_2__bash:ApplyImpact(target)
        local caster = self:GetCaster()
        if target:IsInvisible() then return end

        local mod = target:FindAllModifiersByName("_modifier_stun")
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then return end
        end

        self:PlayEfxImpact(target)
    
        ApplyDamage({
            damage = self.damage,
            attacker = caster,
            victim = target,
            damage_type = self:GetAbilityDamageType(),
            ability = self,
            damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK
        })
        
        target:AddNewModifier(caster, self, "_modifier_stun", {
            duration = self:CalcStatus(self.stun, caster, target)
        })
    
        target:AddNewModifier(caster, nil, "modifier_knockback", {
            duration = 0.25,
            knockback_duration = 0.25,
            knockback_distance = self.stun * 50,
            center_x = caster:GetAbsOrigin().x + 1,
            center_y = caster:GetAbsOrigin().y + 1,
            center_z = caster:GetAbsOrigin().z,
            knockback_height = self.stun * 20,
        })
    end

    function bald_2__bash:OnOwnerSpawned()
        self:SetActivated(true)
    end

    function bald_2__bash:GetAbilityTextureName()
        if self:GetCaster():HasModifier("bald_2_modifier_heap") then
            return "bald_bash_2"
        else
            return "bald_bash"
        end
    end

    function bald_2__bash:GetBehavior()
        if self:GetCaster():HasModifier("bald_2_modifier_heap") then
            return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
        else
            return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
        end
    end

-- EFFECTS

    function bald_2__bash:PlayEfxImpact(target)
        local sound_cast = "Hero_Spirit_Breaker.GreaterBash.Creep"
        if target:IsHero() then sound_cast = "Hero_Spirit_Breaker.GreaterBash" end 

        local particle_cast = "particles/econ/items/spirit_breaker/spirit_breaker_weapon_ti8/spirit_breaker_bash_ti8.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, target)
        ParticleManager:SetParticleControlEnt(effect_cast, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
        ParticleManager:ReleaseParticleIndex(effect_cast)

        if IsServer() then target:EmitSound(sound_cast) end
    end
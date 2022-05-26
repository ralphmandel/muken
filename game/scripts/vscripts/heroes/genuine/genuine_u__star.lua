genuine_u__star = class({})
LinkLuaModifier("genuine_u_modifier_caster", "heroes/genuine/genuine_u_modifier_caster", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_u_modifier_target", "heroes/genuine/genuine_u_modifier_target", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_blind", "modifiers/_modifier_blind", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_blind_stack", "modifiers/_modifier_blind_stack", LUA_MODIFIER_MOTION_NONE)

-- INIT

    function genuine_u__star:CalcStatus(duration, caster, target)
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

    function genuine_u__star:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

    function genuine_u__star:RemoveBonus(string, target)
        local stringFormat = string.format("%s_modifier_stack", string)
        local mod = target:FindAllModifiersByName(stringFormat)
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self then modifier:Destroy() end
        end
    end

    function genuine_u__star:GetRank(upgrade)
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        local att = caster:FindAbilityByName("genuine__attributes")
        if not att then return end
        if not att:IsTrained() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

        return att.talents[4][upgrade]
    end

    function genuine_u__star:OnUpgrade()
        local caster = self:GetCaster()
        if caster:IsIllusion() then return end
        if caster:GetUnitName() ~= "npc_dota_hero_drow_ranger" then return end

        local att = caster:FindAbilityByName("genuine__attributes")
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

        -- UP 4.42
        if self:GetRank(42) == false then
            charges = charges * 2
        end

        self:SetCurrentAbilityCharges(charges)
    end

    function genuine_u__star:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

    function genuine_u__star:OnAbilityPhaseStart()
        local caster = self:GetCaster()
        caster:FindModifierByName("genuine__modifier_effect"):ChangeActivity("")
        
        local particle_cast = "particles/genuine/ult_caster/genuine_ult_caster.vpcf"
	    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:ReleaseParticleIndex(effect_cast)

        return true
    end

    function genuine_u__star:OnAbilityPhaseInterrupted()
        local caster = self:GetCaster()
        caster:FindModifierByName("genuine__modifier_effect"):ChangeActivity("ti6")
    end

    function genuine_u__star:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        local duration = self:GetSpecialValueFor("duration")
        caster:FindModifierByName("genuine__modifier_effect"):ChangeActivity("ti6")

        -- UP 4.42
        if self:GetRank(42) == false then
            if target:TriggerSpellAbsorb(self) then return end
        end
        
        self:PlayEfxStart(caster, target)
        self:PlayEfxStart(target, caster)
        if IsServer() then target:EmitSound("Hero_Terrorblade.DemonZeal.Cast") end

        -- UP 4.11
        if self:GetRank(11) then
            duration = duration + 1.5
        end

        target:AddNewModifier(caster, self, "genuine_u_modifier_target", {
            duration = self:CalcStatus(duration, caster, target)
        })
    end

    function genuine_u__star:CreateStarfall(target)
        self:PlayEfxStarfall(target)

		Timers:CreateTimer((0.5), function()
			if target ~= nil then
				if IsValidEntity(target) then
					self:ApplyStarfall(target)
				end
			end
		end)
    end

    function genuine_u__star:ApplyStarfall(target)
        local caster = self:GetCaster()
        local starfall_damage = 75
        local starfall_radius = 200
        local damageTable = {
            attacker = caster,
            damage = starfall_damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        }
        
        local enemies = FindUnitsInRadius(
            caster:GetTeamNumber(), target:GetOrigin(), nil, starfall_radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            0, 0, false
        )

        for _,enemy in pairs(enemies) do
            damageTable.victim = enemy
            ApplyDamage(damageTable)
        end

        if IsServer() then target:EmitSound("Hero_Mirana.Starstorm.Impact") end
    end

    function genuine_u__star:CastFilterResultTarget(hTarget)
        local caster = self:GetCaster()
        local flag = 0

        if caster == hTarget then
            return UF_FAIL_CUSTOM
        end

        -- UP 4.42
        if self:GetCurrentAbilityCharges() % 2 == 0 then
            flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
        end

        local result = UnitFilter(
            hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO,
            flag, caster:GetTeamNumber()
        )
        
        if result ~= UF_SUCCESS then
            return result
        end

        return UF_SUCCESS
    end

    function genuine_u__star:GetCustomCastErrorTarget(hTarget)
        if self:GetCaster() == hTarget then
            return "#dota_hud_error_cant_cast_on_self"
        end
    end

    function genuine_u__star:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level =  (1 + ((self:GetLevel() - 1) * 0.1))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
    end

-- EFFECTS

    function genuine_u__star:PlayEfxStart(hero_1, hero_2)
        local particle_cast = "particles/units/heroes/hero_terrorblade/terrorblade_sunder.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, hero_2)
        ParticleManager:SetParticleControlEnt(effect_cast, 0, hero_1, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
        ParticleManager:SetParticleControlEnt(effect_cast, 1, hero_2, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
        ParticleManager:SetParticleControl(effect_cast, 60, Vector(125, 0, 175))
        ParticleManager:SetParticleControl(effect_cast, 61, Vector(1, 0, 0))
        ParticleManager:ReleaseParticleIndex(effect_cast)
    end

    function genuine_u__star:PlayEfxStarfall(target)
        local particle_cast = "particles/genuine/starfall/genuine_starfall_attack.vpcf"
        local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
        ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
        ParticleManager:ReleaseParticleIndex(effect_cast)
    
        if IsServer() then target:EmitSound("Hero_Mirana.Starstorm.Cast") end
    end
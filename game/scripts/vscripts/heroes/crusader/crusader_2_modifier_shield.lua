crusader_2_modifier_shield = class({})

function crusader_2_modifier_shield:IsHidden()
	return false
end

function crusader_2_modifier_shield:IsPurgable()
    return true
end

-----------------------------------------------------------

function crusader_2_modifier_shield:OnCreated( kv )
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

    self.max_damage = self:GetAbility():GetSpecialValueFor("max_damage")
    self.converted_damage = self:GetAbility():GetSpecialValueFor("converted_damage")

    -- UP 2.1
    if self.ability:GetRank(1) then
        self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {percent = 10})
    end

	-- UP 2.3
	if self.ability:GetRank(3) then
        self.converted_damage = self.converted_damage + 15
	end

	-- UP 2.6
	if self.ability:GetRank(6) then
        local radius = 400
		local allies = FindUnitsInRadius(
			self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, radius,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
			0, 0, false
		)
	
		for _,ally in pairs(allies) do
            if ally ~= self.parent then
			    ally:AddNewModifier(self.caster, self.ability, "crusader_2_modifier_absorption", {})
            end
		end

        self:PlayEfxAbs(self.parent:GetOrigin(), radius)
	end

    if IsServer() then
        self:SetStackCount(self.max_damage)
        self:PlayEfxStart(false)

        -- UP 2.4
        if self.ability:GetRank(4) then
            self:StartIntervalThink(0.5)
        end       
    end
end

function crusader_2_modifier_shield:OnRefresh( kv )
    self.max_damage = self:GetAbility():GetSpecialValueFor("max_damage")
    self.converted_damage = self:GetAbility():GetSpecialValueFor("converted_damage") * 0.01

    -- UP 2.1
    if self.ability:GetRank(1) then
        local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_buff")
        for _,modifier in pairs(mod) do
            if modifier:GetAbility() == self.ability then modifier:Destroy() end
        end

        self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {percent = 10})
    end

    -- UP 2.3
	if self.ability:GetRank(3) then
        self.converted_damage = self.converted_damage + 15
	end

	-- UP 2.6
	if self.ability:GetRank(6) then
        local radius = 400
		local allies = FindUnitsInRadius(
			self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, radius,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
			0, 0, false
		)
	
		for _,ally in pairs(allies) do
            if ally ~= self.parent then
			    ally:AddNewModifier(self.caster, self.ability, "crusader_2_modifier_absorption", {})
            end
		end

        self:PlayEfxAbs(self.parent:GetOrigin(), radius)
	end

    if IsServer() then
        self:SetStackCount(self.max_damage)
        self:PlayEfxStart(true)

        -- UP 2.4
        if self.ability:GetRank(4) then
            self:StartIntervalThink(0.5)
        end   
    end
end

function crusader_2_modifier_shield:OnRemoved()
    if IsServer() then
        self.parent:StopSound("Hero_Abaddon.AphoticShield.Loop")
        self.parent:EmitSound("Hero_Abaddon.Curse.Proc")
    end

    local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_buff")
    for _,modifier in pairs(mod) do
        if modifier:GetAbility() == self.ability then modifier:Destroy() end
    end

    -- UP 2.2
	if self.ability:GetRank(2) then
		if self:GetStackCount() < 1 and self.parent:IsAlive() then
            self.parent:Purge(false, true, false, true, false)
        end
	end

    -- UP 2.5
	if self.ability:GetRank(5) then
        local radius = 400
        local root_duration = 2
        local damage = (self.max_damage - self:GetStackCount()) / 3
        local damageTable = {
            victim = nil,
            attacker = self.parent,
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self.ability
        }
    
        local enemies = FindUnitsInRadius(
            self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            0, 0, false
        )
    
        for _,enemy in pairs(enemies) do
            damageTable.victim = enemy
            ApplyDamage(damageTable)
    
            if enemy:IsAlive() then
                enemy:AddNewModifier(self.caster, self.ability, "_modifier_root", {
                    duration = self.ability:CalcStatus(root_duration, self.caster, enemy),
                    effect = 2
                })
            end
        end
    
        self:PlayEfxFinal(radius)
	end

    -- UP 2.4
    if self.ability:GetRank(4) == false then
        self.ability:SetActivated(true)
        self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
    end
end

-----------------------------------------------------------

function crusader_2_modifier_shield:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_AVOID_DAMAGE,
        --MODIFIER_PROPERTY_ABSORB_SPELL,
    }
    return funcs
end

function crusader_2_modifier_shield:GetModifierAvoidDamage(keys)
    local heal = keys.damage * self.converted_damage * 0.01
    local mnd = self.caster:FindModifierByName("_2_MND_modifier")
	if mnd then heal = heal * mnd:GetHealPower() end
    if heal > 0 then
        self.parent:Heal(heal, self.ability)
        self:PlayEfxLifesteal()
    end

    self:PlayEfxDamage(keys.damage)
    self:SetStackCount(self:GetStackCount() - keys.damage)

    if self:GetStackCount() < 1 then
        self:SetStackCount(0)
        self:Destroy()
    end

    return 1
end

function crusader_2_modifier_shield:OnIntervalThink()
    self.ability:StartCooldown(self.ability:GetCooldownTimeRemaining() + 0.25)
end

-- function crusader_2_modifier_shield:GetAbsorbSpell(keys)
-- 	if IsServer() then
-- 		if self.block_spell > 0 then
--             self.block_spell = self.block_spell - 1
-- 			self:PlayEfxBlockSpell()
-- 			return 1
-- 		end
-- 	end
-- end

------------------------------------------------------------------------

function crusader_2_modifier_shield:PlayEfxStart(sound_only)
    if IsServer() then self.parent:EmitSound("Hero_Abaddon.AphoticShield.Cast") end
    if sound_only == true then return end

    local particle_cast = "particles/units/heroes/hero_abaddon/abaddon_aphotic_shield.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
    ParticleManager:SetParticleControl(effect_cast, 1, Vector(100, 0, 0))
    self:AddParticle(effect_cast, false, false, -1, false, false)

    if IsServer() then self.parent:EmitSound("Hero_Abaddon.AphoticShield.Loop") end
end

function crusader_2_modifier_shield:PlayEfxLifesteal()
	local particle_cast = "particles/units/heroes/hero_abaddon/abaddon_borrowed_time_heal.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)

    --if IsServer() then self.parent:EmitSound("Hero_Oracle.FalsePromise.Healed") end
end

function crusader_2_modifier_shield:PlayEfxDamage(damage)
    if damage == nil then return end
    if damage < 1 then return end
	local particle_cast = "particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_hit.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
    ParticleManager:SetParticleControl(effect_cast, 1, Vector(100, 100, 50))
    self:AddParticle(effect_cast, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_Medusa.ManaShield.Proc") end
end

function crusader_2_modifier_shield:PlayEfxFinal(radius)
    local particle_cast = "particles/econ/items/pugna/pugna_ti9_immortal/pugna_ti9_immortal_netherblast.vpcf"
    local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_POINT_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
    ParticleManager:SetParticleControl(effect_cast, 1, Vector(1, radius * 1.5, radius * 1.5))

    if IsServer() then self.parent:EmitSound("Hero_Abaddon.AphoticShield.Destroy") end
end

function crusader_2_modifier_shield:PlayEfxAbs(point, radius)
    --local sound_cast = "Hero_DarkWillow.Fear.FP"
	local particle_cast = "particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast, 0, point)
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(radius, 0, radius * 2))
	ParticleManager:ReleaseParticleIndex(effect_cast)

    if IsServer() then self.parent:EmitSound("Hero_MonkeyKing.Spring.Channel") end
end
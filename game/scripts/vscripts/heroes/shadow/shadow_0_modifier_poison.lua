shadow_0_modifier_poison = class({})
local tempTable = require("libraries/tempTable")

function shadow_0_modifier_poison:IsPurgable()
	return self.purge
end

function shadow_0_modifier_poison:IsHidden()
	return false
end

function shadow_0_modifier_poison:IsDebuff()
	return true
end

function shadow_0_modifier_poison:GetTexture()
	return "shadow_poison"
end

--------------------------------------------------------------------------------
-- Initializations

function shadow_0_modifier_poison:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local total_damage = 0
	self.total = kv.total or 0
	self.total_stack = self.total
	self.poison_heal = 0
	self.poison_damage = 10
	self.ticks = 15
	self.purge = true
	self.tracking = 0
	self.break_invi = false

	local sick = self.caster:FindAbilityByName("shadow_x2__sick")
	if sick then
		if sick:IsTrained() then
			sick:SetActivated(true)
		end
	end

	local poison_duration = 12
	if self.parent:HasModifier("shadow_x1_modifier_heart") then
		self.purge = false
		poison_duration = poison_duration * 2
	end

	self:SetStackCount(1)

    if IsServer() then
        -- add stack modifier
		local this = tempTable:AddATValue( self )
		self.parent:AddNewModifier(
			self.caster, -- player source
			self.ability, -- ability source
			"shadow_0_modifier_poison_stack", -- modifier name
			{
				duration = self.ability:CalcStatus(poison_duration, self.caster, self.parent),
				modifier = this,
			} -- kv
		)

		self.damageTable = {
			victim = self.parent,
			attacker = self.caster,
			--damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
			ability = self.ability
		}
		
		for x = 1, self:GetStackCount(), 1 do
			total_damage = total_damage + (self.poison_damage * (0.8^x))
		end

		self.damageTable.damage = total_damage
		self.total = math.floor(ApplyDamage( self.damageTable ))
		self.total_stack = self.total_stack + self.total

		self:PlaySoundsEfx()
		self:PlayEffects(self.parent)
		self:StartIntervalThink(0.1) 
    end
end

function shadow_0_modifier_poison:OnRefresh( kv )
	local poison_duration = 12
	if self.parent:HasModifier("shadow_x1_modifier_heart") then
		poison_duration = poison_duration * 2
	end

    if IsServer() then
		-- add stack
		local this = tempTable:AddATValue( self )
		self.parent:AddNewModifier(
			self.caster, -- player source
			self.ability, -- ability source
			"shadow_0_modifier_poison_stack", -- modifier name
			{
				duration = self.ability:CalcStatus(poison_duration, self.caster, self.parent),
				modifier = this,
			} -- kv
		)
		
		-- increment stack
		self:IncrementStackCount()
		--self:PlaySoundsEfx()
	end
end

function shadow_0_modifier_poison:OnRemoved()
	if IsServer() then self.parent:StopSound("Hero_Alchemist.AcidSpray") end

	local sick = self.caster:FindAbilityByName("shadow_x2__sick")
	if sick then if sick:IsTrained() then sick:CheckUnits() end end

	local dagger = self.caster:FindAbilityByName("shadow_u__dagger")
	if dagger then if dagger:IsTrained() == false then return end end

	-- UP 4.4
	if dagger:GetRank(4) and dagger:GetTargetHit() == self.parent then
		local radius = 700
		self:PlayEffectsSplash(self.parent, radius)

		local enemies = FindUnitsInRadius(
			self.caster:GetTeamNumber(),	-- int, your team number
			self.parent:GetOrigin(),	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)
	
		for _,enemy in pairs(enemies) do
			if self.parent ~= enemy then
				enemy:AddNewModifier(
					self.caster, -- player source
					self.ability, -- ability source
					"shadow_0_modifier_poison", -- modifier name
					{total = self.total_stack / 2} -- kv
				)
		
				self:PlayEffectsHit(enemy)
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Interval Effects

function shadow_0_modifier_poison:OnIntervalThink()

	local dagger = self.caster:FindAbilityByName("shadow_u__dagger")
	if dagger then
		if dagger:IsTrained() then
			-- UP 4.3
			if dagger:GetRank(3) then
				if dagger:IsCooldownReady() or dagger.landed == true then
					if self.parent:IsInvisible() == false and self.parent:IsHero() then
						AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), 50, 0.2, false)
					end
					self.break_invi = true
				else
					self.break_invi = false
				end
			end
		end
	end

	if self.parent:HasModifier("shadow_x1_modifier_heart") then
		self.purge = false
	else
		self.purge = true
	end

	self.ticks = self.ticks - 1

	if self.ticks < 1 then
		self.ticks = 15

		if IsServer() then
			local total_damage = 0
			for x = 1, self:GetStackCount(), 1 do
				total_damage = total_damage + (self.poison_damage * (0.8^x))
			end

			self.damageTable.damage = total_damage
			self.total = math.floor(ApplyDamage( self.damageTable ))
			self.total_stack = self.total_stack + self.total
		end

		self:PlayEffects(self.parent)
	end

	if self.parent:HasModifier("shadow_1_modifier_faster")
	and self.ticks > 5 then
		self.ticks = 5
	end
end

function shadow_0_modifier_poison:OnStackCountChanged(old)
	if self:GetStackCount() == 0 then
		self:Destroy()
	end
end

function shadow_0_modifier_poison:GetPoisonDamage()
	return self.poison_heal
end

function shadow_0_modifier_poison:GetTotalPoisonDamage()
	return self.total_stack
end

----------------------------------------------------------------------------

function shadow_0_modifier_poison:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = false,
	}

	if self.break_invi == true then
		return state
	end
end

function shadow_0_modifier_poison:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function shadow_0_modifier_poison:DeclareFunctions()

    local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
 
    return funcs
end

function shadow_0_modifier_poison:GetModifierIncomingDamage_Percentage(keys)
	if keys.attacker:IsBaseNPC() == false then return 0 end
    if keys.attacker ~= self.caster then return 0 end
	if keys.inflictor == nil then return 0 end

	if keys.inflictor:GetAbilityName() == "shadow_1__weapon"
	or keys.inflictor:GetAbilityName() == "shadow_2__smoke"
	or keys.inflictor:GetAbilityName() == "shadow_3__walk" then
		self.poison_heal = keys.original_damage
	end
	
	return 0
end

function shadow_0_modifier_poison:OnAttackLanded(keys)
	if keys.target ~= self.parent then return end

	if keys.attacker:HasModifier("shadow_3_modifier_illusion")
	or keys.attacker:HasModifier("shadow_3_modifier_invisible") then
		local total_damage = 0
		for x = 1, self:GetStackCount(), 1 do
			total_damage = total_damage + (self.poison_damage * (0.8^x))
		end

		if keys.attacker:IsIllusion()
		and self.caster:HasModifier("shadow_x2_modifier_sick") == false then
			total_damage = total_damage * 0.25 -- DAMAGE REDUCTION SPECIAL FOR SHADOWS
		end
		
		self.damageTable.damage = total_damage
		self.total = math.floor(ApplyDamage( self.damageTable ))
		self.total_stack = self.total_stack + self.total
		self:PlayEffects(self.parent)
	end
end

--------------------------------------------------------------------------------

function shadow_0_modifier_poison:GetStatusEffectName()
    return "particles/status_fx/status_effect_maledict.vpcf"
end

function shadow_0_modifier_poison:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function shadow_0_modifier_poison:PlayEffects( target )
	-- Get Resources
    local particle_cast = "particles/econ/events/ti9/blink_dagger_ti9_start_lvl2_splash.vpcf"

	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		0,
		target,
		PATTACH_ABSORIGIN_FOLLOW ,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function shadow_0_modifier_poison:PlayEffectsHit( target )
	local particle = "particles/units/heroes/hero_witchdoctor/witchdoctor_shard_switcheroo_cast.vpcf"
	
	if self.effect ~= nil then ParticleManager:DestroyParticle(self.effect, true) end
	self.effect = ParticleManager:CreateParticle( particle, PATTACH_ABSORIGIN, target )
	ParticleManager:SetParticleControl( self.effect, 0, target:GetOrigin() )
end

function shadow_0_modifier_poison:PlayEffectsSplash(target, radius)
	local particle_cast = "particles/units/heroes/hero_grimstroke/grimstroke_ink_swell_aoe.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 2, Vector( radius, radius, radius ))

	if IsServer() then target:EmitSound("Hero_Venomancer.VenomousGale") end
end

function shadow_0_modifier_poison:PlaySoundsEfx()
	--if IsServer() then self.parent:EmitSound("Hero_Alchemist.AcidSpray") end
end
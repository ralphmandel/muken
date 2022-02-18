shadow_2_modifier_smoke = class({})

--------------------------------------------------------------------------------
-- Classifications
function shadow_2_modifier_smoke:IsHidden()
	return true
end

function shadow_2_modifier_smoke:IsPurgable()
	return false
end

function shadow_2_modifier_smoke:GetModifierProvidesFOWVision()
	return 1
end

--------------------------------------------------------------------------------
-- Initializations
function shadow_2_modifier_smoke:OnCreated( kv )

	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.radius = kv.radius
	self.intervals = self.ability:GetSpecialValueFor("intervals")
	self.duration = self.ability:GetSpecialValueFor("duration")
	self.time = 0.5

	self.delay = 0.3

    -- UP 2.5
    if self.ability:GetRank(5) then
		self.time = 0
		self.intervals = self.intervals - 0.25
    end
	
	self:StartIntervalThink(self.delay)
end

function shadow_2_modifier_smoke:OnRefresh( kv )
end

function shadow_2_modifier_smoke:OnDestroy()
end

--------------------------------------------------------------------------------

function shadow_2_modifier_smoke:OnIntervalThink()
	if self.time == self.duration then
		self:Destroy()
		return
	end

	if self.delay > 0 then
		self.delay = 0
		self:Ticks()
		self:StartIntervalThink(self.intervals)
		return
	end

	self.time = self.time + self.intervals
	self:Ticks()
end

function shadow_2_modifier_smoke:Ticks()
	self:PlayEffects()

	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(),	-- int, your team number
		self.parent:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	local sound = false
	for _,enemy in pairs(enemies) do
		
		-- UP 2.1
		if self.ability:GetRank(1)
		or enemy:IsMagicImmune() == false then
			enemy:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {duration = 0.5, percent = 100})
			enemy:AddNewModifier(self.caster, self.ability, "shadow_0_modifier_poison", {})
	
			self:PlayEffectsHit(enemy)
			sound = true			
		end

		-- UP 2.4
		if self.ability:GetRank(4) then
			enemy:AddNewModifier(
				self.caster, -- player source
				self.ability, -- ability source
				"_modifier_blind", -- modifier name
				{
					duration = self.intervals,
					miss_chance = 70,
					percent = 70
				} -- kv
			)
		end
	end

	if sound == true then
		self:PlayEffectsSound()
	end
end
--------------------------------------------------------------------------------

function shadow_2_modifier_smoke:PlayEffects()

	local particle_cast = "particles/units/heroes/hero_void_spirit/dissimilate/void_spirit_dissimilate_dmg.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, Vector( self.radius*0.65, self.radius*0.65, self.radius*0.65 ))

	if IsServer() then self.parent:EmitSound("Hero_Nightstalker.Void") end
end

function shadow_2_modifier_smoke:PlayEffectsHit( target )
	local particle = "particles/units/heroes/hero_witchdoctor/witchdoctor_shard_switcheroo_cast.vpcf"
	
	if self.effect ~= nil then ParticleManager:DestroyParticle(self.effect, true) end
	self.effect = ParticleManager:CreateParticle( particle, PATTACH_ABSORIGIN, target )
	ParticleManager:SetParticleControl( self.effect, 0, target:GetOrigin() )
end

function shadow_2_modifier_smoke:PlayEffectsSound()
	if IsServer() then self.parent:EmitSound("Hero_Bioshadow.Poison") end
end
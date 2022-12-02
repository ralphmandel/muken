bald_5_modifier_spike_caster = class({})

function bald_5_modifier_spike_caster:IsHidden() return false end
function bald_5_modifier_spike_caster:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_5_modifier_spike_caster:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.total_amount = 0

	self.amount = self.ability:GetSpecialValueFor("amount")

	self.ability:EndCooldown()
	self.ability:SetActivated(false)

	if IsServer() then
		self:SetStackCount(1)
		self:PlayEfxStart()
	end
end

function bald_5_modifier_spike_caster:OnRefresh(kv)
	self.amount = self.ability:GetSpecialValueFor("amount")

	if IsServer() then
		self:IncrementStackCount()
		self:PlayEfxStart()
	end
end

function bald_5_modifier_spike_caster:OnRemoved()
	if IsServer() then self.parent:StopSound("Hero_Bristleback.PistonProngs.IdleLoop") end
	
	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
	self.ability:SetActivated(true)
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_5_modifier_spike_caster:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function bald_5_modifier_spike_caster:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end

	self:IncrementAmount(keys.damage)
end

function bald_5_modifier_spike_caster:OnStackCountChanged(old)
	if old == self:GetStackCount() then return end
	if self:GetStackCount() == 0 then self:Destroy() end
end

-- UTILS -----------------------------------------------------------

function bald_5_modifier_spike_caster:IncrementAmount(damage)
	self.total_amount = self.total_amount + damage
	if self.total_amount > self.amount then
		self.total_amount = self.total_amount - self.amount
		self:ReleaseSpikes()
		self:IncrementAmount(0)
	end
end

function bald_5_modifier_spike_caster:ReleaseSpikes()
	local spike_radius = self.ability:GetSpecialValueFor("spike_radius")
	local damage = self.ability:GetSpecialValueFor("damage")
	self:PlayEfxQuill(spike_radius * self.parent:GetModelScale())

	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, spike_radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0, 0, false
	)

	for _,enemy in pairs(enemies) do
		self:PlayEfxQuillImpact(enemy)
		local dist = spike_radius - (CalcDistanceBetweenEntityOBB(self.parent, enemy) * 0.5)
		local knock_duration = self.ability:CalcStatus(dist * 0.001, self.caster, enemy)
		local knock_distance = self.ability:CalcStatus(dist * 0.4, self.caster, enemy)
	
		enemy:AddNewModifier(self.caster, nil, "modifier_knockback", {
			duration = knock_duration,
			knockback_duration =  knock_duration,
			knockback_distance = knock_distance,
			center_x = self.parent:GetAbsOrigin().x + 1,
			center_y = self.parent:GetAbsOrigin().y + 1,
			center_z = self.parent:GetAbsOrigin().z,
			knockback_height = 0,
		})

		ApplyDamage({
            damage = damage,
            attacker = self.caster,
            victim = enemy,
            damage_type = self.ability:GetAbilityDamageType(),
            ability = self.ability
		})
	end
end

-- EFFECTS -----------------------------------------------------------

function bald_5_modifier_spike_caster:PlayEfxStart()
	local particle_cast = "particles/bald/bald_ion/bald_ion.vpcf"
	local sound_cast = "Hero_Dark_Seer.Ion_Shield_Start"
	local sound_loop = "Hero_Dark_Seer.Ion_Shield_lp"
	local hull1 = self.parent:GetModelScale() * 70
	local hull2 = self.parent:GetModelScale() * 70

	if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, false) end
	self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(hull1, hull2, 0))
	self:AddParticle(self.effect_cast, false, false, -1, false, false)

	if IsServer() then
		self.parent:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
		self.parent:EmitSound("Hero_Bristleback.PistonProngs.IdleLoop")
	end
end

function bald_5_modifier_spike_caster:PlayEfxQuill(radius)
	local particle_cast = "particles/druid/druid_lotus/lotus_quill.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 10, Vector(radius, 0, 0))
	ParticleManager:SetParticleControl(effect_cast, 61, Vector(1, 0, 1))
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then self.parent:EmitSound("Hero_Bristleback.PistonProngs.QuillSpray.Cast") end
end

function bald_5_modifier_spike_caster:PlayEfxQuillImpact(target)
	local particle_cast = "particles/units/heroes/hero_bristleback/bristleback_quill_spray_impact.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, target)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then target:EmitSound("Hero_Bristleback.QuillSpray.Target") end
end
dasdingo_6_modifier_fire = class({})

function dasdingo_6_modifier_fire:IsHidden()
	return false
end

function dasdingo_6_modifier_fire:IsPurgable()
	return true
end

function dasdingo_6_modifier_fire:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function dasdingo_6_modifier_fire:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local intervals = 0.5
	local fire_damage = self.ability:GetSpecialValueFor("fire_damage") * intervals
	self.max_stack = self.ability:GetSpecialValueFor("max_stack")

	self.damageTable = {
		victim = self.parent,
		attacker = self.caster,
		damage = fire_damage,
		damage_type = self.ability:GetAbilityDamageType(),
		ability = self.ability
	}

	if IsServer() then
		local stack_init = 1
		local mod = self.parent:FindAllModifiersByName("_modifier_stun")
		for _,modifier in pairs(mod) do
			if modifier:GetAbility() == self.ability then stack_init = 0 end
		end

		self:SetStackCount(stack_init)
		self:StartIntervalThink(intervals)
		self.parent:EmitSound("Dasdingo.Fire.Loop")
	end
end

function dasdingo_6_modifier_fire:OnRefresh(kv)
	if IsServer() then
		local stunned = false
		local mod = self.parent:FindAllModifiersByName("_modifier_stun")
		for _,modifier in pairs(mod) do
			if modifier:GetAbility() == self.ability then stunned = true end
		end

		if stunned == false then self:IncrementStackCount() end

		if self:GetStackCount() < self.max_stack then
			self.parent:StopSound("Dasdingo.Fire.Loop")
			self.parent:EmitSound("Dasdingo.Fire.Loop")
			return
		end		
	end

	local stun_duration = self.ability:GetSpecialValueFor("stun_duration")
	local blast_damage = self.ability:GetSpecialValueFor("blast_damage")

	self.parent:Purge(true, false, false, false, false)

	self.damageTable.damage = blast_damage
	ApplyDamage(self.damageTable)

	-- UP 6.21
	if self.ability:GetRank(21) then
		stun_duration = stun_duration + 1
	end

	-- UP 6.31
	if self.ability:GetRank(31) then
		self.ability:Explode(self.parent, 12)
	end

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_stun", {
		duration = self.ability:CalcStatus(stun_duration, self.caster, self.parent)
	})

	self:PlayEfxBlast()
	self:Destroy()
end

function dasdingo_6_modifier_fire:OnRemoved()
	if IsServer() then self.parent:StopSound("Dasdingo.Fire.Loop") end
end

--------------------------------------------------------------------------------

function dasdingo_6_modifier_fire:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function dasdingo_6_modifier_fire:OnAttackLanded(keys)
end

function dasdingo_6_modifier_fire:OnIntervalThink()
	ApplyDamage(self.damageTable)
end

--------------------------------------------------------------------------------

function dasdingo_6_modifier_fire:GetEffectName()
	return "particles/dasdingo/dasdingo_fire_debuff.vpcf"
end

function dasdingo_6_modifier_fire:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function dasdingo_6_modifier_fire:PlayEfxBlast()
	local particle_cast = "particles/econ/items/alchemist/alchemist_smooth_criminal/alchemist_smooth_criminal_unstable_concoction_explosion.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(effect_cast, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then self.parent:EmitSound("Hero_Batrider.Flamebreak.Impact") end
end
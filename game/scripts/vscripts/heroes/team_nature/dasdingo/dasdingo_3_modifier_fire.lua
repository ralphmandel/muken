dasdingo_3_modifier_fire = class({})

function dasdingo_3_modifier_fire:IsHidden()
	return false
end

function dasdingo_3_modifier_fire:IsPurgable()
	return true
end

function dasdingo_3_modifier_fire:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function dasdingo_3_modifier_fire:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local intervals = 0.6
	local fire_damage = self.ability:GetSpecialValueFor("fire_damage") * intervals

	self.damageTable = {
		victim = self.parent,
		attacker = self.caster,
		damage = fire_damage,
		damage_type = self.ability:GetAbilityDamageType(),
		ability = self.ability
	}

	-- UP 3.11
	if self.ability:GetRank(11) then
		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {
			percent = 15
		})
	end

	if IsServer() then
		self:SetStackCount(1)
		self:StartIntervalThink(intervals)
		self.parent:EmitSound("Dasdingo.Fire.Loop")
	end
end

function dasdingo_3_modifier_fire:OnRefresh(kv)
	if IsServer() then
		self.parent:StopSound("Dasdingo.Fire.Loop")
		self.parent:EmitSound("Dasdingo.Fire.Loop")
	end
end

function dasdingo_3_modifier_fire:OnRemoved()
	if IsServer() then self.parent:StopSound("Dasdingo.Fire.Loop") end

	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	local min_stack = self.ability:GetSpecialValueFor("min_stack")
	local blast_damage = self.ability:GetSpecialValueFor("blast_damage")
	local stun_base = self.ability:GetSpecialValueFor("stun_base")
	local stun_mult = self.ability:GetSpecialValueFor("stun_mult") * self:GetStackCount()
	local stun_total = stun_base + stun_mult

	if self:GetStackCount() < min_stack then return end

	self.parent:Purge(true, false, false, false, false)
	self.damageTable.damage = blast_damage
	ApplyDamage(self.damageTable)

	if self.parent:IsAlive() == false then return end

	-- UP 3.21
	if self.ability:GetRank(21) then
		stun_total = stun_total * 1.25
	end

	-- UP 3.31
	if self.ability:GetRank(31) then
		self.ability:Explode(self.parent, 12)
	end

	-- UP 3.41
	if self.ability:GetRank(41) then
		self.parent:AddNewModifier(self.caster, self.ability, "dasdingo_3_modifier_ignition", {
			duration = CalcStatus(7, self.caster, self.parent)
		})
	end

	stun_total = CalcStatus(stun_total, self.caster, self.parent)
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_stun", {duration = stun_total})
	self.ability:StartCooldown(stun_total)

	self:PlayEfxBlast()
end

--------------------------------------------------------------------------------

function dasdingo_3_modifier_fire:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function dasdingo_3_modifier_fire:OnAttackLanded(keys)
end

function dasdingo_3_modifier_fire:OnIntervalThink()
	ApplyDamage(self.damageTable)
end

--------------------------------------------------------------------------------

function dasdingo_3_modifier_fire:GetEffectName()
	return "particles/dasdingo/dasdingo_fire_debuff.vpcf"
end

function dasdingo_3_modifier_fire:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function dasdingo_3_modifier_fire:PlayEfxBlast()
	local particle_cast = "particles/econ/items/alchemist/alchemist_smooth_criminal/alchemist_smooth_criminal_unstable_concoction_explosion.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(effect_cast, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then self.parent:EmitSound("Hero_Batrider.Flamebreak.Impact") end
end
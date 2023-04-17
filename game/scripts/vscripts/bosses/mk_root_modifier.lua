mk_root_modifier = class({})

function mk_root_modifier:IsHidden()
	return true
end

function mk_root_modifier:IsPurgable()
	return true
end

--------------------------------------------------------------------------------

function mk_root_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local intervals = self.ability:GetSpecialValueFor("intervals")
	local damage = self.ability:GetSpecialValueFor("damage_sec") * intervals

	self.damageTable = {
		victim = self.parent,
		attacker = self.caster,
		damage = damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability
	}

	self.info = {
		Target = self.caster,
		Source = self.parent,
		Ability = self.ability,	
		EffectName = "particles/druid/druid_ult_projectile.vpcf",
		iMoveSpeed = 250,
		bReplaceExisting = false,
		bProvidesVision = true,
		iVisionRadius = 100,
		iVisionTeamNumber = self.caster:GetTeamNumber(),
    bDodgeable = false
	}

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_root", {effect = 7})
	self:StartIntervalThink(intervals)
end

function mk_root_modifier:OnRefresh( kv )
end

function mk_root_modifier:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_root", self.ability)
end

--------------------------------------------------------------------------------

function mk_root_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH
	}

	return funcs
end

function mk_root_modifier:OnDeath(keys)
	if keys.unit ~= self.caster then return end
	self:Destroy()
end

function mk_root_modifier:OnIntervalThink()
	if IsServer() then self.parent:EmitSound("Hero_Sandking.EpiPulse") end

	local damage = ApplyDamage(self.damageTable)
	self.info.ExtraData = {damage = damage}
	ProjectileManager:CreateTrackingProjectile(self.info)
end
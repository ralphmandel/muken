burning_armor_modifier = class({})

function burning_armor_modifier:IsHidden()
	return false
end

function burning_armor_modifier:IsPurgable()
    return false
end

function burning_armor_modifier:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

    local damage = self.ability:GetSpecialValueFor("damage")
    local tick = self.ability:GetSpecialValueFor("tick")

	self.damageTable = {
		damage = damage * tick,
		attacker = self.caster,
		victim = nil,
		damage_type = self.ability:GetAbilityDamageType(),
		ability = self.ability
	}

	if IsServer() then
		self:StartIntervalThink(tick)
		self:PlayEfxAmbient()
	end
end

function burning_armor_modifier:OnRefresh(kv)
end

function burning_armor_modifier:OnRemoved()
	if IsServer() then self.parent:StopSound("Igneo.Burn.Loop") end
end

--------------------------------------------------------------------------------------------------------------------------

function burning_armor_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH
	}

	return funcs
end

function burning_armor_modifier:OnDeath(keys)
	if keys.unit ~= self.caster then return end
	self:Destroy()
end 

function burning_armor_modifier:OnIntervalThink()
	if self.parent:PassivesDisabled() then return end
	local radius = self.ability:GetSpecialValueFor("radius")

	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0, 0, false
	)

	for _,enemy in pairs(enemies) do
		self.damageTable.victim = enemy
		ApplyDamage(self.damageTable)
	end

	if IsServer() then
		self.parent:StopSound("Igneo.Burn.Loop")
		self.parent:EmitSound("Igneo.Burn.Loop")
	end
end

--------------------------------------------------------------------------------------------------------------------------

function burning_armor_modifier:GetEffectName()
	return "particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf"
end

function burning_armor_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function burning_armor_modifier:PlayEfxAmbient()
	local ambient = "particles/econ/items/warlock/warlock_hellsworn_construct/golem_hellsworn_ambient.vpcf"
	local particle = ParticleManager:CreateParticle(ambient, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControlEnt(particle, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	self:AddParticle(particle, false, false, -1, false, false)
end
osiris_4_modifier_rot = class({})

function osiris_4_modifier_rot:IsHidden()
	return true
end

function osiris_4_modifier_rot:IsPurgable()
	return false
end

function osiris_4_modifier_rot:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function osiris_4_modifier_rot:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.radius = self.ability:GetSpecialValueFor("radius")
	self.tick = self.ability:GetSpecialValueFor("tick")
	self.slow = self.ability:GetSpecialValueFor("slow")

	if IsServer() then
		self:StartIntervalThink(self.tick)
		self:PlayEfxStart()
	end
end

function osiris_4_modifier_rot:OnRefresh(kv)
end

function osiris_4_modifier_rot:OnRemoved()
	if self.pfx then ParticleManager:DestroyParticle(self.pfx, false) end
	if IsServer() then self.parent:StopSound("Hero_Pudge.Rot") end
end

-- API FUNCTIONS -----------------------------------------------------------

function osiris_4_modifier_rot:OnIntervalThink()
	local damage = self.ability:GetSpecialValueFor("hp_lost") * self.tick
	self.parent:ModifyHealth(self.parent:GetHealth() - damage, self.ability, true, 0)

	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false
	)

	for _,enemy in pairs(enemies) do
		self:ApplyRot(enemy)
	end

	if IsServer() then self:StartIntervalThink(self.tick) end
end

-- UTILS -----------------------------------------------------------

function osiris_4_modifier_rot:ApplyRot(target)
	local mod = target:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	target:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {
		duration = 0.5, percent = self.slow
	})
end

-- EFFECTS -----------------------------------------------------------

function osiris_4_modifier_rot:PlayEfxStart()
	local string = "particles/econ/items/pudge/pudge_immortal_arm/pudge_immortal_arm_rot_gold.vpcf"
	self.pfx = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.pfx, 1, Vector(self.radius, 0, 0))
	self:AddParticle(self.pfx, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_Pudge.Rot") end
end
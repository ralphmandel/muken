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

function osiris_4_modifier_rot:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_STATE_CHANGED
	}

	return funcs
end

function osiris_4_modifier_rot:OnStateChanged(keys)
	if keys.unit ~= self.parent then return end
	if self.parent:IsSilenced() and self.ability:GetToggleState() then self.ability:ToggleAbility() end
end

function osiris_4_modifier_rot:OnIntervalThink()
	local damage = self.ability:GetSpecialValueFor("hp_lost") * self.tick
	self.parent:ModifyHealth(self.parent:GetHealth() - damage, self.ability, true, 0)

	--local poison_ability = self.parent:FindAbilityByName("osiris_1__poison")
	--if poison_ability then poison_ability:CalcHPLost(damage) end

	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false
	)

	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(self.caster, self.ability, "osiris_4_modifier_debuff", {
			duration = 0.4
		})
	end

	if IsServer() then self:StartIntervalThink(self.tick) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function osiris_4_modifier_rot:PlayEfxStart()
	local string = "particles/econ/items/pudge/pudge_immortal_arm/pudge_immortal_arm_rot_gold.vpcf"
	self.pfx = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.pfx, 1, Vector(self.radius, 0, 0))
	self:AddParticle(self.pfx, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_Pudge.Rot") end
end
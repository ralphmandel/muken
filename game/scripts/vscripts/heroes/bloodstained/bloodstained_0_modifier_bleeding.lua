bloodstained_0_modifier_bleeding = class({})

--------------------------------------------------------------------------------
function bloodstained_0_modifier_bleeding:IsPurgable()
	return true
end

function bloodstained_0_modifier_bleeding:IsHidden()
	return false
end

function bloodstained_0_modifier_bleeding:IsDebuff()
	return true
end

function bloodstained_0_modifier_bleeding:GetTexture()
	return "bleeding"
end

--------------------------------------------------------------------------------

function bloodstained_0_modifier_bleeding:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.delay = true
	self.disable = 0

	self:StartIntervalThink(0.5)
	self:PlayEfxStart()
end

function bloodstained_0_modifier_bleeding:OnRefresh(kv)
	self:PlayEfxStart()
end

--------------------------------------------------------------------------------

function bloodstained_0_modifier_bleeding:OnIntervalThink()
	if self.parent:GetUnitName() == "boss_gorillaz" then return end
	if self.delay == true then
		self.delay = false
		self:StartIntervalThink(0.1)
		return
	end

	if self.parent:IsMoving() then
		local health = self.parent:GetMaxHealth() * 0.01
		local calc = self.parent:GetHealth() - (math.floor(health * 0.5))
		self.parent:ModifyHealth(calc, self.ability, false, 0)
		self.disable = 1
		self:StartBleeding()
	else
		self.disable = 0
		self:StopBleeding()
	end
end

--------------------------------------------------------------------------------

function bloodstained_0_modifier_bleeding:GetEffectName()
	return "particles/econ/items/bloodseeker/bloodseeker_ti7/bloodseeker_ti7_thirst_owner.vpcf"
end

function bloodstained_0_modifier_bleeding:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function bloodstained_0_modifier_bleeding:PlayEfxStart()
	local particle_cast = "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_impact.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
    ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
    ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())

	if IsServer() then
		self.parent:EmitSound("hero_bloodseeker.bloodRite.silence")
		self.parent:EmitSound("Hero_Bloodstained.Bleed")
	end
end

function bloodstained_0_modifier_bleeding:StartBleeding()
	local particle_cast = "particles/units/heroes/hero_beastmaster/beastmaster_wildaxes_hit.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
end

function bloodstained_0_modifier_bleeding:StopBleeding()
end
bloodstained_5_modifier_passive = class({})

function bloodstained_5_modifier_passive:IsHidden() return false end
function bloodstained_5_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained_5_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	if IsServer() then self:OnIntervalThink() end
end

function bloodstained_5_modifier_passive:OnRefresh(kv)
end

function bloodstained_5_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function bloodstained_5_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACKED
	}

	return funcs
end

function bloodstained_5_modifier_passive:OnAttacked(keys)
	if keys.attacker ~= self.parent then return end
	if self.parent:PassivesDisabled() then return end
	if self.parent:GetTeamNumber() == keys.target:GetTeamNumber() then return end

	local heal = keys.original_damage * self:GetLifestealPercent() * 0.01
	self.parent:Heal(heal, self.ability)
	self:PlayEfxLifesteal(keys.target)
end

function bloodstained_5_modifier_passive:OnIntervalThink()
	if IsServer() then
		self:SetStackCount(math.floor(self:GetLifestealPercent()))
		self:StartIntervalThink(FrameTime())
	end
end

-- UTILS -----------------------------------------------------------

function bloodstained_5_modifier_passive:GetLifestealPercent()
	local base_heal = self.ability:GetSpecialValueFor("base_heal")
	local bonus_heal = self.ability:GetSpecialValueFor("bonus_heal")
	local deficit_percent =  1 - (self.parent:GetHealth() / self.parent:GetMaxHealth())

	return (bonus_heal * deficit_percent) + base_heal
end

-- EFFECTS -----------------------------------------------------------

function bloodstained_5_modifier_passive:GetEffectName()
	return "particles/bioshadow/bioshadow_drain.vpcf"
end

function bloodstained_5_modifier_passive:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function bloodstained_5_modifier_passive:PlayEfxLifesteal(target)
	local particle_cast = "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture_nuke.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(effect_cast, 1, target, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)

	local particle_cast2 = "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath.vpcf"
    local effect_cast2 = ParticleManager:CreateParticle(particle_cast2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:ReleaseParticleIndex(effect_cast2)

	if IsServer() then self.parent:EmitSound("Bloodstained.Lifesteal") end
end
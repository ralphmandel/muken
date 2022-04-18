druid_2_modifier_armor = class({})

function druid_2_modifier_armor:IsHidden()
	return false
end

function druid_2_modifier_armor:IsPurgable()
	return true
end

--------------------------------------------------------------------------------

function druid_2_modifier_armor:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then
		self:PlayEfxStart()
		self:StartIntervalThink(0.25)
		self.ability:AddBonus("_2_DEF", self.parent, 10, 0, nil)
	end
end

function druid_2_modifier_armor:OnRefresh(kv)
end

function druid_2_modifier_armor:OnRemoved()
	self.ability:RemoveBonus("_2_DEF", self.parent)
end

--------------------------------------------------------------------------------

function druid_2_modifier_armor:OnIntervalThink()
	self.parent:Heal(self.parent:GetMaxHealth() * 0.005, self.ability)
end

--------------------------------------------------------------------------------

function druid_2_modifier_armor:PlayEfxStart()
	local string = "particles/units/heroes/hero_treant/treant_livingarmor.vpcf"
	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)
	self:AddParticle(effect_cast, false, false, -1, false, false)
end
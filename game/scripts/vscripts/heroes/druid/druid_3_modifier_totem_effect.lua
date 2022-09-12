druid_3_modifier_totem_effect = class({})

function druid_3_modifier_totem_effect:IsHidden()
	return self:GetParent():GetUnitName() == "npc_druid_totem"
end

function druid_3_modifier_totem_effect:IsPurgable()
	return false
end

function druid_3_modifier_totem_effect:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_3_modifier_totem_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.mp_regen = 0

	self.regen = self.ability:GetSpecialValueFor("regen")

	-- UP 3.21
	if self.ability:GetRank(21) then
		self:ApplyINT()
	end

	if IsServer() then self:PlayEfxStart() end
end

function druid_3_modifier_totem_effect:OnRefresh(kv)
end

function druid_3_modifier_totem_effect:OnRemoved()
	self.ability:RemoveBonus("_1_INT", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_3_modifier_totem_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}

	return funcs
end

function druid_3_modifier_totem_effect:GetModifierConstantHealthRegen()
	return self.regen
end

function druid_3_modifier_totem_effect:GetModifierConstantManaRegen()
	return self.mp_regen
end

-- UTILS -----------------------------------------------------------

function druid_3_modifier_totem_effect:ApplyINT()
	self.ability:AddBonus("_1_INT", self.parent, 16, 0, nil)

	if self.parent:IsHero() == false then
		self.mp_regen = 8
	end
end

-- EFFECTS -----------------------------------------------------------

function druid_3_modifier_totem_effect:PlayEfxStart()
	local string = "particles/econ/items/juggernaut/jugg_fortunes_tout/jugg_healling_ward_fortunes_tout_hero_heal.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(particle, 2, self.parent:GetOrigin())
	self:AddParticle(particle, false, false, -1, false, false)
end
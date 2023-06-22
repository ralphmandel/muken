fleaman_4_modifier_strip = class({})

function fleaman_4_modifier_strip:IsHidden() return false end
function fleaman_4_modifier_strip:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function fleaman_4_modifier_strip:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  AddBonus(self.ability, "_2_DEF", self.parent, self.ability:GetSpecialValueFor("def"), 0, nil)

	if IsServer() then self:PlayEfxStart() end
end

function fleaman_4_modifier_strip:OnRefresh(kv)
end

function fleaman_4_modifier_strip:OnRemoved()
  RemoveBonus(self.ability, "_2_DEF", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function fleaman_4_modifier_strip:GetEffectName()
	return "particles/items3_fx/star_emblem.vpcf"
end

function fleaman_4_modifier_strip:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function fleaman_4_modifier_strip:PlayEfxStart()
	local string_1 = "particles/items_fx/abyssal_blink_end.vpcf"
	local particle_1 = ParticleManager:CreateParticle(string_1, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle_1, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(particle_1)

	if IsServer() then self.parent:EmitSound("DOTA_Item.AbyssalBlade.Activate") end
end

function fleaman_4_modifier_strip:PlayEfxEnd()
	local string_1 = "particles/items_fx/abyssal_blink_start.vpcf"
	local particle_1 = ParticleManager:CreateParticle(string_1, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle_1, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(particle_1)

	if IsServer() then self.parent:EmitSound("DOTA_Item.Bloodthorn.Activate") end
end
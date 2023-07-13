fleaman_5_modifier_steal = class({})

function fleaman_5_modifier_steal:IsHidden() return false end
function fleaman_5_modifier_steal:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function fleaman_5_modifier_steal:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	if IsServer() then
    self:SetStackCount(0)
    self:AddStack()
  end
end

function fleaman_5_modifier_steal:OnRefresh(kv)
  if self:GetStackCount() < self.ability:GetSpecialValueFor("max_stack") then
    self:AddStack()
  end
end

function fleaman_5_modifier_steal:OnRemoved()
  local modifier = self.caster:FindModifierByName(self.ability:GetIntrinsicModifierName())
  modifier:SetStackCount(modifier:GetStackCount() - self:GetStackCount())
	RemoveBonus(self.ability, "_1_STR", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function fleaman_5_modifier_steal:OnStackCountChanged(old)
	RemoveBonus(self.ability, "_1_STR", self.parent)
	AddBonus(self.ability, "_1_STR", self.parent, -self:GetStackCount(), 0, nil)
end

-- UTILS -----------------------------------------------------------

function fleaman_5_modifier_steal:AddStack()
  if IsServer() then
    self.caster:FindModifierByName(self.ability:GetIntrinsicModifierName()):IncrementStackCount()
    self:IncrementStackCount()
    self:PlayEfxHit(self.parent)
  end
end

-- EFFECTS -----------------------------------------------------------

function fleaman_5_modifier_steal:PlayEfxHit(target)
	local particle_cast = "particles/econ/items/slark/slark_ti6_blade/slark_ti6_blade_essence_shift.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(effect_cast, 1, self.caster:GetOrigin() + Vector(0, 0, 64))
  ParticleManager:SetParticleControlTransformForward(effect_cast, 3, self.parent:GetOrigin(), self.caster:GetLeftVector())
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then target:EmitSound("Hero_BountyHunter.Jinada") end
end
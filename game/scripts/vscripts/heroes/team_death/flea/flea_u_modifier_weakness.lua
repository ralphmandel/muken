flea_u_modifier_weakness = class({})

function flea_u_modifier_weakness:IsHidden() return false end
function flea_u_modifier_weakness:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_u_modifier_weakness:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.stack = 0

  self.caster:FindModifierByName(self.ability:GetIntrinsicModifierName()):IncrementStackCount()

	if IsServer() then
    self:SetStackCount(1)
    self:PlayEfxHit(self.parent)
  end
end

function flea_u_modifier_weakness:OnRefresh(kv)
  self.caster:FindModifierByName(self.ability:GetIntrinsicModifierName()):IncrementStackCount()

	if IsServer() then
    self:IncrementStackCount()
    self:PlayEfxHit(self.parent)
  end
end

function flea_u_modifier_weakness:OnRemoved()
  local modifier = self.caster:FindModifierByName(self.ability:GetIntrinsicModifierName())
  modifier:SetStackCount(modifier:GetStackCount() - self:GetStackCount())
	RemoveBonus(self.ability, "_1_STR", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_u_modifier_weakness:OnStackCountChanged(old)
	RemoveBonus(self.ability, "_1_STR", self.parent)
	AddBonus(self.ability, "_1_STR", self.parent, -self:GetStackCount(), 0, nil)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function flea_u_modifier_weakness:PlayEfxHit(target)
	local particle_cast = "particles/econ/items/slark/slark_ti6_blade/slark_ti6_blade_essence_shift.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(effect_cast, 1, self.caster:GetOrigin() + Vector(0, 0, 64))
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then target:EmitSound("Hero_BountyHunter.Jinada") end
end
icebreaker_3_modifier_skin = class({})

function icebreaker_3_modifier_skin:IsHidden() return false end
function icebreaker_3_modifier_skin:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_3_modifier_skin:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	if IsServer() then
		self:SetStackCount(self.ability:GetSpecialValueFor("layers"))
		self:PlayEfxStart()
	end
end

function icebreaker_3_modifier_skin:OnRefresh(kv)
	if IsServer() then
		self:SetStackCount(self.ability:GetSpecialValueFor("layers"))
		self:PlayEfxStart()
	end
end

function icebreaker_3_modifier_skin:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_3_modifier_skin:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK
	}

	return funcs
end

function icebreaker_3_modifier_skin:GetModifierPhysical_ConstantBlock(keys)
  if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then return end
	if keys.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then return end

  AddModifier(keys.attacker, self.caster, self.ability, "icebreaker__modifier_hypo", {
    stack = self.ability:GetSpecialValueFor("hypo_stack")
  }, false)
  
	if IsServer() then
    self:DecrementStackCount()
    self:PlayEfxBlock()
  end

	if self:GetStackCount() < 1 then
		self:Destroy()
	end

  return keys.damage
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function icebreaker_3_modifier_skin:PlayEfxStart()
  local particle = "particles/units/heroes/hero_lich/lich_ice_age.vpcf"
	local efx = ParticleManager:CreateParticle(particle, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(efx, 1, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(efx, 2, Vector(150, 150, 150))
	self:AddParticle(efx, false, false, -1, false, false)

  if IsServer() then self.parent:EmitSound("Hero_Lich.IceAge") end
end

function icebreaker_3_modifier_skin:PlayEfxBlock()
  if IsServer() then self.parent:EmitSound("Hero_Lich.IceAge.Tick") end
  if IsServer() then self.parent:EmitSound("Hero_Lich.IceAge.Damage") end
end
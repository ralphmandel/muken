bald_3_modifier_inner = class({})

function bald_3_modifier_inner:IsHidden() return false end
function bald_3_modifier_inner:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_3_modifier_inner:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.spell_immunity = self:GetAbility():GetSpecialValueFor("special_spell_immunity")
  local modifier = self.parent:FindModifierByNameAndCaster(self.ability:GetIntrinsicModifierName(), self.caster)

	if IsServer() then
    modifier:SetStackCount(kv.stack)
		self:PlayEfxStart()
	end
end

function bald_3_modifier_inner:OnRefresh(kv)
	if IsServer() then self:PlayEfxStart() end
end

function bald_3_modifier_inner:OnRemoved()
  local modifier = self.parent:FindModifierByNameAndCaster(self.ability:GetIntrinsicModifierName(), self.caster)
  if IsServer() then modifier:SetStackCount(0) end
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_3_modifier_inner:CheckState()
	local state = {}

	if self.spell_immunity == 1 then
		table.insert(state, MODIFIER_STATE_MAGIC_IMMUNE, true)
	end

	return state
end


-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bald_3_modifier_inner:PlayEfxStart()
	local string = "particles/bald/bald_inner/bald_inner_owner.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(particle, 10, Vector(self.parent:GetModelScale() * 100, 0, 0))
	ParticleManager:SetParticleControlEnt(particle, 2, self.parent, PATTACH_POINT_FOLLOW, "attach_weapon", Vector(0,0,0), true)
	self:AddParticle(particle, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_EarthSpirit.Magnetize.Cast") end
end
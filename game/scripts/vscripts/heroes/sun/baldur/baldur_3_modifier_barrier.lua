baldur_3_modifier_barrier = class({})

function baldur_3_modifier_barrier:IsHidden() return true end
function baldur_3_modifier_barrier:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function baldur_3_modifier_barrier:OnCreated(kv)
  if not IsServer() then return end

  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.barrier = self.ability:GetSpecialValueFor("barrier_min") + (self.ability:GetSpecialValueFor("barrier_stack") * kv.stack)
  self:SetHasCustomTransmitterData(true)
  
  self.ability:SetActivated(false)
  self.ability:EndCooldown()

	if IsServer() then
		self:PlayEfxStart()
    self:StartIntervalThink(0.1)
	end
end

function baldur_3_modifier_barrier:OnRefresh(kv)
	if IsServer() then self:PlayEfxStart() end
end

function baldur_3_modifier_barrier:OnRemoved()
  self.ability:SetActivated(true)
  self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
end

function baldur_3_modifier_barrier:AddCustomTransmitterData()
  return {
    barrier = self.barrier,
  }
end

function baldur_3_modifier_barrier:HandleCustomTransmitterData(data)
  self.barrier = data.barrier
end

-- API FUNCTIONS -----------------------------------------------------------

function baldur_3_modifier_barrier:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT
	}
	
	return funcs
end

function baldur_3_modifier_barrier:GetModifierIncomingDamageConstant(keys)  
  if not IsServer() then return self.barrier end

  local damage = keys.damage
  self.barrier = self.barrier - damage

  if self.barrier <= 0 then
    damage = damage + self.barrier
    self:Destroy()
  end

  return -damage
end

function baldur_3_modifier_barrier:OnIntervalThink()
  local interval = 0.1

  self.barrier = self.barrier - (self.ability:GetSpecialValueFor("barrier_loss") * interval)
  if self.barrier <= 0 then self:Destroy() return end

  self:SendBuffRefreshToClients()
  self:StartIntervalThink(interval)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function baldur_3_modifier_barrier:PlayEfxStart()
	local string = "particles/bald/bald_inner/bald_inner_owner.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(particle, 10, Vector(self.parent:GetModelScale() * 100, 0, 0))
	ParticleManager:SetParticleControlEnt(particle, 2, self.parent, PATTACH_POINT_FOLLOW, "attach_weapon", Vector(0,0,0), true)
	self:AddParticle(particle, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_EarthSpirit.Magnetize.Cast") end
end
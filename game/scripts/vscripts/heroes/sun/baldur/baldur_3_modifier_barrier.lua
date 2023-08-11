baldur_3_modifier_barrier = class({})

function baldur_3_modifier_barrier:IsHidden() return false end
function baldur_3_modifier_barrier:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function baldur_3_modifier_barrier:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  
  self.ability:SetActivated(false)
  self.ability:EndCooldown()

	if IsServer() then
		self:PlayEfxStart()
	end
end

function baldur_3_modifier_barrier:OnRefresh(kv)
	if IsServer() then self:PlayEfxStart() end
end

function baldur_3_modifier_barrier:OnRemoved()
  self.ability:SetActivated(true)
  self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
end

-- API FUNCTIONS -----------------------------------------------------------

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
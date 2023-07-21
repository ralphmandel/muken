paladin_1_modifier_link = class({})

function paladin_1_modifier_link:IsHidden() return false end
function paladin_1_modifier_link:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function paladin_1_modifier_link:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then self:PlayEfxStart() end
end

function paladin_1_modifier_link:OnRefresh(kv)
end

function paladin_1_modifier_link:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function paladin_1_modifier_link:PlayEfxStart()
  local string = "particles/paladin/link/paladin_link.vpcf"
  self.pfx = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent, self.caster)
  ParticleManager:SetParticleControlEnt(self.pfx, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true)
  ParticleManager:SetParticleControlEnt(self.pfx, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
  self:AddParticle(self.pfx, false, false, -1, false, false)

  if IsServer() then self.parent:EmitSound("Hero_Wisp.Tether.Target") end
end
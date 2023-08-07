templar_5_modifier_passive = class({})

function templar_5_modifier_passive:IsHidden() return true end
function templar_5_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function templar_5_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.efx_pre = {}
end

function templar_5_modifier_passive:OnRefresh(kv)
end

function templar_5_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function templar_5_modifier_passive:DeclareFunctions()
	local funcs = {
    MODIFIER_EVENT_ON_DEATH,
    MODIFIER_EVENT_ON_RESPAWN
	}

	return funcs
end

function templar_5_modifier_passive:OnDeath(keys)
  if keys.unit:GetTeamNumber() ~= self.caster:GetTeamNumber() then return end
  if keys.unit:IsHero() == false or keys.unit:IsIllusion() then return end

  if IsServer() then self:PlayEfxPre(keys.unit, keys.unit:GetOrigin()) end
end

function templar_5_modifier_passive:OnRespawn(keys)
  if keys.unit:GetTeamNumber() ~= self.caster:GetTeamNumber() then return end
  if keys.unit:IsHero() == false then return end

  if IsServer() then self:StopEfx(keys.unit) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function templar_5_modifier_passive:StopEfx(unit)
  local caster = self:GetCaster()

  if self.efx_pre[unit:GetUnitName()] then
    ParticleManager:DestroyParticle(self.efx_pre[unit:GetUnitName()].pfx, true)
    ParticleManager:ReleaseParticleIndex(self.efx_pre[unit:GetUnitName()].pfx)
    RemoveFOWViewer(self.caster:GetTeamNumber(), self.efx_pre[unit:GetUnitName()].fow)
    self.efx_pre[unit:GetUnitName()] = nil
  end
end

function templar_5_modifier_passive:PlayEfxPre(unit, loc)
  self:StopEfx(unit)

  self.efx_pre[unit:GetUnitName()] = {}
  self.efx_pre[unit:GetUnitName()].fow = AddFOWViewer(self.caster:GetTeamNumber(), loc, 200, 999, true)

  local caster = self:GetCaster()
  local particle_pre = "particles/econ/events/ti10/aegis_lvl_1000_ambient_ti10.vpcf"
  self.efx_pre[unit:GetUnitName()].pfx = ParticleManager:CreateParticle(particle_pre, PATTACH_WORLDORIGIN, nil)
  ParticleManager:SetParticleControl(self.efx_pre[unit:GetUnitName()].pfx, 0, loc)
end
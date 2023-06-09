lawbreaker_2_modifier_reload = class({})

function lawbreaker_2_modifier_reload:IsHidden() return true end
function lawbreaker_2_modifier_reload:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function lawbreaker_2_modifier_reload:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.step = 1
  
  if IsServer() then
    self:StartIntervalThink(self.ability:GetSpecialValueFor("fast_reload_delay"))
  end
end

function lawbreaker_2_modifier_reload:OnRefresh(kv)
end

function lawbreaker_2_modifier_reload:OnRemoved()
  self.parent:FadeGesture(ACT_DOTA_TRANSITION)
  self.ability.reloading = false
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

function lawbreaker_2_modifier_reload:OnIntervalThink()
  if self.step == 1 then self.ability.reloading = true end  

  if IsServer() then
    if self.step == 1 then
      self.step = 2
      self:StartIntervalThink(0.5)
    else
      self:PlayEfxStart()
      self:StartIntervalThink(-1)
    end
  end
end

-- EFFECTS -----------------------------------------------------------

function lawbreaker_2_modifier_reload:PlayEfxStart()
	local string = "particles/econ/items/windrunner/windranger_arcana/windranger_arcana_ambient.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
	self:AddParticle(particle, false, false, -1, false, false)

	--if IsServer() then self.parent:EmitSound("") end
end
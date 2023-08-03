dasdingo_2_modifier_aura = class({})

function dasdingo_2_modifier_aura:IsHidden() return false end
function dasdingo_2_modifier_aura:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function dasdingo_2_modifier_aura:IsAura() return true end
function dasdingo_2_modifier_aura:GetModifierAura() return "dasdingo_2_modifier_aura_effect" end
function dasdingo_2_modifier_aura:GetAuraRadius() return self:GetAbility():GetAOERadius() end
function dasdingo_2_modifier_aura:GetAuraSearchTeam() return DOTA_UNIT_TARGET_TEAM_BOTH end
function dasdingo_2_modifier_aura:GetAuraSearchType() return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function dasdingo_2_modifier_aura:GetAuraSearchFlags() return DOTA_UNIT_TARGET_FLAG_NONE end
function dasdingo_2_modifier_aura:GetAuraEntityReject(hEntity)
  if self:GetCaster():GetTeamNumber() == hEntity:GetTeamNumber() then
    return (hEntity:IsConsideredHero() == false)
  else
    return (hEntity:IsInvisible())
  end
end

-- CONSTRUCTORS -----------------------------------------------------------

function dasdingo_2_modifier_aura:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  self.radius = self.ability:GetAOERadius()
  self.tree = EntIndexToHScript(kv.tree_index)

  if IsServer() then
    self:PlayEfxStart()
    self:StartIntervalThink(0.5)
  end
end

function dasdingo_2_modifier_aura:OnRefresh(kv)
end

function dasdingo_2_modifier_aura:OnRemoved()
  if self.fow then RemoveFOWViewer(self.caster:GetTeamNumber(), self.fow) end
end

-- API FUNCTIONS -----------------------------------------------------------

function dasdingo_2_modifier_aura:OnIntervalThink()
  if self.tree then
    if IsValidEntity(self.tree) then
      if self.tree:IsStanding() then
        if IsServer() then self:StartIntervalThink(0.1) end
        return
      end
    end
  end

  self:Destroy()
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function dasdingo_2_modifier_aura:PlayEfxStart()
  self.fow = AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), self.radius, self:GetDuration(), false)

	local string = "particles/units/heroes/hero_treant/treant_eyesintheforest.vpcf"
	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetAbsOrigin())
  ParticleManager:SetParticleControl(effect_cast, 1, Vector(self.radius, self.radius, self.radius))
	self:AddParticle(effect_cast, false, false, -1, false, false)
    
	if IsServer() then self.parent:EmitSound("Hero_Treant.Eyes.Cast") end
end
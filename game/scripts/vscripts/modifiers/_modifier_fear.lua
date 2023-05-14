_modifier_fear = class ({})

function _modifier_fear:IsHidden() return false end
function _modifier_fear:IsPurgable() return true end
function _modifier_fear:GetTexture() return "_modifier_fear" end
function _modifier_fear:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

-- CONSTRUCTORS -----------------------------------------------------------

function _modifier_fear:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.target = self.parent:GetAggroTarget()
  self.special = kv.special or 0

  AddStatusEfx(self.ability, "_modifier_fear_status_efx", self.caster, self.parent)
  self.parent:AddNewModifier(self.caster, self.ability, "_modifier_percent_movespeed_debuff", {percent = 30})

	if IsServer() then
    if self.special == 1 then
      self:PlayEfxStart("particles/econ/items/dark_willow/dark_willow_immortal_2021/dw_2021_willow_wisp_spell_debuff.vpcf", PATTACH_OVERHEAD_FOLLOW)
      self:PlayEfxStart("particles/genuine/genuine_fear.vpcf", PATTACH_ABSORIGIN_FOLLOW)
      self.parent:EmitSound("Hero_DarkWillow.Fear.Target")
      self.parent:StopSound("Genuine.Fear.Loop")
      self.parent:EmitSound("Genuine.Fear.Loop")
    else
      self:PlayEfxStart("particles/units/heroes/hero_lone_druid/lone_druid_savage_roar_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW)
    end

    self:OnIntervalThink()
  end
end

function _modifier_fear:OnRefresh(kv)
end

function _modifier_fear:OnRemoved(kv)
	if self.target then
		self.parent:MoveToTargetToAttack(self.target)
	else
		self.parent:Stop()
	end

  RemoveStatusEfx(self.ability, "_modifier_fear_status_efx", self.caster, self.parent)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_percent_movespeed_debuff", self.ability)

  if self.special == 1 then
    if IsServer() then self.parent:StopSound("Genuine.Fear.Loop") end
  end
end

-- API FUNCTIONS -----------------------------------------------------------

function _modifier_fear:CheckState()
	local state = {
    [MODIFIER_STATE_FEARED] = true,
    [MODIFIER_STATE_COMMAND_RESTRICTED] = true
  }

	return state
end

-- UTILS -----------------------------------------------------------

function _modifier_fear:OnIntervalThink()
	local direction = (self.caster:GetAbsOrigin() - self.parent:GetAbsOrigin()):Normalized() * -250
	local pos = self.parent:GetOrigin() + direction
	self.parent:MoveToPosition(pos)

	if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- EFFECTS -----------------------------------------------------------

function _modifier_fear:GetStatusEffectName()
  return "particles/status_fx/status_effect_lone_druid_savage_roar.vpcf"
end

function _modifier_fear:StatusEffectPriority()
  return MODIFIER_PRIORITY_HIGH
end

function _modifier_fear:PlayEfxStart(string, attach)
	local pfx = ParticleManager:CreateParticle(string, attach, self.parent)	
	self:AddParticle(pfx, false, false, -1, false, false)
end
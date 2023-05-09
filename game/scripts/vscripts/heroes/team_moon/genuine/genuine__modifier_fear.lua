genuine__modifier_fear = class ({})

function genuine__modifier_fear:IsHidden() return false end
function genuine__modifier_fear:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine__modifier_fear:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.target = self.parent:GetAggroTarget()

  AddStatusEfx(self.ability, "genuine__modifier_fear_status_efx", self.caster, self.parent)

  self.parent:AddNewModifier(self.caster, self.ability, "_modifier_percent_movespeed_debuff", {percent = 25})

	if IsServer() then
		self:PlayEfxStart()
		self:OnIntervalThink()
		self.parent:EmitSound("Hero_DarkWillow.Fear.Target")
		self.parent:StopSound("Genuine.Fear.Loop")
		self.parent:EmitSound("Genuine.Fear.Loop")
	end
end

function genuine__modifier_fear:OnRefresh(kv)
  if IsServer() then
		self.parent:EmitSound("Hero_DarkWillow.Fear.Target")
		self.parent:StopSound("Genuine.Fear.Loop")
		self.parent:EmitSound("Genuine.Fear.Loop")
	end
end

function genuine__modifier_fear:OnRemoved(kv)
	if self.target then
		self.parent:MoveToTargetToAttack(self.target)
	else
		self.parent:Stop()
	end

  RemoveStatusEfx(self.ability, "genuine__modifier_fear_status_efx", self.caster, self.parent)

  if IsServer() then self.parent:StopSound("Genuine.Fear.Loop") end
end

function genuine__modifier_fear:OnDestroy()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_percent_movespeed_debuff", self.ability)
  if IsServer() then self.parent:StopSound("Genuine.Fear.Loop") end
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine__modifier_fear:CheckState()
	local state = {
    [MODIFIER_STATE_FEARED] = true,
    [MODIFIER_STATE_COMMAND_RESTRICTED] = true
  }

	return state
end

-- UTILS -----------------------------------------------------------

function genuine__modifier_fear:OnIntervalThink()
	local direction = (self.caster:GetAbsOrigin() - self.parent:GetAbsOrigin()):Normalized() * -250
	local pos = self.parent:GetOrigin() + direction
	self.parent:MoveToPosition(pos)

	if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- EFFECTS -----------------------------------------------------------

function genuine__modifier_fear:GetStatusEffectName()
 	return "particles/status_fx/status_effect_lone_druid_savage_roar.vpcf"
end

function genuine__modifier_fear:StatusEffectPriority()
 	return MODIFIER_PRIORITY_HIGH
end

function genuine__modifier_fear:PlayEfxStart()
	local particle_cast1 = "particles/econ/items/dark_willow/dark_willow_immortal_2021/dw_2021_willow_wisp_spell_debuff.vpcf"
	local particle_cast2 = "particles/genuine/genuine_fear.vpcf"
	local effect_cast1 = ParticleManager:CreateParticle(particle_cast1, PATTACH_OVERHEAD_FOLLOW, self.parent)
	local effect_cast2 = ParticleManager:CreateParticle(particle_cast2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	
	self:AddParticle(effect_cast1, false, false, -1, false, false)
	self:AddParticle(effect_cast2, false, false, -1, false, false)
end
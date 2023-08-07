icebreaker_1_modifier_passive = class({})

function icebreaker_1_modifier_passive:IsHidden() return true end
function icebreaker_1_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_1_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.cast = false

  if IsServer() then self:PlayEfxAmbient() end
end

function icebreaker_1_modifier_passive:OnRefresh(kv)
end

function icebreaker_1_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_1_modifier_passive:DeclareFunctions()
	local funcs = {
    MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}

	return funcs
end

function icebreaker_1_modifier_passive:OnTakeDamage(keys)  
  if keys.attacker == nil then return end
  if keys.attacker:IsBaseNPC() == false then return end
  if keys.attacker ~= self.parent then return end

  -- CLEAVE APPLY
  -- if keys.damage_flags == 1024 then
  --   AddModifier(keys.unit, self.ability, "icebreaker__modifier_hypo", {stack = 1}, false)
  -- end
end

function icebreaker_1_modifier_passive:OnOrder(keys)
	if keys.unit ~= self.parent then return end

	if keys.ability then
		if keys.ability == self:GetAbility() and keys.order_type == 6 then
			self.cast = true
			return
		end
	end
	
	self.cast = false
end

function icebreaker_1_modifier_passive:GetModifierProcAttack_Feedback(keys)
  if self:ShouldLaunch(keys.target) == false then return end

  self.ability:UseResources(true, false, false, true)

  AddModifier(keys.target, self.ability, "icebreaker__modifier_hypo", {stack = self.ability:GetSpecialValueFor("stack")}, false)
end

-- UTILS -----------------------------------------------------------

function icebreaker_1_modifier_passive:ShouldLaunch(target)
  if self.parent:IsIllusion() then return false end

	if self.ability:GetAutoCastState() then
    local nResult = UnitFilter(
      target, self.ability:GetAbilityTargetTeam(),
      self.ability:GetAbilityTargetType(),
      self.ability:GetAbilityTargetFlags(),
      self.caster:GetTeamNumber()
    )

    self.cast = (nResult == UF_SUCCESS)
  end

	if self.cast == true and self.parent:IsSilenced() == false and self.ability:IsFullyCastable()
  and RandomFloat(0, 100) < self.ability:GetSpecialValueFor("chance") then
    return true
  end

	return false
end

-- EFFECTS -----------------------------------------------------------

function icebreaker_1_modifier_passive:PlayEfxAmbient()
	local particle_cast = "particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch_buff.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin() )
	self:AddParticle(effect_cast, false, false, -1, false, false)
end
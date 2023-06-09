lawbreaker_2_modifier_passive = class({})

function lawbreaker_2_modifier_passive:IsHidden() return true end
function lawbreaker_2_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function lawbreaker_2_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then
    self:PlayEfxStart()
    self:SetStackCount(0)
    self.ability:EnableShotRefresh(true)
  end
end

function lawbreaker_2_modifier_passive:OnRefresh(kv)
end

function lawbreaker_2_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function lawbreaker_2_modifier_passive:DeclareFunctions()
	local funcs = {
    MODIFIER_EVENT_ON_STATE_CHANGED,
		MODIFIER_EVENT_ON_ATTACK_START,
    MODIFIER_EVENT_ON_UNIT_MOVED
	}

	return funcs
end

function lawbreaker_2_modifier_passive:OnStateChanged(keys)
	if keys.unit ~= self.parent then return end
	if self.parent:IsStunned() or self.parent:IsHexed() or self.parent:IsFrozen() then
		self.parent:RemoveModifierByName("lawbreaker_2_modifier_reload")
	end
end

function lawbreaker_2_modifier_passive:OnAttackStart(keys)
  if keys.attacker == self.parent then self.parent:RemoveModifierByName("lawbreaker_2_modifier_reload") end
end

function lawbreaker_2_modifier_passive:OnUnitMoved(keys)
  if keys.unit == self.parent then self.parent:RemoveModifierByName("lawbreaker_2_modifier_reload") end
end 

function lawbreaker_2_modifier_passive:OnIntervalThink()
  if IsServer() then
    local fast_reload = self.ability:GetSpecialValueFor("fast_reload")

    if self.ability.reloading == true then
      Timers:CreateTimer(fast_reload / 2, function()
        self.parent:FadeGesture(ACT_DOTA_TRANSITION)
        if self.ability.reloading == true then
          self.parent:AddActivityModifier("aggressive")
          self.parent:StartGestureWithPlaybackRate(ACT_DOTA_TRANSITION, 0.9 / fast_reload)
        end
      end)
      Timers:CreateTimer(fast_reload - 0.05, function()
        if self.ability.reloading == true then
          self.parent:EmitSound("Hero_Muerta.PreAttack")
        end
      end)
    else
      Timers:CreateTimer(fast_reload / 2, function()
        self.parent:FadeGesture(ACT_DOTA_TRANSITION)
      end)
    end
    
    self:IncrementStackCount()
  end
end

function lawbreaker_2_modifier_passive:OnStackCountChanged(old)
  self.ability:SetActivated(self:GetStackCount() >= self.ability:GetSpecialValueFor("min_shots"))
  if self:GetStackCount() == 0 then self.parent:RemoveModifierByName("lawbreaker_2_modifier_combo") end

  self:CheckShots()
end

-- UTILS -----------------------------------------------------------

function lawbreaker_2_modifier_passive:CheckShots()
  if self:GetStackCount() == self.ability:GetSpecialValueFor("max_shots") then
    self.ability:EnableShotRefresh(false)
  else
    self.ability:EnableShotRefresh(true)
  end

  if self.particle then
    if IsServer() then self:PlayEfxStart() end
    for bar = 1, self.ability:GetSpecialValueFor("max_shots") do
      local value = 1
      if bar > self:GetStackCount() then value = 0 end
      ParticleManager:SetParticleControl(self.particle, bar + 1, Vector(value, 0, 0))
    end
  end

  self.ability:SetCurrentAbilityCharges(self:GetStackCount())
end

-- EFFECTS -----------------------------------------------------------

function lawbreaker_2_modifier_passive:PlayEfxStart()
  if self.particle then ParticleManager:DestroyParticle(self.particle, true) end
  local string = "particles/lawbreaker/shots_count/lawbreaker_shots_overhead.vpcf"
  self.particle = ParticleManager:CreateParticle(string, PATTACH_OVERHEAD_FOLLOW, self.parent)
  ParticleManager:SetParticleControl(self.particle, 1, Vector(self.ability:GetSpecialValueFor("max_shots"), 0, 0))
  self:AddParticle(self.particle, false, false, -1, false, false)
end
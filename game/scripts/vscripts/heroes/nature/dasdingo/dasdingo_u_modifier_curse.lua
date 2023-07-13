dasdingo_u_modifier_curse = class({})

function dasdingo_u_modifier_curse:IsHidden() return false end
function dasdingo_u_modifier_curse:IsPurgable() return false end

-----------------------------------------------------------

function dasdingo_u_modifier_curse:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	self.interval = self.ability:GetSpecialValueFor("interval")
	self.health = self.parent:GetHealth()

  ApplyDamage({
    attacker = self.caster, victim = self.parent, ability = self.ability,
    damage = self.ability:GetSpecialValueFor("damage_init"),
    damage_type = self.ability:GetAbilityDamageType()
  })
	
	if IsServer() then
		self:PlayEfxStart(true)
    self:SetStackCount(self.ability:GetSpecialValueFor("max_tick"))
		self:StartIntervalThink(self.interval)
	end
end

function dasdingo_u_modifier_curse:OnRefresh(kv)
	self.interval = self.ability:GetSpecialValueFor("interval")
	self.health = self.parent:GetHealth()

	if IsServer() then
		self:SetStackCount(self.ability:GetSpecialValueFor("max_tick"))
		self:PlayEfxStart(true)
		self:StartIntervalThink(self.interval)
	end
end

function dasdingo_u_modifier_curse:OnRemoved(kv)
	if IsServer() then self.parent:StopSound("Dasdingo.Maledict.Loop") end
end

------------------------------------------------------------

function dasdingo_u_modifier_curse:OnIntervalThink()
  if self:GetStackCount() == 0 then self:Destroy() return end
	local hp_lost = self.health - self.parent:GetHealth()
  local interval = self.interval

	if hp_lost < 0 then
		self.health = self.parent:GetHealth()
	else
		ApplyDamage({
      attacker = self.caster, victim = self.parent, ability = self.ability,
      damage = hp_lost * self.ability:GetSpecialValueFor("hp_damage") * 0.01,
      damage_type = self.ability:GetAbilityDamageType()
    })
	end

  if IsServer() then
		self:PlayEfxStart(false)
    self:DecrementStackCount()    
    if self:GetStackCount() == 0 then interval = 0.1 end
    self:StartIntervalThink(interval)
	end
end

-----------------------------------------------------------

function dasdingo_u_modifier_curse:PlayEfxStart(bStart)
	if bStart then
		if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, true) end

		local string = "particles/econ/items/witch_doctor/wd_ti8_immortal_head/wd_ti8_immortal_maledict.vpcf"
		self.effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
		self:AddParticle(self.effect_cast, false, false, -1, false, false)

		if IsServer() then
			self.parent:EmitSound("Hero_WitchDoctor.Maledict_Cast")
			if self.parent:GetPlayerOwnerID() and self.parent:IsAlive() then
				EmitSoundOnEntityForPlayer("Dasdingo.Maledict.Loop", self.parent, self.parent:GetPlayerOwnerID())
			end
		end
	else
		if IsServer() then self.parent:EmitSound("Hero_WitchDoctor.Maledict_Tick") end
	end

  if self.effect_cast then ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(self.interval, 0, 0)) end
end
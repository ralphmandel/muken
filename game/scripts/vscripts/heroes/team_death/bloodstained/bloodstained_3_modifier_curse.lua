bloodstained_3_modifier_curse = class({})

function bloodstained_3_modifier_curse:IsHidden() return false end
function bloodstained_3_modifier_curse:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained_3_modifier_curse:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	if self.parent ~= self.caster then
		self.ability:SetActivated(false)
		self.ability:EndCooldown()

    AddModifier(self.caster, self.caster, self.ability, self:GetName(), {}, false)
    AddModifier(self.parent, self.caster, self.ability, "_modifier_movespeed_debuff", {
      percent = self.ability:GetSpecialValueFor("slow")
    }, false)
	end

	if IsServer() then
		self:PlayEfxStart()
		self:OnIntervalThink()
	end
end

function bloodstained_3_modifier_curse:OnRefresh(kv)
end

function bloodstained_3_modifier_curse:OnRemoved()
	if self.ability.target then self.ability.target:RemoveModifierByNameAndCaster(self:GetName(), self.caster) end
	self.caster:RemoveModifierByNameAndCaster(self:GetName(), self.caster)
	self.ability.target = nil

	if self.parent ~= self.caster then
		self.ability:SetActivated(true)

    if self.parent:IsAlive() == false then
      self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
    end
	end

  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_debuff", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

function bloodstained_3_modifier_curse:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function bloodstained_3_modifier_curse:OnTakeDamage(keys)
	if keys.unit ~= self.parent and keys.unit ~= self.caster then return end
	if self.parent == self.caster then return end

	local target = self.caster
	if keys.unit == self.caster then target = self.parent end

	local shared_damage = self.ability:GetSpecialValueFor("shared_damage")
	local total_damage = (keys.damage * shared_damage * 0.01)
	local iDesiredHealthValue = target:GetHealth() - total_damage
	target:ModifyHealth(iDesiredHealthValue, self.ability, true, 0)

	if target == self.caster then
		local mod = self.caster:FindModifierByNameAndCaster("bloodstained_1_modifier_rage", self.caster)
		if mod then mod:FilterDamage(total_damage) end
	end
end

function bloodstained_3_modifier_curse:OnIntervalThink()
	if IsServer() then
		if self.parent ~= self.caster then
			AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), 75, 0.2, true)
			local current_distance = CalcDistanceBetweenEntityOBB(self.caster, self.parent)
			local max_range = self.ability:GetSpecialValueFor("max_range")
			if current_distance > max_range then
        self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
        self:Destroy() return
      end
		end

		self:StartIntervalThink(0.1)
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bloodstained_3_modifier_curse:PlayEfxStart()
	local particle_cast = "particles/units/heroes/hero_queenofpain/queen_shadow_strike_body.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)

	if self.caster == self.parent then return end

	local particle_cast_2 = "particles/econ/items/grimstroke/gs_fall20_immortal/gs_fall20_immortal_soulbind.vpcf"
	local effect_cast_2 = ParticleManager:CreateParticle(particle_cast_2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(effect_cast_2, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(effect_cast_2, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	self:AddParticle(effect_cast_2, false, false, -1, false, false)
end
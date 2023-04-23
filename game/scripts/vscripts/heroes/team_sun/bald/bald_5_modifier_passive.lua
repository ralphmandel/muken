bald_5_modifier_passive = class({})

function bald_5_modifier_passive:IsHidden() return false end
function bald_5_modifier_passive:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_5_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
	self.total_amount = 0
end

function bald_5_modifier_passive:OnRefresh(kv)
end

function bald_5_modifier_passive:OnRemoved()
	if IsServer() then self.parent:StopSound("Hero_Bristleback.PistonProngs.IdleLoop") end
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_5_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
    MODIFIER_EVENT_ON_MODIFIER_ADDED
	}

	return funcs
end

function bald_5_modifier_passive:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end
	if self.parent:PassivesDisabled() then return end
  if self.ability:IsCooldownReady() == false then return end

	self.total_amount = self.total_amount + keys.damage
	if self.total_amount > self.ability:GetSpecialValueFor("amount") then
    self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
		self:ReleaseSpikes()
    self.total_amount = 0
	end
end

function bald_5_modifier_passive:OnModifierAdded(keys)
	if keys.unit ~= self.parent then return end
  if keys.added_buff:GetName() ~= "bald_3_modifier_inner" then return end
  if self.parent:FindAbilityByName(keys.added_buff:GetAbility():GetAbilityName()) == nil then return end

  local call_duration = keys.added_buff:GetDuration() * self.ability:GetSpecialValueFor("special_call_duration") * 0.01
	local spike_radius = self.ability:GetSpecialValueFor("spike_radius")

  if call_duration > 0 then
    self:PlayEfxCall(spike_radius)

    local enemies = FindUnitsInRadius(
      self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, spike_radius,
      DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
      DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false
    )

    for _,enemy in pairs(enemies) do
      enemy:AddNewModifier(self.caster, self.ability, "bald_5_modifier_call", {duration = call_duration})
    end
  end
end

function bald_5_modifier_passive:OnIntervalThink()
	if IsServer() then
    self.parent:StopSound("Hero_Bristleback.PistonProngs.IdleLoop")
    self:StartIntervalThink(-1)
  end
end

-- UTILS -----------------------------------------------------------

function bald_5_modifier_passive:ReleaseSpikes()
	local spike_radius = self.ability:GetSpecialValueFor("spike_radius")
	self:PlayEfxQuill(spike_radius)

	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, spike_radius,
		self.ability:GetAbilityTargetTeam(), self.ability:GetAbilityTargetType(),
		self.ability:GetAbilityTargetFlags(), 0, false
	)

	for _,enemy in pairs(enemies) do
		self:PlayEfxQuillImpact(enemy)
		local knockback = self.ability:GetSpecialValueFor("knockback")
		local knock_duration = CalcStatus(knockback * 0.003, self.caster, enemy)
		local knock_distance = CalcStatus(knockback, self.caster, enemy)

    local goo_duration = self.ability:GetSpecialValueFor("special_goo_duration")
    if goo_duration > 0 then
      enemy:AddNewModifier(self.caster, self.ability, "bald_5_modifier_goo", {
        duration = CalcStatus(goo_duration, self.caster, enemy)
      })
    end
	
		enemy:AddNewModifier(self.caster, nil, "modifier_knockback", {
			duration = knock_duration,
			knockback_duration =  knock_duration,
			knockback_distance = knock_distance,
			center_x = self.parent:GetAbsOrigin().x + 1,
			center_y = self.parent:GetAbsOrigin().y + 1,
			center_z = self.parent:GetAbsOrigin().z,
			knockback_height = 0,
		})

		ApplyDamage({
			damage = self.ability:GetSpecialValueFor("spike_damage"),
			attacker = self.caster,
			victim = enemy,
			damage_type = self.ability:GetAbilityDamageType(),
			ability = self.ability
		})
	end
end

-- EFFECTS -----------------------------------------------------------

function bald_5_modifier_passive:PlayEfxQuill(radius)
	local particle_cast = "particles/bald/bald_quill/bald_quill_spray.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 10, Vector(radius * 1.5, 0, 0))
	--ParticleManager:SetParticleControl(effect_cast, 61, Vector(1, 0, 1))
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then
    self.parent:EmitSound("Hero_Bristleback.PistonProngs.QuillSpray.Cast")
    self.parent:StopSound("Hero_Bristleback.PistonProngs.IdleLoop")
    self.parent:EmitSound("Hero_Bristleback.PistonProngs.IdleLoop")
    self:StartIntervalThink(3)
  end
end

function bald_5_modifier_passive:PlayEfxQuillImpact(target)
	local particle_cast = "particles/units/heroes/hero_bristleback/bristleback_quill_spray_impact.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, target)
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then target:EmitSound("Hero_Bristleback.QuillSpray.Target") end
end

function bald_5_modifier_passive:PlayEfxCall(radius)
  local particle_cast = "particles/econ/items/axe/axe_ti9_immortal/axe_ti9_gold_call.vpcf"
  local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
  ParticleManager:SetParticleControl(effect_cast, 2, Vector(radius, radius, radius))
  ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_mouth", Vector(0,0,0), true)
  ParticleManager:ReleaseParticleIndex(effect_cast)

  if IsServer() then self.parent:EmitSound("Hero_Axe.BerserkersCall.Item.Shoutmask") end
end
bocuse_u_modifier_mise = class({})

function bocuse_u_modifier_mise:IsHidden() return false end
function bocuse_u_modifier_mise:IsPurgable() return false end
function bocuse_u_modifier_mise:GetPriority() return MODIFIER_PRIORITY_ULTRA end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_u_modifier_mise:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.stop = false
	self.extra_damage = 0

  AddStatusEfx(self.ability, "bocuse_u_modifier_mise_status_efx", self.caster, self.parent)
  AddModifier(self.parent, self.caster, self.ability, "bocuse_u_modifier_jump", {duration = 0.5}, false)

  if self.ability:GetSpecialValueFor("special_unslow") == 1 then
    AddModifier(self.parent, self.caster, self.ability, "_modifier_unslowable", {}, false)
	end

  AddBonus(self.ability, "LCK", self.parent, self.ability:GetSpecialValueFor("special_lck"), 0, nil)

  self.ability:SetActivated(false)
  if self.ability.autocast == false then self.ability:EndCooldown() end

	self:CheckAggro()
	self:StartSlash()
  self:PlayEfxStart()
end

function bocuse_u_modifier_mise:OnRefresh(kv)
end

function bocuse_u_modifier_mise:OnRemoved()
	self.parent:FadeGesture(ACT_DOTA_CHANNEL_ABILITY_4)
  RemoveStatusEfx(self.ability, "bocuse_u_modifier_mise_status_efx", self.caster, self.parent)

  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_unslowable", self.ability)
  RemoveBonus(self.ability, "LCK", self.parent)

  self.ability:SetActivated(true)
  if self.ability.autocast == false then self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel())) end
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_u_modifier_mise:CheckState()
	local state = {
    [MODIFIER_STATE_ALLOW_PATHING_THROUGH_CLIFFS] = true,
    [MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = true,
		[MODIFIER_STATE_DISARMED] = true,
    [MODIFIER_STATE_SILENCED] = true,
    [MODIFIER_STATE_FROZEN] = false
	}

	return state
end

function bocuse_u_modifier_mise:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_EVENT_ON_DEATH,
    MODIFIER_EVENT_ON_STATE_CHANGED
	}

	return funcs
end

function bocuse_u_modifier_mise:GetModifierIncomingDamage_Percentage(keys)
	return self:GetAbility():GetSpecialValueFor("special_incoming")
end

function bocuse_u_modifier_mise:GetModifierProcAttack_BonusDamage_Physical()
	return self.extra_damage
end

function bocuse_u_modifier_mise:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end

	if RandomFloat(0, 100) < self.ability:GetSpecialValueFor("special_microstun_chance") then
    AddModifier(keys.target, self.caster, self.ability, "_modifier_stun", {duration = 0.2}, false)
	end
end

function bocuse_u_modifier_mise:OnOrder(keys)
	if keys.unit ~= self.parent then return end
	if keys.order_type ~= DOTA_UNIT_ORDER_ATTACK_TARGET then return end
	local target = keys.target

	Timers:CreateTimer((FrameTime()), function()
		if target and self then
      if self.parent:IsCommandRestricted() == false then
        if (self.parent:GetOrigin() - target:GetOrigin()):Length2D() > self.parent:Script_GetAttackRange() then
          local direction = (self.parent:GetOrigin() - target:GetOrigin()):Normalized() * self.parent:Script_GetAttackRange()
          local point = target:GetOrigin() + direction
          self.parent:MoveToPosition(point)
        else
          self.parent:Stop()
        end        
      end
		end
	end)
end

function bocuse_u_modifier_mise:OnDeath(keys)
  if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
  if keys.attacker ~= self.parent then return end
  if keys.unit:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if keys.unit:IsHero() == false then return end
	if keys.unit:IsIllusion() then return end
	local extra_damage = self.ability:GetSpecialValueFor("special_extra_damage")

	if extra_damage > 0 then
		self:SetDuration(self:GetDuration(), true)
		self.extra_damage = self.extra_damage + extra_damage
		self:PlayEfxStart()
	end
end

function bocuse_u_modifier_mise:OnStateChanged(keys)
	if keys.unit ~= self.parent then return end
	if self.parent:IsHexed() == true and self.stop == false then
		self.stop = true
		self:StartIntervalThink(-1)
	end

	if self.parent:IsHexed() == false and self.stop == true then
		self.stop = false
		self:StartSlash()
	end
end

function bocuse_u_modifier_mise:OnIntervalThink()
	if self.init then
		self.init = false
    self.parent:FadeGesture(1728)
    self.parent:StartGestureWithPlaybackRate(ACT_DOTA_CHANNEL_ABILITY_4, self.speed)
	end

	local radius = self.parent:Script_GetAttackRange() + 80
	local angle = self.ability:GetSpecialValueFor("angle")
	local cast_direction = self.parent:GetForwardVector():Normalized()
	local cast_angle = VectorToAngles(cast_direction).y

	self:FindTrees(radius, angle, cast_angle)
	self:FindEnemies(radius, angle, cast_direction, cast_angle)
	self:SetSlashSpeed()
end

-- UTILS -----------------------------------------------------------

function bocuse_u_modifier_mise:CheckAggro()
	local target = self.parent:GetAttackTarget()
	if target == nil then target = self.parent:GetAggroTarget() end
	if target then
    if self.parent:IsCommandRestricted() == false then
      self.parent:Stop()
      if (self.parent:GetOrigin() - target:GetOrigin()):Length2D() > self.parent:Script_GetAttackRange() then
        local direction = (self.parent:GetOrigin() - target:GetOrigin()):Normalized() * self.parent:Script_GetAttackRange()
        local point = target:GetOrigin() + direction
        self.parent:MoveToPosition(point)
      end      
    end
	end
end

function bocuse_u_modifier_mise:StartSlash()
  local speed_mult = 1 + ((self.ability:GetSpecialValueFor("speed_mult") - 100) * 0.01)
	local gesture_cycle = 1.5
  self.speed = gesture_cycle * speed_mult

	self.hits = {
		[1] = {[1] = 1, [2] = 0.35 / speed_mult},
		[2] = {[1] = 2, [2] = 0.35 / speed_mult},
		[3] = {[1] = 3, [2] = 0.5 / speed_mult},
		[4] = {[1] = 4, [2] = 0.3 / speed_mult}
	}

	self.state_hit = self.hits[1]
	
	self.init = true
	self.parent:StartGestureWithPlaybackRate(1728, 3)
	if IsServer() then self:StartIntervalThink(0.5) end
end

function bocuse_u_modifier_mise:SetSlashSpeed()
	for i = 1, 4, 1 do
		if self.state_hit[1] == self.hits[i][1] then
			if self.hits[i][1] == self.hits[4][1] then
				self.state_hit = self.hits[1]
			else
				self.state_hit = self.hits[i + 1]
			end
			break
		end
  end

  if IsServer() then self:StartIntervalThink(self.state_hit[2]) end
end

function bocuse_u_modifier_mise:FindTrees(radius, angle, cast_angle)
	local trees = GridNav:GetAllTreesAroundPoint(self.parent:GetOrigin(), radius, false)
	if trees == nil then return end

	for _,tree in pairs(trees) do
		local tree_direction = (tree:GetOrigin() - self.parent:GetOrigin()):Normalized()
		local tree_angle = VectorToAngles(tree_direction).y
		local angle_diff = math.abs(AngleDiff(cast_angle, tree_angle))

		if angle_diff <= angle then tree:CutDown(self.parent:GetTeamNumber()) end
	end
end

function bocuse_u_modifier_mise:FindEnemies(radius, angle, cast_direction, cast_angle)
	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	0, false
	)

	for _,enemy in pairs(enemies) do
		local enemy_direction = (enemy:GetOrigin() - self.parent:GetOrigin()):Normalized()
		local enemy_angle = VectorToAngles(enemy_direction).y
		local angle_diff = math.abs(AngleDiff(cast_angle, enemy_angle))

		if angle_diff <= angle then
			self:HitTarget(enemy, cast_direction)
		end
  end
end

function bocuse_u_modifier_mise:HitTarget(target, direction)
	if target:IsInvulnerable() then return end
	if target:IsAttackImmune() then return end

	self.parent:PerformAttack(target, false, true, true, false, false, false, false)
	self:PlayEfxHit(target, self.parent:GetOrigin(), direction)
end

-- EFFECTS -----------------------------------------------------------

function bocuse_u_modifier_mise:GetStatusEffectName()
	return "particles/econ/items/invoker/invoker_ti7/status_effect_alacrity_ti7.vpcf"
end

function bocuse_u_modifier_mise:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function bocuse_u_modifier_mise:PlayEfxStart()
  local particle_cast = "particles/econ/items/doom/doom_ti8_immortal_arms/doom_ti8_immortal_devour.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())

  if self.effect_cast ~= nil then ParticleManager:DestroyParticle(self.effect_cast, true) end
  local particle_cast_1 = "particles/econ/items/pudge/pudge_immortal_arm/pudge_immortal_arm_rot.vpcf"
	self.effect_cast = ParticleManager:CreateParticle(particle_cast_1, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.effect_cast, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)
	self:AddParticle(self.effect_cast, false, false, -1, false, false)

  if self.effect_cast2 ~= nil then ParticleManager:DestroyParticle(self.effect_cast2, true) end
  local particle_cast_2 = "particles/econ/items/ogre_magi/ogre_ti8_immortal_weapon/ogre_ti8_immortal_bloodlust_buff.vpcf"
	self.effect_cast2 = ParticleManager:CreateParticle(particle_cast_2, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.effect_cast2, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)
	self:AddParticle(self.effect_cast2, false, false, -1, false, false)

  if IsServer() then self.parent:EmitSound("Hero_Alchemist.ChemicalRage.Cast") end
end

function bocuse_u_modifier_mise:PlayEfxHit(target, origin, direction)
	local particle_cast = "particles/units/heroes/hero_grimstroke/grimstroke_cast2_ground.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())

	particle_cast = "particles/units/heroes/hero_mars/mars_shield_bash_crit.vpcf"
	effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, target)
	ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, target:GetOrigin())
	ParticleManager:SetParticleControlForward(effect_cast, 1, direction)
	ParticleManager:ReleaseParticleIndex(effect_cast)

  if IsServer() then target:EmitSound("Hero_Alchemist.ChemicalRage.Attack") end
end
striker_1_modifier_passive = class({})

function striker_1_modifier_passive:IsHidden()
	return false
end

function striker_1_modifier_passive:IsPurgable()
	return false
end

function striker_1_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_1_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.hits = 0
	self.last_hit_target = nil
	self.sonicblow = false
	self.sonic_mirror = false
end

function striker_1_modifier_passive:OnRefresh(kv)
end

function striker_1_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function striker_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_STATE_CHANGED,
		MODIFIER_EVENT_ON_UNIT_MOVED,
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function striker_1_modifier_passive:OnStateChanged(keys)
	if keys.unit ~= self.parent then return end
	if self.parent:IsStunned()
	or self.parent:IsHexed()
	or self.parent:IsFrozen()
	or self.parent:IsDisarmed() then
		if self.parent:IsIllusion() then print("1") end
		self:CancelCombo(false)
	end
end

function striker_1_modifier_passive:OnUnitMoved(keys)
	if keys.unit ~= self.parent then return end
	if self.parent:IsIllusion() then print("2") end
	self:CancelCombo(false)
end

function striker_1_modifier_passive:OnOrder(keys)
	if keys.unit ~= self.parent then return end
	if keys.order_type > 10 then return end
	if keys.order_type == 4 then
		if keys.target then
			if keys.target == self.last_hit_target then
				return
			end
		end
	end

	if self.parent:IsIllusion() then print("3") end
	self:CancelCombo(false)
end

function striker_1_modifier_passive:OnAttack(keys)
	if keys.attacker ~= self.parent then return end

	self:CheckHits(keys.target)
	self.last_hit_target = keys.target
end

function striker_1_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	self:TryCombo(keys.target)
end

-- UTILS -----------------------------------------------------------

function striker_1_modifier_passive:CheckHits(target)
	if target ~= self.last_hit_target then if self.parent:IsIllusion() then print("4") end self:CancelCombo(false) return end
	if self.hits < 1 then return end
	self.hits = self.hits - 1
	if self.hits < 1 then if self.parent:IsIllusion() then print("5") end self:CancelCombo(false) end
end

function striker_1_modifier_passive:TryCombo(target)
	if self.parent:PassivesDisabled() then return end

	local chance = self.ability:GetSpecialValueFor("chance")
	local base_stats = self.parent:FindAbilityByName("base_stats")
	if base_stats then chance = chance * base_stats:GetCriticalChance() end

	if RandomFloat(1, 100) <= chance then
		self:PerformBlink(target)
	end
end

function striker_1_modifier_passive:PerformBlink(target)
	self:CancelCombo(true)

	-- UP 1.11
	if self.ability:GetRank(11) then
		self.parent:AddNewModifier(self.caster, self.ability, "striker_1_modifier_immune", {})
	end

	-- UP 1.12
	if self.ability:GetRank(12) then
		self.ability:AddBonus("_2_LCK", self.parent, 10, 0, nil)
	end

	-- UP 1.31
	if self.ability:GetRank(31) then
		self.ability:StartCooldown(12)
	end

	-- UP 1.32
	if self.ability:GetRank(32) then
		self:PerformAfterShake()
	end

	-- UP 1.41
	if self.ability:GetRank(41) then
		self:PerformMirrorSonic(RandomInt(0, 2), target)
	end

	local agi = self.ability:GetSpecialValueFor("agi")
	self.ability:AddBonus("_1_AGI", self.parent, agi, 0, nil)
	self.parent:Stop()

	self:PlayEfxBlinkStart(target:GetOrigin() - self.parent:GetOrigin(), target)
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_ban", {})

	local delay = 0.3
	if self.parent:HasModifier("striker_6_modifier_sof")
	or self.parent:HasModifier("striker_6_modifier_return")
	or self.parent:HasModifier("striker_6_modifier_illusion_sof") then
		delay = 0.1
	end

	Timers:CreateTimer((delay), function()
		if target then
			if IsValidEntity(target) then
				local point = target:GetAbsOrigin() + RandomVector(350)
				self:PlayEfxBlinkEnd(target:GetAbsOrigin() - point, point)

				local blink_point = (point - target:GetOrigin()):Normalized() * 50
				blink_point = target:GetOrigin() + blink_point
				GridNav:DestroyTreesAroundPoint(blink_point, 150, false)

				self.parent:SetAbsOrigin(blink_point)
				self.parent:SetForwardVector((target:GetAbsOrigin() - blink_point):Normalized())
				FindClearSpaceForUnit(self.parent, blink_point, true)

				local mod = self.parent:FindAllModifiersByName("_modifier_ban")
				for _,modifier in pairs(mod) do
					if modifier:GetAbility() == self.ability then modifier:Destroy() end
				end

				self:PerformCombo(target)
				self:ApplyKnockback(target)
			end
		end
	end)
end

function striker_1_modifier_passive:PerformCombo(target)
	self.hits = self.ability:GetSpecialValueFor("hits")
	self.sonicblow = true
	self.parent:MoveToTargetToAttack(target)
	self:PlayEfxComboStart()
end

function striker_1_modifier_passive:CancelCombo(bRepeat)
	if self.sonicblow == false then return end
	if bRepeat == false then
		self.parent:RemoveModifierByNameAndCaster("striker_1_modifier_immune", self.caster)

		if self.parent:IsIllusion() and self.sonic_mirror == true then
			self.parent:Kill(self.ability, self.caster)
		end
	end

	self.ability:RemoveBonus("_1_AGI", self.parent)
	self.ability:RemoveBonus("_2_LCK", self.parent)
	self.hits = 0
	self.sonicblow = false
end

function striker_1_modifier_passive:ApplyKnockback(target)
	local knockback_duration = 0.25

	-- UP 1.21
	if self.ability:GetRank(21) then
		local chance = 25
		local base_stats = self.parent:FindAbilityByName("base_stats")
		if base_stats then chance = chance * base_stats:GetCriticalChance() end

		if RandomFloat(1, 100) <= chance then
			knockback_duration = knockback_duration + 0.5
		end
	else
		if target:IsMagicImmune() then return end
	end

	local knockbackProperties =
	{
		duration = knockback_duration,
		knockback_duration = knockback_duration,
		knockback_distance = 75,
		center_x = self.parent:GetAbsOrigin().x + 1,
		center_y = self.parent:GetAbsOrigin().y + 1,
		center_z = self.parent:GetAbsOrigin().z,
		knockback_height = 10,
	}

	target:AddNewModifier(self.caster, nil, "modifier_knockback", knockbackProperties)
	if IsServer() then target:EmitSound("Hero_Spirit_Breaker.Charge.Impact") end
end

function striker_1_modifier_passive:PerformAfterShake(target)
	local radius = 300

	local damageTable = {
		victim = nil,
		attacker = self.parent,
		damage = 50,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability
	}

	local enemies = FindUnitsInRadius(
        self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        0, 0, false
    )

    for _,enemy in pairs(enemies) do
		damageTable.victim = enemy
		ApplyDamage(damageTable)

		if enemy:IsAlive() then
			enemy:AddNewModifier(self.caster, self.ability, "_modifier_stun", {duration = 0.3})
		end
    end

    GridNav:DestroyTreesAroundPoint(self.parent:GetOrigin(), radius, true)
	self:PlayEfxAfterShake(radius)
end

function striker_1_modifier_passive:PerformMirrorSonic(number, target)
	if self.parent:IsIllusion() then return end
	if number == 0 then return end

	local enemies = FindUnitsInRadius(
        self.caster:GetTeamNumber(), target:GetOrigin(), nil, 500,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false
    )

    for _,enemy in pairs(enemies) do
		if number > 0 and enemy:IsHero()
		and enemy ~= target then
			self:CreateCopy(enemy)
			number = number - 1			
		end
	end

	for _,enemy in pairs(enemies) do
		if number > 0 and enemy ~= target then
			self:CreateCopy(enemy)
			number = number - 1
		end
	end
end

function striker_1_modifier_passive:CreateCopy(target)
	local ein_sof = self.parent:FindAbilityByName("striker_6__sof")

	local illu_array = CreateIllusions(self.caster, self.parent, {
		outgoing_damage = 0, incoming_damage = 200,
		bounty_base = 0, bounty_growth = 0, duration = -1
	}, 1, 64, false, true)

	for _,illu in pairs(illu_array) do
		if ein_sof and self.parent:HasModifier("striker_6_modifier_sof") then
			if ein_sof:IsTrained() then
				illu:AddNewModifier(self.caster, ein_sof, "striker_6_modifier_illusion_sof", {})
			end
		end

		local caster_ult = self.caster:FindAbilityByName("striker_u__auto")
		local illu_ult = illu:FindAbilityByName("striker_u__auto")
		if illu_ult and caster_ult then illu_ult:SetLevel(caster_ult:GetLevel()) end

		local passive = illu:FindModifierByName("striker_1_modifier_passive")
		passive.last_hit_target = target
		passive.sonic_mirror = true
		passive:PerformBlink(target)
	end	
end

-- EFFECTS -----------------------------------------------------------

function striker_1_modifier_passive:PlayEfxBlinkStart(direction, target)
	local particle_cast = "particles/econ/events/ti10/blink_dagger_start_ti10_splash.vpcf"
	
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl( effect_cast, 0, self.parent:GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast, 0, direction:Normalized() )
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() + direction )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	if IsServer() then self.parent:EmitSound("Hero_Antimage.Blink_out") end
end

function striker_1_modifier_passive:PlayEfxBlinkEnd(direction, point)
	local particle_cast_a = "particles/econ/items/phantom_assassin/pa_fall20_immortal_shoulders/pa_fall20_blur_start.vpcf"
	local particle_cast_b = "particles/econ/events/ti10/blink_dagger_end_ti10_lvl2.vpcf"
	
	local effect_cast_a = ParticleManager:CreateParticle(particle_cast_a, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast_a, 0, point)
	ParticleManager:SetParticleControlForward(effect_cast_a, 0, direction:Normalized())
	ParticleManager:SetParticleControl(effect_cast_a, 1, point + direction )
	ParticleManager:ReleaseParticleIndex(effect_cast_a)

	local effect_cast_b = ParticleManager:CreateParticle( particle_cast_b, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl(effect_cast_b, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControlForward( effect_cast_b, 0, direction:Normalized())
	ParticleManager:ReleaseParticleIndex(effect_cast_b)

	if IsServer() then self.parent:EmitSound("Hero_Antimage.Blink_in.Persona") end
end

function striker_1_modifier_passive:PlayEfxComboStart()
	local particle_cast = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_spawn_v2.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())

	if IsServer() then self.parent:EmitSound("Hero_Centaur.DoubleEdge") end
end

function striker_1_modifier_passive:PlayEfxAfterShake(radius)
	local particle_cast = "particles/striker/striker_aftershake.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(radius, radius, radius))

	if IsServer() then self.parent:EmitSound("Hero_EarthShaker.Totem") end
end
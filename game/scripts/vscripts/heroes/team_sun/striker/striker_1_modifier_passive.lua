striker_1_modifier_passive = class({})

function striker_1_modifier_passive:IsHidden() return false end
function striker_1_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_1_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.hits = 0
	self.last_hit_target = nil
	self.sonicblow = false
	self.sonic_mirror = false
	self.illu_array = {}
end

function striker_1_modifier_passive:OnRefresh(kv)
end

function striker_1_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function striker_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_EVENT_ON_STATE_CHANGED,
		MODIFIER_EVENT_ON_UNIT_MOVED,
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function striker_1_modifier_passive:GetModifierAttackRangeBonus(keys)
	return self:GetAbility():GetSpecialValueFor("atk_range")
end

function striker_1_modifier_passive:OnStateChanged(keys)
	if keys.unit ~= self.parent then return end
	if self.parent:IsStunned()
	or self.parent:IsHexed()
	or self.parent:IsFrozen()
	or self.parent:IsDisarmed() then
		self:CancelCombo(false)
	end
end

function striker_1_modifier_passive:OnUnitMoved(keys)
	if keys.unit ~= self.parent then return end

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
	if target ~= self.last_hit_target then self:CancelCombo(false) return end
	if self.hits < 1 then return end
	self.hits = self.hits - 1
	if self.hits < 1 then self:CancelCombo(false) end
end

function striker_1_modifier_passive:TryCombo(target)
	if self.parent:PassivesDisabled() then return end

	if RandomFloat(1, 100) <= self.ability:GetSpecialValueFor("chance") then
		self:PerformBlink(target)
	end
end

function striker_1_modifier_passive:PerformBlink(target)
	self:CancelCombo(true)
	self:PerformMirrorSonic(self.parent:IsIllusion(), target)
	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))

	local agi = self.ability:GetSpecialValueFor("agi")
	AddBonus(self.ability, "_1_AGI", self.parent, agi, 0, nil)
	self.parent:Stop()

	self:PlayEfxBlinkStart(target:GetOrigin() - self.parent:GetOrigin(), target)
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_ban", {})
	self:PerformAfterShake()

	local delay = 0.3
	if self.parent:HasModifier("striker_5_modifier_sof")
	or self.parent:HasModifier("striker_5_modifier_return")
	or self.parent:HasModifier("striker_5_modifier_illusion_sof") then
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

        RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_ban", self.ability)

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
		if self.parent:IsIllusion() and self.sonic_mirror == true then
			local caster_mod = self.owner:FindModifierByName("striker_1_modifier_passive")
			for i = #caster_mod.illu_array, 1, -1 do
				if caster_mod.illu_array[i] == self.parent then
					table.remove(caster_mod.illu_array, i)
				end
			end

			self.parent:Kill(self.ability, self.caster)
			return
		end
	end

	RemoveBonus(self.ability, "_1_AGI", self.parent)
	self.hits = 0
	self.sonicblow = false
end

function striker_1_modifier_passive:ApplyKnockback(target)
	if RandomFloat(1, 100) > self.ability:GetSpecialValueFor("knockback_chance") then return end

	target:AddNewModifier(self.caster, nil, "modifier_knockback", {
		duration = 0.3,
		knockback_duration = 0.3,
		knockback_distance = 75,
		center_x = self.parent:GetAbsOrigin().x + 1,
		center_y = self.parent:GetAbsOrigin().y + 1,
		center_z = self.parent:GetAbsOrigin().z,
		knockback_height = 12,
	})

	if IsServer() then target:EmitSound("Hero_Spirit_Breaker.Charge.Impact") end
end

function striker_1_modifier_passive:PerformAfterShake(target)
	local damage = self.ability:GetSpecialValueFor("special_shake_damage")
	local radius = self.ability:GetSpecialValueFor("special_shake_radius")
	if radius == 0 then return end

	local enemies = FindUnitsInRadius(
		self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0, 0, false
	)

	for _,enemy in pairs(enemies) do
		self:PlayEfxScreenShake(enemy)

    RemoveAllModifiersByNameAndAbility(enemy, "_modifier_percent_movespeed_debuff", self.ability)

		enemy:AddNewModifier(self.caster, self.ability, "_modifier_percent_movespeed_debuff", {
			duration = CalcStatus(1.5, self.caster, enemy),
			percent = 100
		})

		ApplyDamage({
			victim = enemy, attacker = self.caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self.ability
		})
	end

	GridNav:DestroyTreesAroundPoint(self.parent:GetOrigin(), radius, true)
	self:PlayEfxAfterShake(radius)
end

function striker_1_modifier_passive:PerformMirrorSonic(bIllusion, target)
	local radius = self.ability:GetSpecialValueFor("special_copy_range")
	local number = RandomInt(0, self.ability:GetSpecialValueFor("special_copy_number"))
	if number <= 0 then return end
	if bIllusion then return end

	local enemies = FindUnitsInRadius(
        self.caster:GetTeamNumber(), target:GetOrigin(), nil, radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false
    )

	for _,enemy in pairs(enemies) do
		if number > 0 and enemy ~= target then
			local pass = true
			for _,illu in pairs(self.illu_array) do
				local passive = illu:FindModifierByName("striker_1_modifier_passive")
				if passive.last_hit_target == enemy then
					pass = false
				end
			end

			if pass then
				self:CreateCopy(enemy)
				number = number - 1
			end
		end
	end
end

function striker_1_modifier_passive:CreateCopy(target)
	local ein_sof = self.parent:FindAbilityByName("striker_5__sof")

	local illu_array = CreateIllusions(self.caster, self.parent, {
		outgoing_damage = 0, incoming_damage = 200,
		bounty_base = 0, bounty_growth = 0, duration = -1
	}, 1, 64, false, true)

	for _,illu in pairs(illu_array) do
		if ein_sof and self.parent:HasModifier("striker_5_modifier_sof") then
			if ein_sof:IsTrained() then
				illu:AddNewModifier(self.caster, ein_sof, "striker_5_modifier_illusion_sof", {})
			end
		end

		local caster_ult = self.caster:FindAbilityByName("striker_u__auto")
		local illu_ult = illu:FindAbilityByName("striker_u__auto")
		if illu_ult and caster_ult then illu_ult:SetLevel(caster_ult:GetLevel()) end

		local passive = illu:FindModifierByName("striker_1_modifier_passive")
		passive.last_hit_target = target
		passive.sonic_mirror = true
		passive.owner = self.caster
		passive:PerformBlink(target)

		table.insert(self.illu_array, illu)
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

function striker_1_modifier_passive:PlayEfxScreenShake(target)
	local string = "particles/bioshadow/bioshadow_poison_hit_shake.vpcf"
	local effect = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
	ParticleManager:SetParticleControl(effect, 1, Vector(100, 0, 0))
	ParticleManager:ReleaseParticleIndex(effect)
end
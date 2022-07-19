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
	or self.parent:IsFrozen()
	or self.parent:IsDisarmed() then
		self:CancelCombo()
	end
end

function striker_1_modifier_passive:OnUnitMoved(keys)
	if keys.unit ~= self.parent then return end
	self:CancelCombo()
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

	self:CancelCombo()
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
	if target ~= self.last_hit_target then self:CancelCombo() return end
	if self.hits < 1 then return end
	self.hits = self.hits - 1
	if self.hits < 1 then self:CancelCombo() end
end

function striker_1_modifier_passive:TryCombo(target)
	if self.parent:PassivesDisabled() then return end

	local chance = self.ability:GetSpecialValueFor("chance")
	local base_stats = self.parent:FindAbilityByName("base_stats")
	if base_stats then chance = chance * base_stats:GetCriticalChance() end

	if RandomFloat(1, 100) <= chance then
		self:CancelCombo()
		self:PerformBlink(target)
	end
end

function striker_1_modifier_passive:PerformBlink(target)
	local agi = self.ability:GetSpecialValueFor("agi")
	self.ability:AddBonus("_1_AGI", self.parent, agi, 0, nil)
	self.parent:Stop()

	self:PlayEfxBlinkStart(target:GetOrigin() - self.parent:GetOrigin(), target)
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_ban", {})

	Timers:CreateTimer((0.3), function()
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


function striker_1_modifier_passive:CancelCombo()
	if self.sonicblow == false then return end
	self.ability:RemoveBonus("_1_AGI", self.parent)
	self.hits = 0
	self.sonicblow = false
end

function striker_1_modifier_passive:ApplyKnockback(target)
	local knockbackProperties =
	{
		duration = 0.25,
		knockback_duration = 0.25,
		knockback_distance = 75,
		center_x = self.parent:GetAbsOrigin().x + 1,
		center_y = self.parent:GetAbsOrigin().y + 1,
		center_z = self.parent:GetAbsOrigin().z,
		knockback_height = 15,
	}

	target:AddNewModifier(self.caster, nil, "modifier_knockback", knockbackProperties)
	if IsServer() then target:EmitSound("Hero_Spirit_Breaker.Charge.Impact") end
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
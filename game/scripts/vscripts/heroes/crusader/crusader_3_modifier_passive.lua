crusader_3_modifier_passive = class ({})

function crusader_3_modifier_passive:IsHidden()
    return false
end

function crusader_3_modifier_passive:IsPurgable()
    return false
end

-----------------------------------------------------------

function crusader_3_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then
		self:SetStackCount(0)
	end
end

function crusader_3_modifier_passive:OnRefresh(kv)
end

function crusader_3_modifier_passive:OnRemoved(kv)
end

------------------------------------------------------------

function crusader_3_modifier_passive:CheckState()
	local state = {
		[MODIFIER_STATE_EVADE_DISABLED] = true,
	}

	return state
end

function crusader_3_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}

	return funcs
end

function crusader_3_modifier_passive:OnAttackLanded(keys)
	local steal_time = self.ability:GetSpecialValueFor("steal_time")

	-- UP 3.1
	if self.ability:GetRank(1) then
		steal_time = steal_time + 15
	end

	-- UP 3.4
	if self.ability:GetRank(4)
	and keys.target:GetTeamNumber() ~= self.parent:GetTeamNumber()
	and keys.attacker == self.parent
	and RandomInt(1, 100) <= 10 then
		self:PlayEfxSteal(keys.target)

		keys.target:AddNewModifier(self.caster, self.ability, "crusader_3_modifier_leech", {})
		self.parent:AddNewModifier(self.caster, self.ability, "crusader_3_modifier_leech", {
			duration = self.ability:CalcStatus(steal_time, self.caster, self.parent)
		})
	end

	if keys.target ~= self.parent then return end
	if keys.attacker:GetTeamNumber() == self.parent:GetTeamNumber() then return end

	local amount = 100
	local dex = self.parent:FindModifierByName("_2_DEX_modifier")
	if dex then amount = amount + dex:GetStackCount() end
	if keys.attacker:IsIllusion()
	or keys.attacker:IsHero() == false then
		amount = amount * 0.5
	end

	local counter_mult = self.ability:GetSpecialValueFor("counter_mult")
	local value = amount * counter_mult
    local counter_chance = (value * 6) / (1 +  (value * 0.06))

	if self.parent:HasModifier("crusader_3_modifier_buff") then
		counter_chance = counter_chance * 2
	else
		if self.parent:PassivesDisabled() then return end
	end

	if RandomInt(1, 10000) <= counter_chance * 100 then
		local target = self.parent:GetAttackTarget()
		if target then
			if target:IsIllusion() then return end
			if target:IsAlive() then
				-- local damageTable = {
				-- 	victim = target,
				-- 	attacker = self.parent,
				-- 	damage = self.parent:GetAttackDamage(),
				-- 	damage_type = DAMAGE_TYPE_PHYSICAL,
				-- 	ability = self.ability
				-- }

				-- -- UP 3.3
				-- if self.ability:GetRank(3) then
				-- 	local str = self.parent:FindModifierByName("_1_STR_modifier")
				-- 	if str then str:EnableForceSpellCrit(250) end	
				-- end

				-- ApplyDamage(damageTable)

				self.parent:PerformAttack(target, false, true, true, true, false, false, true)

				self:PlayEfxCounter(target)
				self.parent:FaceTowards(target:GetOrigin())
				self.parent:AddNewModifier(self.caster, self.ability, "_modifier_disarm", {duration = 0.25})

				if target:IsHero() and target:IsAlive() then
					self.parent:FaceTowards(target:GetOrigin())
					self:PlayEfxCounter(target)

					-- UP 3.5
					if self.ability:GetRank(5) then
						self:IncrementStackCount()
						if self:GetStackCount() >= 3 then
							self:SetStackCount(0)
							self.parent:Heal(target:GetMaxHealth() * 0.05, self.ability)
							self:PlayEfxHeal()
							
							target:AddNewModifier(self.caster, self.ability, "_modifier_silence", {
								duration = self.ability:CalcStatus(3, self.caster, target)
							})
						end
					end

					target:AddNewModifier(self.caster, self.ability, "crusader_3_modifier_leech", {})
					self.parent:AddNewModifier(self.caster, self.ability, "crusader_3_modifier_leech", {
						duration = self.ability:CalcStatus(steal_time, self.caster, self.parent)
					})
				end
			end
		end
	end
end

-----------------------------------------------------------

function crusader_3_modifier_passive:PlayEfxCounter(target)
	self.parent:FadeGesture(ACT_DOTA_ATTACK)
	self.parent:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 2)

	local particle_cast = "particles/units/heroes/hero_legion_commander/legion_commander_courage_hit.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())

    local particle_cast_target = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_explosion.vpcf"
    local effect_cast_target = ParticleManager:CreateParticle(particle_cast_target, PATTACH_POINT_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(effect_cast_target, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)

	if IsServer() then self.parent:EmitSound("Hero_LegionCommander.Courage") end
end

function crusader_3_modifier_passive:PlayEfxSteal(target)
    local particle_cast_target = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_explosion.vpcf"
    local effect_cast_target = ParticleManager:CreateParticle(particle_cast_target, PATTACH_POINT_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(effect_cast_target, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)

	if IsServer() then self.parent:EmitSound("Hero_Puck.Dream_Coil_Snap") end
end

function crusader_3_modifier_passive:PlayEfxHeal()
	local particle_cast = "particles/items3_fx/octarine_core_lifesteal.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)
end
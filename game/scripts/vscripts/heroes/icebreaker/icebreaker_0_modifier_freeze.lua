icebreaker_0_modifier_freeze = class({})

--------------------------------------------------------------------------------

function icebreaker_0_modifier_freeze:IsHidden()
	return false
end

function icebreaker_0_modifier_freeze:IsPurgable()
    return false
end

function icebreaker_0_modifier_freeze:IsStunDebuff()
	return true
end

function icebreaker_0_modifier_freeze:GetTexture()
	return "icebreaker_frozen"
end
--------------------------------------------------------------------------------

function icebreaker_0_modifier_freeze:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.break_damage = self.ability:GetSpecialValueFor("break_damage")

	if IsServer() then
		self:SetStackCount(0)
		self:PlayEfxStart()
	end
end

function icebreaker_0_modifier_freeze:OnRefresh( kv )
end

function icebreaker_0_modifier_freeze:OnRemoved( kv )
	if self.parent:GetTeamNumber() == self.caster:GetTeamNumber() then
		local heal = self:GetStackCount() * 0.5
		if heal > 0 then self.parent:Heal(heal, self.ability) end
	else
		local damageTable = {
			victim = self.parent,
			attacker = self.caster,
			damage = self:GetStackCount(),
			damage_type = self.ability:GetAbilityDamageType(),
			ability = self.ability
		}
		local value = math.floor(ApplyDamage(damageTable))
		if value > 0 then self:Popup(self.parent, value) end

		if self:GetStackCount() >= self.break_damage then
			self:PlayEfxDestroy()
		end

		if self.ability:GetAbilityName() == "icebreaker_3__blink" then
			-- UP 3.1
			if self.ability:GetRank(1) and self.parent:IsAlive() then
				local knockbackProperties =
				{
					duration = 0.5,
					knockback_duration = 0.5,
					knockback_distance = 125,
					center_x = self.caster:GetAbsOrigin().x + 1,
					center_y = self.caster:GetAbsOrigin().y + 1,
					center_z = self.caster:GetAbsOrigin().z,
					knockback_height = 12,
				}
	
				self.parent:AddNewModifier(self.caster, nil, "modifier_knockback", knockbackProperties)
				if IsServer() then self.parent:EmitSound("Hero_Spirit_Breaker.Charge.Impact") end
			end

			-- UP 3.2
			if self.ability:GetRank(2) then
				if value > 0 then self.caster:Heal(value, self.ability) end
			end
		end
	end
end

--------------------------------------------------------------------------------

function icebreaker_0_modifier_freeze:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FROZEN] = true,
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
		[MODIFIER_STATE_INVISIBLE] = false,
	}

	return state
end

function icebreaker_0_modifier_freeze:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end

function icebreaker_0_modifier_freeze:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_AVOID_DAMAGE,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
	return funcs
end


function icebreaker_0_modifier_freeze:GetModifierAvoidDamage(keys)
	if keys.target ~= self.parent then return 0 end
	if keys.damage <= 0 then return 0 end

	if IsServer() then
		self:PlayEfxHit()
		local stack = self:GetStackCount() + keys.damage
		if stack >= self.break_damage then
			self:SetStackCount(self.break_damage)
			self:Destroy()
		else
			self:SetStackCount(stack)
		end
	end

	return 1
end

function icebreaker_0_modifier_freeze:OnAbilityExecuted(keys)
	if self.parent:GetTeamNumber() == self.caster:GetTeamNumber() then return end
	self.ability = keys.ability
	
	if keys.unit == self.caster
	and keys.target == self.parent
	and self.ability:GetAbilityName() == "icebreaker_3__blink" then
		Timers:CreateTimer((0.1), function()
			if self.ability ~= nil then
				if IsValidEntity(self.ability) then
					self.ability:EndCooldown()
				end
			end
		end)

		local frost = keys.unit:FindAbilityByName("icebreaker_1__frost")
		if frost then
			if frost:IsTrained() then
				frost:ResetDouble()
			end
		end

		-- UP 3.4
		if self.ability:GetRank(4) then
			self:PlayEfxSpread()
			local units = FindUnitsInRadius(
				self.caster:GetTeamNumber(), self.parent:GetOrigin(),
				nil, 300,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
				0, 0, false
			)
		
			for _,unit in pairs(units) do
				if IsServer() then unit:EmitSound("Hero_DrowRanger.Marksmanship.Target") end

				local ability_slow = self.caster:FindAbilityByName("icebreaker_0__slow")
				if ability_slow then
					if ability_slow:IsTrained() then
						ability_slow:AddSlow(unit, ability_slow)
					end
				end

				local damageTable = {
					victim = unit,
					attacker = self.caster,
					damage = 40,
					damage_type = DAMAGE_TYPE_MAGICAL,
					ability = self.ability
				}
				local value = math.floor(ApplyDamage(damageTable))
				if value > 0 then self:PopupMagicalDamage(unit, value) end
			end
		end

		-- UP 3.5
		local damage = self.break_damage
		if self.ability:GetRank(5) then
			damage = damage + 30
		end

		self:SetStackCount(damage)
		self:PlayEfxBlink((keys.target:GetOrigin() - keys.unit:GetOrigin()), keys.unit:GetOrigin(), keys.target)
		self:Destroy()
	end
end

--------------------------------------------------------------------------------

function icebreaker_0_modifier_freeze:GetEffectName()
	return "particles/econ/items/winter_wyvern/winter_wyvern_ti7/wyvern_cold_embrace_ti7buff.vpcf"
end

function icebreaker_0_modifier_freeze:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function icebreaker_0_modifier_freeze:GetStatusEffectName()
	return "particles/econ/items/drow/drow_ti9_immortal/status_effect_drow_ti9_frost_arrow.vpcf"
end

function icebreaker_0_modifier_freeze:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function icebreaker_0_modifier_freeze:Popup(target, amount)
	local vec = {
		x = 125,
		y = 200,
		z = 225
	}

	if self.ability:GetAbilityName() == "icebreaker_3__blink" then
		vec.x = 225
		vec.y = 0
		vec.z = 0
	end
    
	self:PopupNumbers(target, "crit", Vector(vec.x, vec.y, vec.z), 2.5, amount, nil, 4)
end

function icebreaker_0_modifier_freeze:PopupDamageOverTime(target, amount)
    self:PopupNumbers(target, "crit", Vector(125, 200, 225), 3.0, amount, nil, 6)
end

function icebreaker_0_modifier_freeze:PopupNumbers(target, pfx, color, lifetime, number, pre, pos)
    local pfxPath = string.format("particles/msg_fx/msg_%s.vpcf", pfx)
	local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN_FOLLOW, target) -- target:GetOwner()
    
    local digits = 0
    if number ~= nil then
        digits = #tostring(number)
    end
    if presymbol ~= nil then
        digits = digits + 1
    end
    if postsymbol ~= nil then
        digits = digits + 1
    end

    ParticleManager:SetParticleControl(pidx, 1, Vector(0, tonumber(number), pos))
    ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
end

function icebreaker_0_modifier_freeze:PlayEfxBlink(direction, origin, target)
	local particle_cast = "particles/units/heroes/hero_centaur/centaur_double_edge.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
	ParticleManager:SetParticleControlForward(effect_cast, 0, direction:Normalized())
	ParticleManager:SetParticleControl(effect_cast, 1, origin + direction)
	ParticleManager:ReleaseParticleIndex(effect_cast)
	
	if IsServer() then target:EmitSound("Hero_Ancient_Apparition.IceBlastRelease.Cast") end
	if IsServer() then target:EmitSound("Hero_Icebreaker.Break") end
end

function icebreaker_0_modifier_freeze:PlayEfxStart()
	if IsServer() then self.parent:EmitSound("Hero_Ancient_Apparition.IceBlast.Tracker") end
end

function icebreaker_0_modifier_freeze:PlayEfxHit()
	if IsServer() then self.parent:EmitSound("Hero_Lich.ProjectileImpact") end
end

function icebreaker_0_modifier_freeze:PlayEfxDestroy()
	local particle = "particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_start.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())

	local particle_2 = "particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/cm_arcana_pup_flee.vpcf"
	local effect_cast_2 = ParticleManager:CreateParticle(particle_2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast_2, 0, self.parent:GetOrigin())

	if IsServer() then self.parent:EmitSound("Hero_Lich.IceSpire.Destroy") end
end

function icebreaker_0_modifier_freeze:PlayEfxSpread()
	local particle = "particles/econ/items/ancient_apparition/aa_blast_ti_5/ancient_apparition_ice_blast_explode_ti5.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
end

function icebreaker_0_modifier_freeze:PopupMagicalDamage(target, amount)
    self:PopupNumbers(target, "crit", Vector(125, 200, 225), 3.0, amount, nil, POPUP_SYMBOL_POST_SKULL)
end

-- function icebreaker_0_modifier_freeze:PopupNumbers(target, pfx, color, lifetime, number, presymbol, postsymbol)
--     local pfxPath = string.format("particles/msg_fx/msg_%s.vpcf", pfx)
-- 	local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN_FOLLOW, target) -- target:GetOwner()
-- 	postsymbol = 6
    
--     local digits = 0
--     if number ~= nil then
--         digits = #tostring(number)
--     end
--     if presymbol ~= nil then
--         digits = digits + 1
--     end
--     if postsymbol ~= nil then
--         digits = digits + 1
--     end

--     ParticleManager:SetParticleControl(pidx, 1, Vector(tonumber(nil), tonumber(number), tonumber(postsymbol)))
--     ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
--     ParticleManager:SetParticleControl(pidx, 3, color)
-- end
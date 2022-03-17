bloodstained_3_modifier_curse = class({})

function bloodstained_3_modifier_curse:IsHidden()
	return false
end

function bloodstained_3_modifier_curse:IsPurgable()
    return self.purge
end

----------------------------------------------------------------------------------------------------------------

function bloodstained_3_modifier_curse:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.truesight = false
	self.purge = true

	self.max_range = self.ability:GetSpecialValueFor("max_range")
	self.shared_damage = self.ability:GetSpecialValueFor("shared_damage") * 0.01

    -- UP 3.21
	if self.ability:GetRank(21) then
		self.purge = false
	end

    -- UP 3.31
	if self.ability:GetRank(31) then
		self.shared_damage = (self.ability:GetSpecialValueFor("shared_damage") + 25) * 0.01
	end

    -- UP 3.13
	if self.ability:GetRank(13)
	and self.caster ~= self.parent then
		self.truesight = true
	end
	
	if self.caster == self.parent then
		self.target = self.ability:GetCursorTarget()

		if self.target == nil then
			self:Destroy()
			return
		end

		self.target:AddNewModifier(self.caster, self.ability, self:GetName(), {
			duration = self:GetDuration()
		})
	end

	self.time = 0
	self.intervals = 0.1
	self:PlayEfxStart()
	self:StartIntervalThink(self.intervals)
end

function bloodstained_3_modifier_curse:OnRefresh(kv)
end

function bloodstained_3_modifier_curse:OnRemoved()
	if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, false) end
	
	if self.caster == self.parent then
		if self.target then
			if IsValidEntity(self.target) then
				self.target:RemoveModifierByName(self:GetName())
			end
		end
	else
		-- UP 3.12
		if self.ability:GetRank(12) then
			if self.parent:IsAlive() == false then self.ability:EndCooldown() end
		end
		
		self.caster:RemoveModifierByName(self:GetName())
	end
end


------------------------------------------------------------------------------------------------

function bloodstained_3_modifier_curse:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = false,
	}

	if self.truesight == true then
		return state
	end
end

function bloodstained_3_modifier_curse:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function bloodstained_3_modifier_curse:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }    
    return funcs
end

function bloodstained_3_modifier_curse:GetModifierIncomingDamage_Percentage(keys)
	if self.caster ~= self.parent then return end
	if self.target == nil then return end
	if IsValidEntity(self.target) == false then return end
	if self.target:IsAlive() == false then return end

	if keys.damage_flags ~= DOTA_DAMAGE_FLAG_REFLECTION then
		local damageTable = {
			damage = keys.original_damage * self.shared_damage,
			damage_type = keys.damage_type,
			attacker = self.caster,
			victim = self.target,
			ability = self.ability,
			damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
		}

		ApplyDamage(damageTable)
	end
end

function bloodstained_3_modifier_curse:OnIntervalThink()
	if self.caster == self.parent then return end
	if self.parent:IsInvisible() == false then AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), 50, 0.2, false) end
	if self.caster:IsInvisible() == false then AddFOWViewer(self.parent:GetTeamNumber(), self.caster:GetOrigin(), 50, 0.2, false) end

	self.time = self.time + 1

    -- UP 3.32
	if self.ability:GetRank(32)
	and self.time % 20 == 0 then
		local leech = self.parent:GetMaxHealth() * 0.05
		if self.parent:IsMagicImmune() == false then
			self.parent:ModifyHealth(self.parent:GetHealth() - leech, self.ability, true, 0)
			self.caster:ModifyHealth(self.caster:GetHealth() + leech, self.ability, true, 0)
			self:PlayEfxHeal()
		end
	end

    -- UP 3.11
	if self.ability:GetRank(11) == false then
		local distance = CalcDistanceBetweenEntityOBB(self.parent, self.caster)
		if self.max_range < distance then
			self:Destroy()
			self:StartIntervalThink(-1)
		end
	end
end

----------------------------------------------------------------------------------------------------------------

function bloodstained_3_modifier_curse:PlayEfxStart()
	local particle_cast = "particles/units/heroes/hero_queenofpain/queen_shadow_strike_body.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)
	self:AddParticle(effect_cast, false, false, -1, false, false)

	if self.caster == self.parent then return end

	local particle_cast_2 = "particles/econ/items/grimstroke/gs_fall20_immortal/gs_fall20_immortal_soulbind.vpcf"
	self.effect_cast = ParticleManager:CreateParticle( particle_cast_2, PATTACH_ABSORIGIN_FOLLOW, self.caster )
	ParticleManager:SetParticleControlEnt(self.effect_cast, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControlEnt(self.effect_cast, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
end

function bloodstained_3_modifier_curse:PlayEfxHeal()
	local particle_cast = "particles/units/heroes/hero_undying/undying_soul_rip_damage.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.caster)
    ParticleManager:SetParticleControl(effect_cast, 0, self.caster:GetOrigin())
    ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())
    ParticleManager:SetParticleControl(effect_cast, 2, self.caster:GetOrigin())

	local particle_cast2 = "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath.vpcf"
    local effect_cast2 = ParticleManager:CreateParticle(particle_cast2, PATTACH_ABSORIGIN_FOLLOW, self.caster)
end


--particles/units/heroes/hero_grimstroke/grimstroke_cast2_ground.vpcf
--modificador que vai ficar no inimigo particles/econ/items/grimstroke/gs_fall20_immortal/gs_fall20_immortal_soul_marker_flames.vpcf
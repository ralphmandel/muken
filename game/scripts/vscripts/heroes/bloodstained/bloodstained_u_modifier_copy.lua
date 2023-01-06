bloodstained_u_modifier_copy = class({})

function bloodstained_u_modifier_copy:IsHidden() return false end
function bloodstained_u_modifier_copy:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained_u_modifier_copy:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
	self.target = nil
	self.slow_mod = nil
	self.hp = kv.hp

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "bloodstained_u_modifier_copy_status_efx", true) end

	Timers:CreateTimer(FrameTime(), function()
		self.parent:ModifyHealth(self.parent:GetMaxHealth(), self.ability, false, 0)
	end)

	if IsServer() then self:SetStackCount(self.hp) end
end

function bloodstained_u_modifier_copy:OnRefresh(kv)
end

function bloodstained_u_modifier_copy:OnRemoved()
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "bloodstained_u_modifier_copy_status_efx", false) end
	
	if self.target == nil then return end

	local mod = self.target:FindAllModifiersByName("bloodstained_u_modifier_slow")
	for _,modifier in pairs(mod) do
		if modifier == self.slow_mod then modifier:Destroy() end
	end

	if self.parent:IsAlive() then
		local mod_extra_hp = self.caster:AddNewModifier(self.caster, self.ability, "bloodstained__modifier_extra_hp", {
			extra_life = self:GetStackCount(), cap = 1000
		})

		mod_extra_hp:ApplyTargetDebuff(self.target)

		self.parent:Kill(self.ability, nil)
	else
		if self.target:IsAlive() then
			--local iDesiredHealthValue = self.target:GetHealth() + self:GetStackCount()
			--self.target:ModifyHealth(iDesiredHealthValue, self.ability, false, 0)
		end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function bloodstained_u_modifier_copy:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true
	}

	return state
end


function bloodstained_u_modifier_copy:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_DEATH
	}

	return funcs
end

function bloodstained_u_modifier_copy:GetModifierMoveSpeedBonus_Percentage(target)
	return 100
end

function bloodstained_u_modifier_copy:OnDeath(keys)
	if keys.unit == self.target then self:Destroy() end
end

function bloodstained_u_modifier_copy:OnTakeDamage(keys)
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end
	if self.slow_mod == nil then return end

	self.slow_mod:ChangeHP(keys.damage)
	self.hp = self.hp + keys.damage
	if IsServer() then self:SetStackCount(math.floor(self.hp)) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bloodstained_u_modifier_copy:GetStatusEffectName()
	return "particles/bloodstained/bloodstained_u_illusion_status.vpcf"
end

function bloodstained_u_modifier_copy:StatusEffectPriority()
	return 99999999
end

function bloodstained_u_modifier_copy:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end

function bloodstained_u_modifier_copy:PlayEfxTarget()
	if self.target == nil then return end
	local string = "particles/bloodstained/bloodstained_u_track1.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.target)
	ParticleManager:SetParticleControlEnt(particle, 3, self.target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
	self:AddParticle(particle, false, false, -1, false, true)

	if IsServer() then self.target:EmitSound("Hero_LifeStealer.OpenWounds") end
end
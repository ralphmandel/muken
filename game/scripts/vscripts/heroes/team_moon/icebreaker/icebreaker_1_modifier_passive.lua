icebreaker_1_modifier_passive = class({})

function icebreaker_1_modifier_passive:IsHidden() return false end
function icebreaker_1_modifier_passive:IsPurgable() return false end
function icebreaker_1_modifier_passive:GetTexture() return "icebreaker_aspd" end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_1_modifier_passive:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	Timers:CreateTimer(0.2, function()
		if IsServer() then
			self.ability.kills = self.ability:GetSpecialValueFor("agi")
			self:SetStackCount(self.ability.kills)
			self:PlayEfxAmbient()
		end
	end)
end

function icebreaker_1_modifier_passive:OnRefresh(kv)
	if IsServer() then
		self:SetStackCount(self.ability.kills)
	end
end

function icebreaker_1_modifier_passive:OnRemoved()
	RemoveBonus(self.ability, "_1_AGI", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_STATE_CHANGED,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_HERO_KILLED,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function icebreaker_1_modifier_passive:OnStateChanged(keys)
	if keys.unit ~= self.parent then return end

	if self.parent:PassivesDisabled() then
		self:SetStackCount(0)
	else
		self:SetStackCount(self.ability.kills)
	end
end

function icebreaker_1_modifier_passive:GetModifierTotalDamageOutgoing_Percentage(keys)
	if keys.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then return 0 end
	
	if self.proc then
		self.proc = nil
		return -9999
	end

	return 0
end

function icebreaker_1_modifier_passive:OnHeroKilled(keys)
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if self.parent:IsIllusion() then return end

	local blink = self.parent:FindAbilityByName("icebreaker_u__blink")
	if blink == nil then return end
	if keys.inflictor ~= blink then return end

	if IsServer() then
		self.ability.kills = self.ability.kills + 1
		self:SetStackCount(self.ability.kills)
		self:PlayEfxKill()
	end
end

function icebreaker_1_modifier_passive:OnAttackFail(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:HasModifier("icebreaker__modifier_frozen") then return end
	if self.parent:PassivesDisabled() then return end

	if RandomFloat(1, 100) <= self.ability:GetSpecialValueFor("chance") then
		self:ApplyFrost(keys.target)
	end
end

function icebreaker_1_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:HasModifier("icebreaker__modifier_frozen") then return end
	if self.parent:PassivesDisabled() then return end

	if RandomFloat(1, 100) <= self.ability:GetSpecialValueFor("special_blink_chance") then
		self:PerformAutoBlink(keys.target)
	end

	if RandomFloat(1, 100) <= self.ability:GetSpecialValueFor("chance") then
		self:ApplyFrost(keys.target)
	end
end

function icebreaker_1_modifier_passive:OnStackCountChanged(old)
	RemoveBonus(self.ability, "_1_AGI", self.parent)

	if self:GetStackCount() > 0 then
		AddBonus(self.ability, "_1_AGI", self.parent, self:GetStackCount(), 0, nil)
	end
end

-- UTILS -----------------------------------------------------------

function icebreaker_1_modifier_passive:ApplyFrost(target)
	if target:IsMagicImmune() then return end
	local instant_duration = self.ability:GetSpecialValueFor("special_instant_duration")

	target:AddNewModifier(self.caster, self.ability, "icebreaker__modifier_hypo", {
		duration = CalcStatus(self.ability:GetSpecialValueFor("stack_duration"), self.caster, target), stack = 1
	})

	if instant_duration > 0 then
		target:AddNewModifier(self.caster, self.ability, "icebreaker__modifier_instant", {
			duration = instant_duration
		})
	end

	ApplyDamage({
		victim = target, attacker = self.caster,
		damage = self.ability:GetSpecialValueFor("damage"),
		damage_type = self.ability:GetAbilityDamageType(),
		ability = self.ability
	})

	self.proc = true
end

function icebreaker_1_modifier_passive:PerformAutoBlink(target)
	if self.parent:IsRooted() then return end

	local direction = target:GetForwardVector() * (-1)
	local blink_point = target:GetAbsOrigin() + direction * 130

	self:PlayEfxAutoBlink()
	self.parent:SetAbsOrigin(blink_point)
	self.parent:SetForwardVector(-direction)
	FindClearSpaceForUnit(self.parent, blink_point, true)
end

-- EFFECTS -----------------------------------------------------------

function icebreaker_1_modifier_passive:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_radiant.vpcf"
end

function icebreaker_1_modifier_passive:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

function icebreaker_1_modifier_passive:PlayEfxAmbient()
  if self.effect_cast_1 then ParticleManager:DestroyParticle(self.effect_cast_1, true) end
	local particle_cast_1 = "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ambient.vpcf"
	self.effect_cast_1 = ParticleManager:CreateParticle(particle_cast_1, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(self.effect_cast_1, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)
	self:AddParticle(self.effect_cast_1, false, false, -1, false, false)

	if self.effect_cast_2 then ParticleManager:DestroyParticle(self.effect_cast_2, true) end
	local particle_cast_2 = "particles/units/heroes/hero_ancient_apparition/ancient_apparition_chilling_touch_buff.vpcf"
	self.effect_cast_2 = ParticleManager:CreateParticle(particle_cast_2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast_2, 0, self.parent:GetOrigin() )
	self:AddParticle(self.effect_cast_2, false, false, -1, false, false)
end

function icebreaker_1_modifier_passive:PlayEfxAutoBlink()
	local particle_cast = "particles/econ/events/winter_major_2017/blink_dagger_start_wm07.vpcf" 
	local effect_cast_a = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect_cast_a, 0, self.parent:GetOrigin())
	--ParticleManager:SetParticleControlForward(effect_cast_a, 0, direction:Normalized())
	--ParticleManager:SetParticleControl(effect_cast_a, 1, origin + direction)
	ParticleManager:ReleaseParticleIndex(effect_cast_a)

	if IsServer() then self.parent:EmitSound("Hero_QueenOfPain.Blink_out") end
end

function icebreaker_1_modifier_passive:PlayEfxKill()
	local particle_cast = "particles/econ/items/techies/techies_arcana/techies_suicide_kills_arcana.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())

	local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_fleshheap_count.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(nFXIndex, 1, Vector(1, 0, 0))
	ParticleManager:ReleaseParticleIndex(nFXIndex)
end
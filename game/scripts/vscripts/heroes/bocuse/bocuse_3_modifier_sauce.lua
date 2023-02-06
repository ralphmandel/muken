bocuse_3_modifier_sauce = class({})

function bocuse_3_modifier_sauce:IsHidden() return false end
function bocuse_3_modifier_sauce:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_3_modifier_sauce:OnCreated(kv)
  self.caster = self:GetCaster()
	self.parent = self:GetParent()
  self.ability = self:GetAbility()
	self.chance = 0

	if IsServer() then
		self:SetStackCount(1)
		self:CheckCounterEfx()
		self:PlayEfxStart()
	end
end

function bocuse_3_modifier_sauce:OnRefresh(kv)	
	if IsServer() then
		if self:GetStackCount() < self.ability:GetSpecialValueFor("max_stack")
		and RandomFloat(1, 100) <= self.chance then
			self:IncrementStackCount()
		end
	end
end

function bocuse_3_modifier_sauce:OnRemoved()
	if self.pidx then ParticleManager:DestroyParticle(self.pidx, true) end
	self:CheckCounterEfx()

	local mod = self.parent:FindAllModifiersByName("_modifier_break")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	local mod = self.parent:FindAllModifiersByName("_modifier_silence")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_3_modifier_sauce:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function bocuse_3_modifier_sauce:GetModifierIncomingDamage_Percentage(keys)
	return self:GetAbility():GetSpecialValueFor("damage_amp_stack") * self:GetStackCount()
end

function bocuse_3_modifier_sauce:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end

	local lifesteal_base = self.ability:GetSpecialValueFor("lifesteal_base")
	local lifesteal_stack = self.ability:GetSpecialValueFor("lifesteal_stack")
	local heal_percent = lifesteal_base + (lifesteal_stack * (self:GetStackCount() - 1))
	local heal_amount = keys.damage * heal_percent * 0.01

	self:ApplyHeal(self.caster, heal_amount)

	if self.ability:GetSpecialValueFor("special_heal_allies") == 1 
	and keys.attacker ~= self.caster then
		self:ApplyHeal(keys.attacker, heal_amount)
	end
end

function bocuse_3_modifier_sauce:OnIntervalThink()
	self.chance = self.chance + 5
	if IsServer() then self:StartIntervalThink(0.25) end
end

function bocuse_3_modifier_sauce:OnStackCountChanged(old)
	if self:GetStackCount() ~= old then
		self:ModifySauce(self:GetStackCount())

		self.chance = 0
		if IsServer() then self:StartIntervalThink(0.25) end
	end	
end

-- UTILS -----------------------------------------------------------

function bocuse_3_modifier_sauce:ApplyHeal(target, heal_amount)
	if target == nil then return end
	if target:IsBaseNPC() == false then return end
	if target:GetTeamNumber() ~= self.caster:GetTeamNumber() then return end

	target:Heal(heal_amount, self.ability)
	self:PlayEfxLifesteal(target)
end

function bocuse_3_modifier_sauce:ModifySauce(stack_count)
	local duration = self.ability:GetSpecialValueFor("duration")
	local duration_reduction = self.ability:GetSpecialValueFor("duration_reduction")
	local duration = duration - (duration_reduction * (stack_count - 1))

	self:SetDuration(duration, true)

	if stack_count > 0 then
		self:PopupSauce(true)
	end

	if RandomFloat(1, 100) <= self.ability:GetSpecialValueFor("special_purge_chance") * stack_count then
		self.parent:Purge(true, false, false, false, false)
	end

	if stack_count == self.ability:GetSpecialValueFor("max_stack") then
		if self.ability:GetSpecialValueFor("special_break") == 1 then
			self.parent:AddNewModifier(self.caster, self.ability, "_modifier_break", {
				duration = self:GetRemainingTime()
			})		
		end

		if self.ability:GetSpecialValueFor("special_silence") == 1 then
			self.parent:AddNewModifier(self.caster, self.ability, "_modifier_silence", {
				duration = self:GetRemainingTime(),
				special = 2
			})	
		end
	end
end

-- EFFECTS -----------------------------------------------------------

function bocuse_3_modifier_sauce:PlayEfxStart()
	local particle_cast_1 = "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodrage_ground_eztzhok.vpcf"
	local effect_cast_1 = ParticleManager:CreateParticle( particle_cast_1, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt(effect_cast_1, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)
  self:AddParticle(effect_cast_1, false, false, -1, false, false)
end

function bocuse_3_modifier_sauce:CheckCounterEfx()
	local mod = self.parent:FindModifierByName("icebreaker__modifier_hypo")
	if mod then
		if IsServer() then mod:PopupIce(false) end
	end
end

function bocuse_3_modifier_sauce:PopupSauce(sound)
	if self.pidx then ParticleManager:DestroyParticle(self.pidx, true) end

	local particle = "particles/bocuse/bocuse_3_counter.vpcf"
	if self.parent:HasModifier("icebreaker__modifier_hypo") then particle = "particles/bocuse/bocuse_3_double_counter.vpcf" end
	self.pidx = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.pidx, 2, Vector(self:GetStackCount(), 0, 0))
	
	if sound == true then
		if IsServer() then self.parent:EmitSound("") end
	end
end

function bocuse_3_modifier_sauce:PlayEfxLifesteal(attacker)
	local particle_cast = "particles/items3_fx/octarine_core_lifesteal.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, attacker)
	ParticleManager:SetParticleControl(effect_cast, 1, attacker:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)
end
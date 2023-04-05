flea_5_modifier_desolator = class({})

function flea_5_modifier_desolator:IsHidden() return false end
function flea_5_modifier_desolator:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_5_modifier_desolator:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
	self.damage_total = 0

	local special_slow = self.ability:GetSpecialValueFor("special_slow")
	if special_slow > 0 then
		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_percent_movespeed_debuff", {
			percent = special_slow
		})
	end

	if IsServer() then self:PlayEfxStart() end
end

function flea_5_modifier_desolator:OnRefresh(kv)
end

function flea_5_modifier_desolator:OnRemoved()
	local mod = self.parent:FindAllModifiersByName("_modifier_percent_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
	
	local damageTable = {
		damage = self.damage_total * self.ability:GetSpecialValueFor("special_damage_percent") * 0.01,
		attacker = self.caster,
		victim = self.parent,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability
	}

	if damageTable.damage > 0 then
		self.parent:Purge(true, false, false, false, false)
		self:PlayEfxEnd()
		ApplyDamage(damageTable)
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_5_modifier_desolator:CheckState()
	local state = {}

	-- if self:GetAbility():GetSpecialValueFor("special_block") == 1 then
	-- 	state[MODIFIER_STATE_BLOCK_DISABLED] = true
	-- end

	if self:GetAbility():GetSpecialValueFor("special_evade") == 1 then
		state[MODIFIER_STATE_EVADE_DISABLED] = true
	end

	return state
end

function flea_5_modifier_desolator:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_IGNORE_PHYSICAL_ARMOR,
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function flea_5_modifier_desolator:GetModifierIgnorePhysicalArmor()
	return 1
end

function flea_5_modifier_desolator:GetDisableHealing()
	return self:GetAbility():GetSpecialValueFor("special_heal")
end

function flea_5_modifier_desolator:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end
	self.damage_total = self.damage_total + keys.damage
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function flea_5_modifier_desolator:GetEffectName()
	return "particles/items3_fx/star_emblem.vpcf"
end

function flea_5_modifier_desolator:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function flea_5_modifier_desolator:PlayEfxStart()
	local string_1 = "particles/items_fx/abyssal_blink_end.vpcf"
	local particle_1 = ParticleManager:CreateParticle(string_1, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle_1, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(particle_1)

	if IsServer() then self.parent:EmitSound("DOTA_Item.AbyssalBlade.Activate") end
end

function flea_5_modifier_desolator:PlayEfxEnd()
	local string_1 = "particles/items_fx/abyssal_blink_start.vpcf"
	local particle_1 = ParticleManager:CreateParticle(string_1, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle_1, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(particle_1)

	if IsServer() then self.parent:EmitSound("DOTA_Item.Bloodthorn.Activate") end
end
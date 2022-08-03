krieger_1_modifier_fury = class({})

function krieger_1_modifier_fury:IsHidden()
	return true
end

function krieger_1_modifier_fury:IsPurgable()
	return true
end

function krieger_1_modifier_fury:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function krieger_1_modifier_fury:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local agi = self.ability:GetSpecialValueFor("agi")
	self.ability:AddBonus("_1_AGI", self.parent, agi, 0, nil)

	local models = {
		["models/items/sven/endless_fury_sven_belt/endless_fury_sven_belt.vmdl"] = {["particles/krieger/dark_fury/krieger_dark_fury_belt.vpcf"] = "nil"},
		["models/items/sven/endless_fury_sven_head/endless_fury_sven_head.vmdl"] = {["particles/krieger/dark_fury/krieger_dark_fury_head.vpcf"] = "attach_head"},
		["models/items/sven/endless_fury_sven_shoulder/endless_fury_sven_shoulder.vmdl"] = {["particles/krieger/dark_fury/krieger_dark_fury_shoulder.vpcf"] = "nil"},
		["models/items/sven/endless_fury_sven_arms/endless_fury_sven_arms.vmdl"] = {["particles/krieger/dark_fury/krieger_dark_fury_arms.vpcf"] = "nil"},
		["models/items/sven/endless_fury_sven_weapon/endless_fury_sven_weapon.vmdl"] = {["particles/krieger/dark_fury/krieger_dark_fury_weapon.vpcf"] = "attach_sword_fx"}
	}

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then
		cosmetics:SetStatusEffect(self.caster, nil, "krieger_1_modifier_fury_status_efx", true)
		cosmetics:ReloadAmbients(self.parent, models, false)
	end

	if IsServer() then self:PlayEfxStart() end
end

function krieger_1_modifier_fury:OnRefresh(kv)
end

function krieger_1_modifier_fury:OnRemoved()
	if self.pfx_fury then ParticleManager:DestroyParticle(self.pfx_fury, false) end
	self.ability:RemoveBonus("_1_AGI", self.parent)

	local models = {
		["models/items/sven/endless_fury_sven_belt/endless_fury_sven_belt.vmdl"] = {["particles/krieger/endless_fury/krieger_endless_fury_belt.vpcf"] = nil},
		["models/items/sven/endless_fury_sven_head/endless_fury_sven_head.vmdl"] = {["particles/krieger/endless_fury/krieger_endless_fury_head.vpcf"] = "attach_head"},
		["models/items/sven/endless_fury_sven_shoulder/endless_fury_sven_shoulder.vmdl"] = {["particles/krieger/endless_fury/krieger_endless_fury_shoulder.vpcf"] = nil},
		["models/items/sven/endless_fury_sven_arms/endless_fury_sven_arms.vmdl"] = {["particles/krieger/endless_fury/krieger_endless_fury_arms.vpcf"] = nil},
		["models/items/sven/endless_fury_sven_weapon/endless_fury_sven_weapon.vmdl"] = {["particles/krieger/endless_fury/krieger_endless_fury_weapon.vpcf"] = "attach_sword_fx"}
	}

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then
		cosmetics:SetStatusEffect(self.caster, nil, "krieger_1_modifier_fury_status_efx", false)
		cosmetics:ReloadAmbients(self.parent, models, false)
	end
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function krieger_1_modifier_fury:PlayEfxStart()
	local string_2 = "particles/krieger/fury/krieger_fury_buff.vpcf"
	self.pfx_fury = ParticleManager:CreateParticle(string_2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.pfx_fury, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.pfx_fury, 10, Vector(self.parent:GetMana(), 0, 0))
	self:AddParticle(self.pfx_fury, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_Sven.GodsStrength") end
end

function krieger_1_modifier_fury:GetStatusEffectName()
	return "particles/econ/items/lifestealer/lifestealer_immortal_backbone/status_effect_life_stealer_immortal_rage.vpcf"
end

function krieger_1_modifier_fury:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end
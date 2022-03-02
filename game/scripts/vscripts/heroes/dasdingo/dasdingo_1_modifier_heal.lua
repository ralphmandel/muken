dasdingo_1_modifier_heal = class({})

function dasdingo_1_modifier_heal:IsHidden()
	return false
end

function dasdingo_1_modifier_heal:IsPurgable()
	return false
end

function dasdingo_1_modifier_heal:IsAura()
	return true
	--return (not self:GetCaster():PassivesDisabled())
end

function dasdingo_1_modifier_heal:GetModifierAura()
	return "dasdingo_1_modifier_heal_effect"
end

function dasdingo_1_modifier_heal:GetAuraRadius()
	if self:GetAbility():GetCurrentAbilityCharges() == 0 then return self:GetAbility():GetSpecialValueFor("radius") end
	if self:GetAbility():GetCurrentAbilityCharges() == 1 then return self:GetAbility():GetSpecialValueFor("radius") end
	if self:GetAbility():GetCurrentAbilityCharges() % 2 == 0 then return self:GetAbility():GetSpecialValueFor("radius") + 100 end
	return self:GetAbility():GetSpecialValueFor("radius")
end

function dasdingo_1_modifier_heal:GetAuraSearchTeam()
	if self:GetAbility():GetCurrentAbilityCharges() == 0 then return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
	if self:GetAbility():GetCurrentAbilityCharges() == 1 then return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
	if self:GetAbility():GetCurrentAbilityCharges() % 3 == 0 then return DOTA_UNIT_TARGET_TEAM_BOTH end
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY 
end

function dasdingo_1_modifier_heal:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

-----------------------------------------------------------

function dasdingo_1_modifier_heal:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.radius = self.ability:GetSpecialValueFor("radius")

	-- UP 1.5
	if self.ability:GetRank(5) then
		self.radius = self.radius + 100
	end

	if IsServer() then
		self:PlayEfxStart()

		-- UP 1.2
		if self.ability:GetRank(2) then
			self:PlayEfxRegen()
		end
	end
end

function dasdingo_1_modifier_heal:OnRefresh(kv)
end

function dasdingo_1_modifier_heal:OnRemoved(kv)
end

-----------------------------------------------------------

function dasdingo_1_modifier_heal:PlayEfxStart()
	local string = "particles/econ/items/witch_doctor/wd_ti10_immortal_weapon_gold/wd_ti10_immortal_voodoo_gold.vpcf"
	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
    ParticleManager:SetParticleControl(effect_cast, 1, Vector(self.radius, 0, 0 ))
	self:AddParticle(effect_cast, false, false, -1, false, false)
    
	if IsServer() then self.parent:EmitSound("Hero_Enchantress.EnchantCast") end
end

function dasdingo_1_modifier_heal:PlayEfxRegen()
	local string = "particles/econ/items/juggernaut/jugg_fortunes_tout/jugg_healing_ward_fortunes_tout_ward_gold_flame.vpcf"
	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
    ParticleManager:SetParticleControl(effect_cast, 1, Vector(self.radius, 0, 0 ))
    ParticleManager:SetParticleControl(effect_cast, 2, self.parent:GetOrigin())
	self:AddParticle(effect_cast, false, false, -1, false, false)
end
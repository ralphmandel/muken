icebreaker_0_modifier_passive_effect = class ({})

function icebreaker_0_modifier_passive_effect:IsHidden()
    return false
end

function icebreaker_0_modifier_passive_effect:IsPurgable()
    return false
end

function icebreaker_0_modifier_passive_effect:GetTexture()
	return "icebreaker_aspd"
end

-----------------------------------------------------------

function icebreaker_0_modifier_passive_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then
		self:SetStackCount(self.ability.kills)
		self:PlayEffects()
	end
end

function icebreaker_0_modifier_passive_effect:OnRefresh(kv)
	if IsServer() then
		self:SetStackCount(self.ability.kills)
	end
end

-----------------------------------------------------------

function icebreaker_0_modifier_passive_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_HERO_KILLED
	}
	
	return funcs
end

function icebreaker_0_modifier_passive_effect:OnTakeDamage(keys)
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end
	if keys.unit:IsBuilding() then return end

	local blink = self.parent:FindAbilityByName("icebreaker_3__blink")
	if blink == nil then return end
	if blink:IsTrained() == false then return end

	-- UP 3.31
	if blink.blink_lifesteal == true then
		local heal = keys.original_damage * 0.5
		self.parent:Heal(heal, blink)
		self:PlayEfxSpellLifesteal(self.parent)
		blink.blink_lifesteal = false
	end
end

function icebreaker_0_modifier_passive_effect:OnHeroKilled(keys)
	if keys.attacker == nil or keys.target == nil or keys.inflictor == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end

	if IsServer() then
		if keys.inflictor:GetAbilityName() == "icebreaker_3__blink" then
			self.ability:AddKillPoint(1)
			self:SetStackCount(self.ability.kills)
		end
	end
end

------------------------------------------------------------

function icebreaker_0_modifier_passive_effect:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_radiant.vpcf"
end

function icebreaker_0_modifier_passive_effect:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end

function icebreaker_0_modifier_passive_effect:PlayEffects()
    if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, true) end
	local particle_cast = "particles/units/heroes/hero_ancient_apparition/ancient_apparition_ambient.vpcf"
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControlEnt(self.effect_cast, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "", Vector(0,0,0), true)
	self:AddParticle(self.effect_cast, false, false, -1, false, false)
end

function icebreaker_0_modifier_passive_effect:PlayEfxSpellLifesteal(target)
	local particle = "particles/items3_fx/octarine_core_lifesteal.vpcf"
	local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect)
end
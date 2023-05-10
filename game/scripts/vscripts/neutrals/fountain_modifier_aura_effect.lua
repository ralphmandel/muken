fountain_modifier_aura_effect = class({})

function fountain_modifier_aura_effect:IsHidden()
	return false
end

function fountain_modifier_aura_effect:IsPurgable()
  return false
end

function fountain_modifier_aura_effect:GetPriority()
  return MODIFIER_PRIORITY_ULTRA
end

function fountain_modifier_aura_effect:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	if IsServer() then
		self:OnIntervalThink()
		self:PlayEfxStart()
	end
end

function fountain_modifier_aura_effect:OnRefresh( kv )
end

function fountain_modifier_aura_effect:OnRemoved()
end

--------------------------------------------------------------------------------------------------------------------------

function fountain_modifier_aura_effect:CheckState()
	local state = {}

	if self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
		state = {
			[MODIFIER_STATE_INVISIBLE] = false,
			[MODIFIER_STATE_TRUESIGHT_IMMUNE] = false
		}		
	end

	return state
end

function fountain_modifier_aura_effect:OnIntervalThink()
	if self.parent:GetTeamNumber() == self.caster:GetTeamNumber() then
		local heal = self.parent:GetMaxHealth() * 0.01
		self.parent:Heal(heal, self.ability)
		--self:PlayEfxHeal(self.parent)
	
		local recovery = 5
		if self.parent:GetUnitName() == "npc_dota_hero_elder_titan" then recovery = 0 end
		self.parent:GiveMana(recovery)
		--self:PlayEfxMana(self.parent)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, self.parent, recovery, self.parent)
	end

	if IsServer() then self:StartIntervalThink(0.25) end
end

--------------------------------------------------------------------------------------------------------------------------

function fountain_modifier_aura_effect:PlayEfxHeal(target)
	local particle_cast = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(effect_cast, 1, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)
end

function fountain_modifier_aura_effect:PlayEfxMana(target)
	local particle_cast = "particles/generic/give_mana.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(effect_cast, 1, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)
end

function fountain_modifier_aura_effect:PlayEfxStart()
	if self.parent:GetTeamNumber() ~= self.caster:GetTeamNumber() then return end

	local string = nil
	if self.parent:GetTeamNumber() == DOTA_TEAM_CUSTOM_1 then
		string = "particles/econ/events/ti7/fountain_regen_ti7_lvl3.vpcf"
	elseif self.parent:GetTeamNumber() == DOTA_TEAM_CUSTOM_2 then
		string = "particles/econ/events/fall_2022/regen/fountain_regen_fall2022_lvl3.vpcf"
	elseif self.parent:GetTeamNumber() == DOTA_TEAM_CUSTOM_3 then
		string = "particles/econ/events/fall_major_2016/radiant_fountain_regen_fm06_lvl3.vpcf"
	elseif self.parent:GetTeamNumber() == DOTA_TEAM_CUSTOM_4 then
		string = "particles/econ/events/spring_2021/fountain_regen_spring_2021_lvl3.vpcf"
	end

	if string == nil then return end

	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self.parent, PATTACH_POINT_FOLLOW, "", Vector(0,0,0), true)
	self:AddParticle(effect_cast, false, false, -1, false, false)
end
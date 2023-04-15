druid_u_modifier_conversion = class({})

function druid_u_modifier_conversion:IsHidden() return false end
function druid_u_modifier_conversion:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_u_modifier_conversion:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	self.parent:SetTeam(self.caster:GetTeamNumber())
	self.parent:SetOwner(self.caster)
	self.parent:SetControllableByPlayer(self.caster:GetPlayerOwnerID(), true)

	self.ability:AddUnit(self.parent)
	self:PlayEfxStart()
end

function druid_u_modifier_conversion:OnRefresh(kv)
end

function druid_u_modifier_conversion:OnRemoved()
	if IsServer() then
		if self.parent:GetUnitName() == "npc_druid_treant_lv1"
		or self.parent:GetUnitName() == "npc_druid_treant_lv2"
		or self.parent:GetUnitName() == "npc_druid_treant_lv3" then
			self.parent:EmitSound("Hero_Furion.TreantDeath")
		end
	end
	
	self.ability:RemoveUnit(self.parent)

	if self.parent:IsAlive() then
		self.parent:Kill(nil, nil)
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_u_modifier_conversion:CheckState()
	local state = {
		[MODIFIER_STATE_DOMINATED] = true
	}

	return state
end

function druid_u_modifier_conversion:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PRE_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function druid_u_modifier_conversion:GetModifierPreAttack(keys)
	if keys.attacker ~= self.parent then return end

	if self.parent:GetUnitName() == "npc_druid_treant_lv1"
	or self.parent:GetUnitName() == "npc_druid_treant_lv2"
	or self.parent:GetUnitName() == "npc_druid_treant_lv3" then
		if IsServer() then self.parent:EmitSound("Furion_Treant.PreAttack") end
	end
end

function druid_u_modifier_conversion:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end

	if self.parent:GetUnitName() == "npc_druid_treant_lv1"
	or self.parent:GetUnitName() == "npc_druid_treant_lv2"
	or self.parent:GetUnitName() == "npc_druid_treant_lv3" then
		if IsServer() then self.parent:EmitSound("Furion_Treant.Attack") end
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function druid_u_modifier_conversion:PlayEfxStart()
  local string = "particles/druid/druid_skill1_convert.vpcf"
	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	self:AddParticle(effect_cast, false, false, -1, false, false)

  if IsServer() then self.parent:EmitSound("Druid.Finish") end
end
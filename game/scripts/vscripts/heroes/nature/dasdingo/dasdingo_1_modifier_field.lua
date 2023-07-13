dasdingo_1_modifier_field = class({})

function dasdingo_1_modifier_field:IsHidden() return true end
function dasdingo_1_modifier_field:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function dasdingo_1_modifier_field:IsAura() return true end
function dasdingo_1_modifier_field:GetModifierAura() return "dasdingo_1_modifier_aura_effect" end
function dasdingo_1_modifier_field:GetAuraRadius() return self:GetAbility():GetAOERadius() end
function dasdingo_1_modifier_field:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function dasdingo_1_modifier_field:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function dasdingo_1_modifier_field:GetAuraSearchFlags() return self:GetAbility():GetAbilityTargetFlags() end
function dasdingo_1_modifier_field:GetAuraEntityReject(hEntity) return false end

-- CONSTRUCTORS -----------------------------------------------------------

function dasdingo_1_modifier_field:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  if IsServer() then self:PlayEfxStart() end
end

function dasdingo_1_modifier_field:OnRefresh(kv)
end

function dasdingo_1_modifier_field:OnRemoved()
  RemoveFOWViewer(self.caster:GetTeamNumber(), self.fow)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function dasdingo_1_modifier_field:PlayEfxStart()
	self.fow = AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), self.ability:GetAOERadius(), self:GetDuration(), false)

	local string = "particles/econ/items/witch_doctor/wd_ti10_immortal_weapon_gold/wd_ti10_immortal_voodoo_gold.vpcf"
	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
  ParticleManager:SetParticleControl(effect_cast, 1, Vector(self.ability:GetAOERadius(), 0, 0 ))
	self:AddParticle(effect_cast, false, false, -1, false, false)
    
	if IsServer() then self.parent:EmitSound("Hero_Enchantress.EnchantCast") end
end
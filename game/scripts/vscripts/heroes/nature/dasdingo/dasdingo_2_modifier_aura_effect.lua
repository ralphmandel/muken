dasdingo_2_modifier_aura_effect = class({})

function dasdingo_2_modifier_aura_effect:IsHidden() return true end
function dasdingo_2_modifier_aura_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function dasdingo_2_modifier_aura_effect:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  local def = self.ability:GetSpecialValueFor("def")
  if self.parent:IsHero() == false then def = def * 0.5 end 

  AddBonus(self.ability, "DEF", self.parent, def, 0, nil)

  if IsServer() then self:PlayEfxStart() end
end

function dasdingo_2_modifier_aura_effect:OnRefresh(kv)
end

function dasdingo_2_modifier_aura_effect:OnRemoved()
  RemoveBonus(self.ability, "DEF", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function dasdingo_2_modifier_aura_effect:PlayEfxStart()
	local special = ((self.ability:GetLevel() - 1) * 8)
  if self.parent:IsHero() == false then special = special * 0.5 end 
	local string = "particles/dasdingo/dasdingo_aura.vpcf"
	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(effect_cast, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(effect_cast, 3, Vector(special, 0, 0 ))

	self:AddParticle(effect_cast, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_Pangolier.TailThump.Cast") end
end
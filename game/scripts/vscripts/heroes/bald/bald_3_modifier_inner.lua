bald_3_modifier_inner = class({})

function bald_3_modifier_inner:IsHidden() return false end
function bald_3_modifier_inner:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_3_modifier_inner:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.origin = self.parent:GetOrigin()
  self.stomp = 0
  
  self.spell_immunity = self:GetAbility():GetSpecialValueFor("special_spell_immunity")
  self.giant = self:GetAbility():GetSpecialValueFor("special_giant")

  self.ability:SetActivated(false)
  self.ability:EndCooldown()

	if IsServer() then
		self:PlayEfxStart()
    if self.spell_immunity == 1 then self:PlayEfxBKB() end
    if self.giant == 1 then self:OnIntervalThink() end
	end
end

function bald_3_modifier_inner:OnRefresh(kv)
	if IsServer() then self:PlayEfxStart() end
end

function bald_3_modifier_inner:OnRemoved()
  self.ability:ResetModifierStack()
  self.ability:SetActivated(true)
  self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_3_modifier_inner:CheckState()
	local state = {}

  if self.giant == 1 then
  	table.insert(state, MODIFIER_STATE_ALLOW_PATHING_THROUGH_CLIFFS, true)
  	table.insert(state, MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES, true)
  end

  if self.spell_immunity == 1 then
    table.insert(state, MODIFIER_STATE_MAGIC_IMMUNE, true)
  end

	return state
end

function bald_3_modifier_inner:OnIntervalThink()
  local trees = GridNav:GetAllTreesAroundPoint(self.parent:GetOrigin(), 100 * self.parent:GetModelScale(), false)
  if trees == nil then return end
  for _,tree in pairs(trees) do tree:CutDown(self.parent:GetTeamNumber()) end

  local distance = (self.origin - self.parent:GetOrigin()):Length2D()
  self.stomp = self.stomp + distance
  while self.stomp >= 250 do
    self.stomp = self.stomp - 250
    if IsServer() then self:PlayEfxShake() end
  end

  self.origin = self.parent:GetOrigin()
  if IsServer() then self:StartIntervalThink(0.2) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bald_3_modifier_inner:PlayEfxStart()
	local string = "particles/bald/bald_inner/bald_inner_owner.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(particle, 10, Vector(self.parent:GetModelScale() * 100, 0, 0))
	ParticleManager:SetParticleControlEnt(particle, 2, self.parent, PATTACH_POINT_FOLLOW, "attach_weapon", Vector(0,0,0), true)
	self:AddParticle(particle, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_EarthSpirit.Magnetize.Cast") end
end

function bald_3_modifier_inner:PlayEfxBKB()
	local bkb_particle = ParticleManager:CreateParticle("particles/items_fx/black_king_bar_avatar.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(bkb_particle, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
	self:AddParticle(bkb_particle, false, false, -1, true, false)
end

function bald_3_modifier_inner:PlayEfxShake()
  local string = "particles/osiris/poison_alt/osiris_poison_splash_shake.vpcf"
  local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN, self.parent)
  ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
  ParticleManager:SetParticleControl(particle, 1, Vector(800 * (self:GetParent():GetModelScale() - 1), 0, 0))

  if IsServer() then self.parent:EmitSound("Bald.Move") end
end
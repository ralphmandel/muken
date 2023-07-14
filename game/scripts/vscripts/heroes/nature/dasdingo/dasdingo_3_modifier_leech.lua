dasdingo_3_modifier_leech = class({})

function dasdingo_3_modifier_leech:IsHidden() return false end
function dasdingo_3_modifier_leech:IsPurgable() return true end

--------------------------------------------------------------------------------

function dasdingo_3_modifier_leech:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.model = "models/items/shadowshaman/ss_fall20_immortal_head/ss_fall20_immortal_head.vmdl"

  AddModifier(self.parent, self.caster, self.ability, "_modifier_stun", {}, false)

  self.ability:SetActivated(false)
  self.ability:EndCooldown()

	if IsServer() then
		self:PlayEfxStart()
		self:OnIntervalThink()
	end
end

function dasdingo_3_modifier_leech:OnRefresh(kv)
end

function dasdingo_3_modifier_leech:OnRemoved(kv)
	self.caster:Interrupt()

  GestureCosmetic(self.caster, self.model, ACT_DOTA_CHANNEL_ABILITY_3, false)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_stun", self.ability)

  self.ability:SetActivated(true)
  self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))

	if IsServer() then self.parent:StopSound("Dasdingo.Leech.Loop") end

	local mod = self.parent:FindAllModifiersByName("_modifier_stun")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

--------------------------------------------------------------------------------

function dasdingo_3_modifier_leech:OnIntervalThink()
  local interval = 0.5
	local drain_amount = self.parent:GetMaxHealth() * self.ability:GetSpecialValueFor("drain_percent") * interval * 0.01
	self.parent:ModifyHealth(self.parent:GetHealth() - drain_amount, self.ability, true, 0)
	self.caster:ModifyHealth(self.caster:GetHealth() + drain_amount, self.ability, false, 0)

	if IsServer() then self:StartIntervalThink(interval) end
end

--------------------------------------------------------------------------------

function dasdingo_3_modifier_leech:PlayEfxStart()
	local head = FindCosmeticByModel(self.caster, self.model)

	ChangeCosmeticsActivity(self.caster)
  GestureCosmetic(self.caster, self.model, ACT_DOTA_CHANNEL_ABILITY_3, true)

  if head then
    local string = "particles/econ/items/shadow_shaman/ss_2021_crimson/shadowshaman_crimson_shackle.vpcf"
    local shackle_particle = ParticleManager:CreateParticle(string, PATTACH_POINT_FOLLOW, head)
    ParticleManager:SetParticleControlEnt(shackle_particle, 0, head, PATTACH_POINT_FOLLOW, "attach_tongue", head:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(shackle_particle, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", self.parent:GetAbsOrigin(), true)
    self:AddParticle(shackle_particle, true, false, -1, true, false)
  end

	if IsServer() then self.parent:EmitSound("Dasdingo.Leech.Loop") end
end
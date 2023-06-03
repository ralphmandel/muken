druid_u_modifier_reborn = class({})

function druid_u_modifier_reborn:IsHidden() return true end
function druid_u_modifier_reborn:IsPurgable() return false end
function druid_u_modifier_reborn:RemoveOnDeath() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_u_modifier_reborn:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function druid_u_modifier_reborn:OnRefresh(kv)
end

function druid_u_modifier_reborn:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_u_modifier_reborn:DeclareFunctions()
	local funcs = {
    MODIFIER_EVENT_ON_RESPAWN
	}

	return funcs
end

function druid_u_modifier_reborn:OnRespawn(keys)
  local reborn_hp = self.ability:GetSpecialValueFor("special_reborn_hp") * 0.01
  if keys.unit == self.parent then
    self.parent:ModifyHealth(self.parent:GetMaxHealth() * reborn_hp, self.ability, false, 0)
    self.parent:SetMana(self.parent:GetMaxMana() * reborn_hp)
    self:Destroy()
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------
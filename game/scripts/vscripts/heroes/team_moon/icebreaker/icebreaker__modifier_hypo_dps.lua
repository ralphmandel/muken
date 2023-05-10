icebreaker__modifier_hypo_dps = class({})

function icebreaker__modifier_hypo_dps:IsHidden() return true end
function icebreaker__modifier_hypo_dps:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker__modifier_hypo_dps:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.intervals = 0.8

  self.damageTable = {
    victim = self.parent, attacker = self.caster, ability = self.ability,
    damage = kv.hypo_damage * self.intervals,
    damage_type = DAMAGE_TYPE_MAGICAL
  }

  if IsServer() then self:StartIntervalThink(self.intervals) end
end

function icebreaker__modifier_hypo_dps:OnRefresh(kv)
end

function icebreaker__modifier_hypo_dps:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker__modifier_hypo_dps:OnIntervalThink()
  ApplyDamage(self.damageTable)
  if IsServer() then self:StartIntervalThink(self.intervals) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------
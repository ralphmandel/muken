ancient_3_modifier_casting = class({})

function ancient_3_modifier_casting:IsHidden() return true end
function ancient_3_modifier_casting:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_3_modifier_casting:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  local time = self.ability:GetCastPoint()
	local think = time - 0.45
	self.pos_delay = 0.65
	self.step = 1

  if IsServer() then
    AddModifier(self.parent, self.caster, self.ability, "ancient_3_modifier_efx_hands", {duration = time}, false)
  end

	if think < 0 then
		local rate = 1 / (time / 0.45)
		self.parent:StartGestureWithPlaybackRate(ACT_DOTA_ANCESTRAL_SPIRIT, rate)
		self:StartIntervalThink((self.pos_delay * (time / 0.45)) + time)
		self.step = 2
		return
	end

	self.parent:StartGesture(ACT_DOTA_TELEPORT)

	if IsServer() then
		self:StartIntervalThink(think)
		self:GetParent():EmitSound("Ancient.Aura.Channel")
	end
end

function ancient_3_modifier_casting:OnRefresh(kv)
end

function ancient_3_modifier_casting:OnRemoved()
  self.parent:FadeGesture(ACT_DOTA_TELEPORT)
	self.parent:FadeGesture(ACT_DOTA_ANCESTRAL_SPIRIT)

	if IsServer() then
		self:GetParent():RemoveModifierByName("ancient_3_modifier_efx_hands")
		self:GetParent():StopSound("Ancient.Aura.Channel")
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_3_modifier_casting:OnIntervalThink()
	if self.step == 1 then
		self.parent:FadeGesture(ACT_DOTA_TELEPORT)
		self.parent:StartGesture(ACT_DOTA_ANCESTRAL_SPIRIT)
		self:StartIntervalThink(self.pos_delay + 0.45)
		self.step = 2
	else
		self:Destroy()
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------
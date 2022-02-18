icebreaker_x2_modifier_sight = class({})

--------------------------------------------------------------------------------
function icebreaker_x2_modifier_sight:IsHidden()
	return true
end

function icebreaker_x2_modifier_sight:IsPurgable()
    return false
end

function icebreaker_x2_modifier_sight:IsDebuff()
    return true
end
--------------------------------------------------------------------------------

function icebreaker_x2_modifier_sight:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
    self.tick = 0.8

	self:StartIntervalThink(self.tick)
end

function icebreaker_x2_modifier_sight:OnRefresh( kv )
end

function icebreaker_x2_modifier_sight:OnRemoved( kv )
end

--------------------------------------------------------------------------------

function icebreaker_x2_modifier_sight:OnIntervalThink()
	local damageTable = {
		victim = self.parent,
		attacker = self.caster,
		damage = self.tick * self.parent:GetMaxHealth() * 0.005,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability
	} 
	self:PopupDamageOverTime(self.parent, math.floor(ApplyDamage(damageTable)))
end

--------------------------------------------------------------------------------

function icebreaker_x2_modifier_sight:PopupDamageOverTime(target, amount)
    if amount < 1 then return end
    self:PopupNumbers(target, "crit", Vector(255, 225, 175), 3.0, amount, nil, POPUP_SYMBOL_POST_SKULL)
end

function icebreaker_x2_modifier_sight:PopupNumbers(target, pfx, color, lifetime, number, presymbol, postsymbol)
    local pfxPath = string.format("particles/msg_fx/msg_%s.vpcf", pfx)
	local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN_FOLLOW, target) -- target:GetOwner()
	postsymbol = 6
    
    local digits = 0
    if number ~= nil then
        digits = #tostring(number)
    end
    if presymbol ~= nil then
        digits = digits + 1
    end
    if postsymbol ~= nil then
        digits = digits + 1
    end

    ParticleManager:SetParticleControl(pidx, 1, Vector(tonumber(nil), tonumber(number), tonumber(postsymbol)))
    ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
end
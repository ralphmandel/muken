shrine_refresh_mp_modifier = class({})

function shrine_refresh_mp_modifier:IsHidden() return false end
function shrine_refresh_mp_modifier:IsPurgable() return false end
function shrine_refresh_mp_modifier:RemoveOnDeath() return false end
function shrine_refresh_mp_modifier:GetTexture() return "_refresh_mana" end

function shrine_refresh_mp_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
end

function shrine_refresh_mp_modifier:OnRefresh( kv )
end

function shrine_refresh_mp_modifier:OnRemoved()
end
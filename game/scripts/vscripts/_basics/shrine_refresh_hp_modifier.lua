shrine_refresh_hp_modifier = class({})

function shrine_refresh_hp_modifier:IsHidden() return false end
function shrine_refresh_hp_modifier:IsPurgable() return false end
function shrine_refresh_hp_modifier:RemoveOnDeath() return false end
function shrine_refresh_hp_modifier:GetTexture() return "_refresh_health" end

function shrine_refresh_hp_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
end

function shrine_refresh_hp_modifier:OnRefresh( kv )
end

function shrine_refresh_hp_modifier:OnRemoved()
end
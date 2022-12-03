-----------------------------------------------------------------------
--                          Творческое объединение "MetroPack"
--	Скрипт написан в 2021 году для карты gm_metro_minsk_1984.
--  В 2022 выделен в отдельный аддон для дополнения Metrostroi.
--	Аддон добавляет в игру знаки уклонов.
--  Авторы: klusandr, ilya2000 (Илья Прокофьев) Classic Metrostroi Project
--	Steam klusandr: https://steamcommunity.com/id/andr47/
--	VK klusandr:	https://vk.com/andreyklysevich
--  Дополнительная информация в файле lua/licence.lua
-----------------------------------------------------------------------

if (not Metrostroi) then return end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
util.AddNetworkString "metrostroi-slope"

function ENT:Initialize()
	self:DrawShadow(false)
	self:SendUpdate()
end

function ENT:OnRemove()
end

function ENT:Think()
end

function ENT:SendUpdate()
	self:SetNWInt("Type", self.Type or 1)
	self:SetNWVector("Offset", Vector(0, self.YOffset or 0, self.ZOffset or 0))
	self:SetNWAngle("Angle", Angle(self.PAngle or 0, self.YAngle or 0, 0))
	self:SetNWString("Value_u", self.Value_u or "")
	self:SetNWString("Length", self.Length or "")
end

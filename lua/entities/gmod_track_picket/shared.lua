-----------------------------------------------------------------------
--                          Творческое объединение "MetroPack"
--	Скрипт написан в 2021 году для карты gm_metro_minsk_1984.
--  В 2022 выделен в отдельный аддон для дополнения Metrostroi.
--	Аддон добавляет в игру туннельные пикеты.
--	Автор: 	klusandr
--	Steam: 	https://steamcommunity.com/id/andr47/
--	VK:		https://vk.com/andreyklysevich
--  Дополнительная информация в файле lua/licence.lua
-----------------------------------------------------------------------

if (not Metrostroi) then return end

ENT.Type            = "anim"

ENT.PrintName       = "Piсket"
ENT.Category		= "Metrostroi (utility)"

ENT.Spawnable		= false
ENT.AdminSpawnable	= false
ENT.RenderGroup		= RENDERGROUP_BOTH

ENT.Models = {}


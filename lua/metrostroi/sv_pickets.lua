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

-- Logger --

local function log(message, category)
    if (Metrostroi.Logger) then
        Metrostroi.Logger.Log(message, category, "Pickets")
    end   
end

local function logError(message)
    log(message, "Error")
end

local function logInfo(message)
    log(message, "Info")
end

local filePath = "metrostroi_data/picket_"..game.GetMap()..".txt";

----

-- Check exists file.
local function checkFile(path)
    return file.Exists(path, "DATA") or file.Exists(path, "LUA")
end

-- Load data from the file.
-- (file) - File name.
-- RETURN - JSON data from file.
local function loadFile(path)
    local data,found
    if file.Exists(path, "DATA") then
        data = util.JSONToTable(file.Read(path, "DATA"))
        found = true
    end
    if not data and file.Exists(path, "LUA") then
        data = util.JSONToTable(file.Read(path, "LUA"))
        found = true
    end
    if not found then
        logError("Configuration file not found. Path: '"..path.."'")
        return
    elseif not data then
        logError("Configuration parse JSON error")
        return
    end
    return data
end

-- Save data in the file.
-- (path) - Full path to file.
-- (data) - Data written to file.
local function saveFile(path, data)
    file.Write(path, data)
end

-- Remove the file.
-- (file) - File name.
local function removeFile(path)
    file.Delete(path)
end

Metrostroi.Picket = {}

-- Load pickets.
function Metrostroi.Picket.Load()
    if (not checkFile(filePath)) then return end

    for _, ent in pairs(ents.FindByClass("gmod_track_picket")) do
        SafeRemoveEntity(ent) 
    end

    local data = loadFile(filePath)
    if not data then return end

    for k,v in pairs(data) do
        local ent = ents.Create("gmod_track_picket")
        if IsValid(ent) then
            ent:SetPos(v.Pos)
            ent:SetAngles(v.Angles)
            
            ent.Type = v.Type or 1
            ent.YOffset = v.YOffset or 0
            ent.ZOffset = v.ZOffset or 0
            ent.PAngle = v.PAngle or 0
            ent.YAngle = v.YAngle or 0
            ent.Left = v.Left or false 
            ent.RightNumber = v.RightNumber or ""
            ent.LeftNumber = v.LeftNumber or ""
            ent:SendUpdate()
            ent:Spawn()
        end
    end

    logInfo("Pickets is loaded")
end 

-- Save pickets.
function Metrostroi.Picket.Save()
    local pickets = {}
    
    for _, ent in pairs(ents.FindByClass("gmod_track_picket")) do
        table.insert(pickets, {
            Pos = ent:GetPos(),
            Angles = ent:GetAngles(),
            Type = (ent.Type ~= 1) and ent.Type or nil,
            YOffset = (ent.YOffset ~= 0) and ent.YOffset or nil,
            ZOffset = (ent.ZOffset ~= 0) and ent.ZOffset or nil,
            PAngle = (ent.PAngle ~= 0) and ent.PAngle or nil,
            YAngle = (ent.YAngle ~= 0) and ent.YAngle or nil,
            Left = (ent.Left ~= false) and ent.Left or nil,
            RightNumber = ent.RightNumber,
            LeftNumber = ent.LeftNumber,
        })
    end

    print("Metrostroi: Saving pickets definition...")

    if (not table.IsEmpty(pickets)) then
        saveFile(filePath, util.TableToJSON(pickets, true))
        print("Saved to "..filePath)
    else
        removeFile(filePath);
        print("File remove "..filePath)
    end
end

-- Teleport player to the picket.
-- (rightNumber) - Right picket number or Left picket number if (leftNumber) is nil.
-- (leftNumber) - Left picket number.
function Metrostroi.Picket.TeleportTo(ply, rightNum, leftNum)
    leftNum = leftNum or rightNum

    if (rightNum == nil) then return end

    local entList = ents.FindByClass("gmod_track_picket")

    for _, ent in pairs(entList) do
        if (ent.RightNumber == rightNum and ent.LeftNumber == leftNum) then
            ply:SetPos(ent:GetPos() + Vector(0, 0, 20))
        end
    end
end

-- Teleport player to the picket.
-- (args[1]) - Right picket number or Left picket number if (args[2]) is nil.
-- (args[2]) - Left picket number.
concommand.Add("picket_tp", function (ply, _, args)
    local rightNum = args[2] or args[1]
    local leftNum = args[1]

    Metrostroi.Picket.TeleportTo(ply, rightNum, leftNum)
end)

timer.Simple(1, function()                  --Задержка после загрузки игры
    local m_save = Metrostroi.Save
    function Metrostroi.Save(name)
        m_save(name)
        Metrostroi.Picket.Save()
    end

    local m_load = Metrostroi.Load
    function Metrostroi.Load(name, keep_signs)
        m_load(name,keep_signs)
        Metrostroi.Picket.Load()
    end
end)                                        --Окончание тела функции с задержкой

timer.Simple(2, Metrostroi.Picket.Load)
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

-- Logger --

local function log(message, category)
    if (Metrostroi.Logger) then
        Metrostroi.Logger.Log(message, category, "Slopes")
    end   
end

local function logError(message)
    log(message, "Error")
end

local function logInfo(message)
    log(message, "Info")
end

local filePath = "metrostroi_data/slope_"..game.GetMap()..".txt";

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

Metrostroi.Slope = {}

-- Load slopes.
function Metrostroi.Slope.Load()
    if (not checkFile(filePath)) then return end

    for _, ent in pairs(ents.FindByClass("gmod_track_slope")) do
        SafeRemoveEntity(ent) 
    end

    local data = loadFile(filePath)
    if not data then return end

    for k,v in pairs(data) do
        local ent = ents.Create("gmod_track_slope")
        if IsValid(ent) then
            ent:SetPos(v.Pos)
            ent:SetAngles(v.Angles)
            
            ent.Type = v.Type or 1
            ent.YOffset = v.YOffset or 0
            ent.ZOffset = v.ZOffset or 0
            ent.PAngle = v.PAngle or 0
            ent.YAngle = v.YAngle or 0
            ent.Value_u = v.Value_u or ""
            ent.Length = v.Length or ""
            ent:SendUpdate()
            ent:Spawn()
        end
    end

    logInfo("Pickets is loaded")
end 

-- Save slopes.
function Metrostroi.Slope.Save()
    local slopes = {}

    for _, ent in pairs(ents.FindByClass("gmod_track_slope")) do
        table.insert(slopes, {
            Pos = ent:GetPos(),
            Angles = ent:GetAngles(),
            Type = (ent.Type ~= 1) and ent.Type or nil,
            YOffset = (ent.YOffset ~= 0) and ent.YOffset or nil,
            ZOffset = (ent.ZOffset ~= 0) and ent.ZOffset or nil,
            PAngle = (ent.PAngle ~= 0) and ent.PAngle or nil,
            YAngle = (ent.YAngle ~= 0) and ent.YAngle or nil,
            Value_u = ent.Value_u,
            Length = ent.Length,w
        })
    end

    print("Metrostroi: Saving slopes definition...")

    if (not table.IsEmpty(slopes)) then
        saveFile(filePath, util.TableToJSON(slopes, true))
        print("Saved to "..filePath)
    else
        removeFile(filePath);
        print("File remove "..filePath)
    end
end

timer.Simple(1, function()                  --Задержка после загрузки игры
    local m_save = Metrostroi.Save
    function Metrostroi.Save(name)
        m_save(name)
        Metrostroi.Slope.Save()
    end

    local m_load = Metrostroi.Load
    function Metrostroi.Load(name, keep_signs)
        m_load(name,keep_signs)
        Metrostroi.Slope.Load()
    end
end)                                        --Окончание тела функции с задержкой

timer.Simple(2, Metrostroi.Slope.Load)
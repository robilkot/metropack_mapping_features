-----------------------------------------------------------------------
--                          Творческое объединение "MetroPack"
--	Скрипт написан в 2022 году для Metrostroi.
--	Реализует логгирование.
--	Автор: 	klusandr
--	Steam: 	https://steamcommunity.com/id/andr47/
--	VK:		https://vk.com/andreyklysevich
--  Дополнительная информация в файле lua/licence.lua
-----------------------------------------------------------------------

if (SERVER) then
    util.AddNetworkString("metrostroi-logger")

    local function sandToClient(message)
        net.Start("metrostroi-logger")
            net.WriteString(message)
        net.Broadcast()
    end
end

if (CLIENT) then
    net.Receive("metrostroi-logger", function(num, ply)
        print(net.ReadString())
    end)
end

local categorys = {
    "Info",
    "Trace",
    "Debufg",
    "Warning",
    "Error",
    "Critical"
}

Metrostroi.Logger = {}

Metrostroi.Logger.Categorys = categorys
Metrostroi.Logger.Enable = true
Metrostroi.CetegoryEnable = {
    ["Trace"] = false,
    ["Debug"] = false,
    ["Warning"] = true,
    ["Error"] = true,
    ["Critical"] = true,

}

function Metrostroi.Logger.Log(message, category, tag, client)
    local category = category or "Info"

    local log = ""
    local tags = { "Metrostroi" }

    if (table.HasValue(categorys, category)) then
        if (Metrostroi.CetegoryEnable[category] == false) then return end
    end

    if (tag) then
        if (type(tag) == "table") then
            table.Add(tags, tag)
        else
            table.insert(tags, tag)
        end
    end

    for _, t in ipairs(tags) do
        log = log.."["..t.."]"
    end

    if (category == "Info") then 
        category = ""
    else
        category = category.." - "
    end

    log = category..log..": "..message

    if (client and SERVER and not game.SinglePlayer()) then
        sandToClient(log)
    end

    print(log)
end

function Metrostroi.Logger.LogInfo(message, client)
    Metrostroi.Logger.Log(message, "Info", client)
end

function Metrostroi.Logger.LogTrace(message, client)
    Metrostroi.Logger.Log(message, "Trace", client)
end

function Metrostroi.Logger.LogDebug(message, client)
    Metrostroi.Logger.Log(message, "Debug", client)
end

function Metrostroi.Logger.LogWarning(message, client)
    Metrostroi.Logger.Log(message, "Warning", client)
end

function Metrostroi.Logger.LogError(message, client)
    Metrostroi.Logger.Log(message, "Error", client)
end

function Metrostroi.Logger.LogCritical(message, client)
    Metrostroi.Logger.Log(message, "Critical", client)
end


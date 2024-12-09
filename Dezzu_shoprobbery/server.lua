ESX = exports["es_extended"]:getSharedObject()
local cooldowns = {}
local webhook = Config.webhook.url
local currectCode = {}


local function getShopKey(coords)
    if coords then
        return string.format("%s:%s:%s", coords.x, coords.y, coords.z)
    else
        return nil
    end
end

local function getValueKey(coords)
    if coords then
        return string.format("%s:%s:%s", coords.x, coords.y, coords.z)
    else
        return nil
    end
end

function setCooldown(shopKey)
    cooldowns[shopKey] = os.time() + Config.shops.cooldownTime['shops']
end

function setCooldown(valueKey)
    cooldowns[valueKey] = os.time() + Config.shops.cooldownTime['value']    
end
function hasCooldown(shopKey, valueKey)
    local currentTime = os.time()
    local cooldownEnd = cooldowns[shopKey] or 0

    if valueKey then
        cooldownEnd = cooldowns[valueKey] or 0
    end

    return currentTime < cooldownEnd
end




RegisterNetEvent('Dezzu_shoprobbery:startRobbery')
AddEventHandler('Dezzu_shoprobbery:startRobbery', function(shopIndex)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local shopCoords = Config.shops.shop[shopIndex]
    local shopKey = getShopKey(shopCoords)

    if not hasCooldown(shopKey) then
        TriggerClientEvent('Dezzu_shoprobbery:notify', source,
            {
                title = 'Powiadomienie',
                description = 'Rozpoczynasz napad na sklep',
                type = 'Success'
            })
        TriggerClientEvent('Dezzu_shoprobbery:progressbar', source)
        setCooldown(shopKey)
    else
        TriggerClientEvent('Dezzu_shoprobbery:notify', source,
            {
                title = 'Okradanie zakończone',
                description = 'Poczekaj ' .. (cooldowns[shopKey] - os.time()) .. ' sekund zanim rozpoczniesz następny napad',
                type = 'error'
            })
    end
end)




RegisterNetEvent('Dezzu_shoprobbery:getrewards')
AddEventHandler('Dezzu_shoprobbery:getrewards', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local withinTarget = false
    local money = math.random(Config.shops.reward['shops']['min'], Config.shops.reward['shops']['max'])
    for i = 1, #Config.shops.shop do
        local targetCoords = Config.shops.shop[i]
        local distance = #(playerCoords - targetCoords)
        if distance < Config.shops.distance['shops'] then
            withinTarget = true
            xPlayer.addInventoryItem('money', money)
            sendLog(webhook, 66666, 'Shoprobbery', '[ID ' .. source .. '] ' .. GetPlayerName(source) .. ' ukradł ' .. money .. '$ ze sejfu')           
            setCooldown(source)
            break
        end
    end

    if not withinTarget then
        sendLog(webhook, 66666, 'Shoprobbery', '[ID ' .. source .. '] ' .. GetPlayerName(source) .. ' Gracz próbował oszukać skrypt')
        DropPlayer(source, 'Cheater!!!')
    end
    
end)


RegisterNetEvent('Dezzu_shoprobbery:startValue')
AddEventHandler('Dezzu_shoprobbery:startValue', function(valueIndex)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local valueCoords = Config.shops.value[valueIndex]
    local valueKey = getValueKey(valueCoords)

    if not hasCooldown(valueKey) then
        TriggerClientEvent('Dezzu_shoprobbery:notify', source,
            {
                title = 'Powiadomienie',
                description = 'Rozpoczynasz napad na sklep',
                type = 'Success'
            })
        TriggerClientEvent('Dezzu_shoprobbery:minigame', source)
        setCooldown(valueKey)
    else
        TriggerClientEvent('Dezzu_shoprobbery:notify', source,
            {
                title = 'Okradanie zakończone',
                description = 'Poczekaj ' .. (cooldowns[valueKey] - os.time()) .. ' sekund zanim rozpoczniesz następny napad',
                type = 'error'
            })
    end
end)


RegisterNetEvent('Dezzu_shoprobbery:getvalue')
AddEventHandler('Dezzu_shoprobbery:getvalue', function()
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local withinTarget = false
    local money = math.random(Config.shops.reward['value']['min'], Config.shops.reward['value']['max'])
    for i = 1, #Config.shops.value do
        local targetCoords = Config.shops.value[i]
        local distance = #(playerCoords - targetCoords)
        if distance < Config.shops.distance['value'] then
            withinTarget = true
            xPlayer.addInventoryItem('money', money)
            sendLog(webhook, 66666, 'Shoprobbery', '[ID ' .. source .. '] ' .. GetPlayerName(source) .. ' ukradł ' .. money .. '$ ze sejfu')           
            setCooldown(source)
            break
        end
    end

    if not withinTarget then
        sendLog(webhook, 66666, 'Shoprobbery', '[ID ' .. source .. '] ' .. GetPlayerName(source) .. ' Gracz próbował oszukać skrypt')
    end
    
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) 

        
        local currentTime = os.time()
        for source, cooldownEnd in pairs(cooldowns) do
            if currentTime >= cooldownEnd then
                cooldowns[source] = nil
            end
        end
    end
end)

function sendLog(webhook, color, name, message)
    local currentDate = os.date("%Y-%m-%d")
    local currentTime = os.date("%H:%M:%S")
    local embed = {
        {
            ["color"] = color,
            ["title"] = "**" .. tostring(name) .. "**",
            ["description"] = tostring(message),
            ["footer"] = {
                ["text"] = currentTime .. " " .. currentDate,
            },
        }
    }
    
    PerformHttpRequest(webhook, function(err, text, headers)
    end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end
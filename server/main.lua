-- Variables

--[[     add this to core

    function QBCore.Functions.GetQBPlayers()   -- add this function to the core if you dont have it
        return QBCore.Players
    end
    
    if PlayerData.metadata['paycheck'] ~= nil then     -- add this metadata to core / server / player 
        PlayerData.metadata['paycheck'] = {
            ["amount"] = PlayerData.metadata['paycheck']["amount"] or 0,
            ["ispaymentday"] = PlayerData.metadata['paycheck']["ispaymentday"] or false,
        }
    else
        PlayerData.metadata['paycheck'] = {
            ["amount"] = 0,
            ["ispaymentday"] = false,
            ["ispaid"] = false,
        }
    end

    self.Functions.PayCheck = function(amount, ispaymentday, ispaid)    -- add this function to core / server / player 
        if amount then 
            self.PlayerData.metadata['paycheck'] = {
                ["amount"] = tonumber(amount),
                ["ispaymentday"] = ispaymentday,
                ["ispaid"] = ispaid
            }
        else
            self.PlayerData.metadata['paycheck'] = {
                ["amount"] = self.PlayerData.metadata['paycheck']["amount"],
                ["ispaymentday"] = ispaymentday,
                ["ispaid"] = ispaid
            }
        end
        self.Functions.UpdatePlayerData()
    end

]]


---- Important   You need to disable this >>[ PaycheckLoop() ]<< function in core 

local QBCore = exports['qb-core']:GetCoreObject()

local PaymentDay = "Friday"  --- change this to whatever day you want
local TimeToAddSalary = 10
local PaycheckJobs = { -- jobs that gonna be paid throgh this system add whatever you want
    ["police"] = {dutyrequired = true}, -- if true then player must be on duty to get daily paiment
    ["tow"] = {dutyrequired = false},
}


function PaycheckLoop()
    local ToDay = os.date("%A")
    local Players = QBCore.Functions.GetQBPlayers()
    for _, Player in pairs(Players) do
        if PaycheckJobs[Player.PlayerData.job.name] then 
            local paycheckData = Player.PlayerData.metadata['paycheck']
            if ToDay == PaymentDay then  
                if not paycheckData["ispaid"] and not paycheckData["ispaymentday"] then 
                    paycheckData["amount"] = paycheckData["amount"] + Player.PlayerData.job.payment
                    Player.Functions.AddMoney('bank', paycheckData["amount"])
                    TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, 'You received your paycheck of $ '..paycheckData["amount"]..'', "success")
                    Player.Functions.PayCheck(0, true, true)
                else
                    if PaycheckJobs[Player.PlayerData.job.name].dutyrequired then
                        if Player.PlayerData.job.onduty then 
                            paycheckData["amount"] = paycheckData["amount"] + Player.PlayerData.job.payment
                            TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, '$ '..Player.PlayerData.job.payment..' Have been added to your paycheck balance and your current paycheck is $ '..paycheckData["amount"]..'', "success")
                        else
                            TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, 'You are not on duty no salary received', "error")
                        end
                    else
                        paycheckData["amount"] = paycheckData["amount"] + Player.PlayerData.job.payment
                        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, '$ '..Player.PlayerData.job.payment..' Have been added to your paycheck balance and your current paycheck is $ '..paycheckData["amount"]..'', "success")
                    end
                    Player.Functions.PayCheck(paycheckData["amount"], true, false)
                end
            else
                if PaycheckJobs[Player.PlayerData.job.name].dutyrequired then
                    if Player.PlayerData.job.onduty then 
                        paycheckData["amount"] = paycheckData["amount"] + Player.PlayerData.job.payment
                        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, '$ '..Player.PlayerData.job.payment..' Have been added to your paycheck balance and your current paycheck is $ '..paycheckData["amount"]..'', "success")
                    else
                        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, 'You are not on duty no salary received', "error")
                    end
                else
                    paycheckData["amount"] = paycheckData["amount"] + Player.PlayerData.job.payment
                    TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, '$ '..Player.PlayerData.job.payment..' Have been added to your paycheck balance and your current paycheck is $ '..paycheckData["amount"]..'', "success")
                end
                Player.Functions.PayCheck(paycheckData["amount"], false, false)
            end
        else
            Player.Functions.AddMoney('bank', Player.PlayerData.job.payment)
            TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, 'You received your paycheck of $ '..Player.PlayerData.job.payment..'', "success")
        end
        Wait(50)
    end
    --SetTimeout(TimeToAddSalary, PaycheckLoop)
    SetTimeout(TimeToAddSalary * (60 * 1000), PaycheckLoop)
end


QBCore.Commands.Add('paycheck', 'Check your current paycheck', {}, false, function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local paycheckData = Player.PlayerData.metadata['paycheck']
    TriggerClientEvent('QBCore:Notify', src, 'Your current paycheck $ '..paycheckData["amount"]..' payment day is '..PaymentDay..'', "success")
end)



Citizen.CreateThread(function()
    Wait(1000)
    PaycheckLoop() -- This just starts the paycheck system
end)
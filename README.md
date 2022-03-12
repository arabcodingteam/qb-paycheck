# qb-paycheck
```
# add this to core
```
function QBCore.Functions.GetQBPlayers()   -- add this function to the core if you dont have it
    return QBCore.Players
end
    
if PlayerData.metadata['paycheck'] ~= nil then     -- add this metadata to core / server / player 
  PlayerData.metadata['paycheck'] = {
    ["amount"] = PlayerData.metadata['paycheck']["amount"] or 0,
    ["ispaymentday"] = PlayerData.metadata['paycheck']["ispaymentday"] or false,
    ["ispaid"] = PlayerData.metadata['paycheck']["ispaid"] or false,
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
```

```
# Important   You need to disable this >>[ PaycheckLoop() ]<< function in core
```

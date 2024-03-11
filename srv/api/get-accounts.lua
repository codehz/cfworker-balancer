local Config = require 'config'

local config<close> = Config:new()
local accounts = {}
for account in config:getAccounts() do
  table.insert(accounts, account)
end
SetHeader('Content-Type', 'application/json, charset=utf-8')
Write(EncodeJson {data = accounts})

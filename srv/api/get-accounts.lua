local Config = require 'config'

local config<close> = Config:new()
local accounts = {}
for email, key in config:getAccounts() do
  table.insert(accounts, {email = email, key = key})
end
SetHeader('Content-Type', 'application/json, charset=utf-8')
Write(EncodeJson {data = accounts})

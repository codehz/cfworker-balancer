local Config = require 'config'

local config<close> = Config:new()
local domains = {}
for domain in config:getDomains() do
  table.insert(domains, domain)
end
SetHeader('Content-Type', 'application/json, charset=utf-8')
Write(EncodeJson {data = domains})

local M = {}
local unix = require 'unix'
local re = require 're'
local Cloudflare = require 'cloudflare'
local go = require 'go'
local Config = require 'config'

local ExtractDomain = re.compile [[^([^/]+)/\*]]
local config = Config:new()

local function worker(info)
  local instance = Cloudflare:new(info)
  local config<close> = Config:new()
  local zones = instance:listZones()
  local result = {}
  for _, zone in ipairs(zones) do
    local filters = instance:listWorkerFilters(zone.id)
    for _, filter in ipairs(filters) do
      local matched, domain = ExtractDomain:search(filter.pattern)
      if matched then
        result[zone.id] = {domain = domain}
        break
      end
    end
  end
  local stats = instance:getUsage()
  for k, v in pairs(stats) do if result[k] then result[k].usage = v end end
  config:updateDomains(info.email, function(update)
    for _, v in pairs(result) do update(v.domain, v.usage) end
  end)
  Log(kLogInfo, 'updated %s' % {info.email})
end

Config.setup()

return function ()
  collectgarbage "stop"
  for account in config:getAccounts() do
    go(worker, account)
  end
  collectgarbage "restart"
end

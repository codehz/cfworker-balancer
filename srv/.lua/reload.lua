local M = {}
local unix = require 'unix'
local re = require 're'
local Cloudflare = require 'cloudflare'
local go = require 'go'
local config = require 'config'
local sharedstate = require 'sharedstate'

local ExtractDomain = re.compile [[^([^/]+)/\*]]

local function worker(info)
  local instance = Cloudflare:new(info)
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
  for _, v in pairs(result) do
    sharedstate.put(info.email, v.domain, v.usage)
    Log(kLogInfo, 'updated %s: %s (%d)' % {info.email, v.domain, v.usage})
  end
end

return function()
  collectgarbage 'stop'
  for idx, account in ipairs(config.accounts) do go(worker, account) end
  collectgarbage 'restart'
end

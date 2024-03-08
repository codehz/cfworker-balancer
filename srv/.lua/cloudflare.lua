local M = {}

local endpoint = 'https://api.cloudflare.com/client/v4'

function M:new(o)
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:_get(name)
  local status, headers, body = assert(Fetch(endpoint .. '/' .. name, {
    headers = {
      ['X-Auth-Email'] = self.email,
      ['X-Auth-Key'] = self.key,
      ['Content-Type'] = 'application/json'
    }
  }))
  local res = assert(DecodeJson(body))
  if res.success == false then error(EncodeLua(res.errors)) end
  return res.result
end

function M:_graphql(query, varaiables)
  local status, headers, body = assert(Fetch(endpoint .. '/graphql', {
    method = 'POST',
    body = EncodeJson {query = query, variables = varaiables},
    headers = {
      ['X-Auth-Email'] = self.email,
      ['X-Auth-Key'] = self.key,
      ['Content-Type'] = 'application/json'
    }
  }))
  if not status then error(headers) end
  local res = DecodeJson(body)
  if res.errors then error(EncodeLua(res.errors)) end
  return res.data
end

function M:listAccount() return self:_get('accounts') end

function M:listZones() return self:_get('zones') end

function M:listWorkerFilters(zone)
  return self:_get('zones/%s/workers/filters' % {zone})
end

function M:getUsage()
  local res = self:_graphql([[
    {
      viewer {
        zones {
          zoneTag
          httpRequests1dGroups(filter: {date_gt: $date}, limit: 1, orderBy: [date_DESC]) {
            dimensions {
              date
            }
            sum {
              requests
            }
          }
        }
      }
    }
  ]], {date = os.date('%Y-%m-%d', os.time() - 86400)})
  local stats = {}
  for _, zone in ipairs(res.viewer.zones) do
    for _, group in ipairs(zone.httpRequests1dGroups) do
      stats[zone.zoneTag] = group.sum.requests
      break
    end
  end
  return stats
end

return M

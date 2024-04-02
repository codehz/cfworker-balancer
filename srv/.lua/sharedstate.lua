local shared = require 'shared'
local M = {}

function M.get(email)
  return shared.load()[email]
end

function M.put(email, domain, usage)
  shared.modify(function (old)
    old[email] = {
      domain = domain,
      usage = usage,
      updated_at = GetTime()
    }
  end)
end

function M.delete(email)
  shared.modify(function (old)
    table.remove(old, email)
  end)
end

function M.all()
  local result = {}
  for k, v in pairs(shared.load()) do
    v.email = k
    table.insert(result, v)
  end
  return result
end

function M.getMinUsageDomain()
  local min = 90000
  local domain = nil
  for _, v in pairs(shared.load()) do
    if v then if v.usage < min then min, domain = v.usage, v.domain end end
  end
  return domain
end

return M
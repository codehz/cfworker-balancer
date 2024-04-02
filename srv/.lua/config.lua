local TOML = require 'toml'
local shared = require 'shared'

local config = {}

local M = {}

local proxy = setmetatable({}, M)

local version = shared.version()

function deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in pairs(orig) do
      copy[orig_key] = deepcopy(orig_value)
    end
  else
    copy = orig
  end
  return copy
end

function M.autoreload()
  local cur = shared.version()
  if version ~= cur then M.reload() end
  return cur
end

function M.reload()
  version = shared.version()
  local content = Slurp 'config.toml'

  if content then
    config = TOML.parse(content)
  else
    config = {admin = {secret = 'secret'}}
  end
  Log(kLogInfo, 'Reloading config: ' .. EncodeLua(config))
end

function M.save()
  local copied = deepcopy(config)
  local encoded = TOML.encode(copied)
  Barf('config.toml', encoded)
  shared.updateVersion()
end

function M:__index(key)
  if config[key] then
    return config[key]
  end
  if key == 'accounts' or key == 'alist' then
    config[key] = {}
    return config[key]
  end
  return M[key]
end

function M:__newindex(key, value)
  config[key] = value
end

function M.deleteAccount(email)
  for i, v in ipairs(proxy.accounts) do
    if v.email == email then
      table.remove(proxy.accounts, i)
      M.save()
      return
    end
  end
end

function M.putAccount(email, key)
  for i, v in ipairs(proxy.accounts) do
    if v.email == email then
      v.key = key
      M.save()
      return
    end
  end
  table.insert(proxy.accounts, {email = email, key = key})
  M.save()
end

M.reload()

return proxy

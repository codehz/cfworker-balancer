local mem = unix.mapshared(1024 * 1024)
local M = {}

local LOCK = 0
local VERSION = 1

local L = {}

local pesudo = setmetatable({}, L)

local function Lock()
  local ok, old = mem:cmpxchg(LOCK, 0, 1)
  if not ok then
    if old == 1 then old = mem:xchg(LOCK, 2) end
    while old > 0 do
      mem:wait(LOCK, 2)
      old = mem:xchg(LOCK, 2)
    end
  end
  return pesudo
end

local function Unlock()
  old = mem:fetch_add(LOCK, -1)
  if old == 2 then
    mem:store(LOCK, 0)
    mem:wake(LOCK, 1)
  end
end

function L:__close() Unlock() end

function M.store(value)
  local encoded = EncodeJson(value)
  Lock()
  mem:write(1024, encoded)
  Unlock()
end

function M.load()
  Lock()
  local data = mem:read(1024)
  Unlock()
  if #data == 0 then return {} end
  return DecodeJson(data)
end

function M.modify(fn)
  local lock<close> = Lock()
  local data = mem:read(1024)
  local old = {}
  if #data > 0 then old = DecodeJson(data) end
  local new = fn(old)
  local encoded = EncodeJson(new or old)
  mem:write(1024, encoded)
  return new
end

function M.version()
  return mem:load(VERSION)
end

function M.updateVersion()
  return mem:fetch_add(VERSION, 1) + 1
end

return M

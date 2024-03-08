local sql = require 'lsqlite3'
local M = {}

function M:new()
  local db = assert(sql.open 'config.db')
  db:busy_timeout(1000)
  db:exec [[PRAGMA foreign_keys=ON]]
  db:exec [[PRAGMA journal_mode=WAL]]
  db:exec [[PRAGMA synchronous=NORMAL]]
  local o = {db = db}
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:getConfig(key)
  if not self._getConfig then
    self._getConfig =
      self.db:prepare [[SELECT value FROM config WHERE key = ?1]]
  end
  self._getConfig:reset()
  self._getConfig:bind(1, key)
  for value in self._getConfig:urows() do return value, nil end
  return nil, 'key not found: ' .. key
end

function M:getAccounts() return self.db:urows [[SELECT * FROM accounts]] end

function M:updateDomain(domain, usage)
  local stmt = assert(self.db:prepare [[
    INSERT INTO domains (domain, usage)
    VALUES (?1, ?2)
    ON CONFLICT(domain) DO UPDATE SET usage = ?2
  ]])
  stmt:reset()
  stmt:bind(1, domain)
  stmt:bind(2, usage)
  if sql.DONE ~= stmt:step() then error 'failed to update domain' end
end

function M:getMinUsageDomain()
  local stmt = assert(self.db:prepare [[
    SELECT domain, usage FROM domains
    WHERE usage < 90000
    ORDER BY usage
    LIMIT 1
  ]])
  stmt:reset()
  for domain, usage in stmt:urows() do return domain, usage end
  return nil, 'no domain found'
end

function M:__close()
  self.db:close_vm()
  self.db:close()
end

function M.setup()
  Log(kLogInfo, 'setup config.db')
  local db = sql.open 'config.db'
  db:busy_timeout(1000)
  db:exec [[PRAGMA foreign_keys=ON]]
  db:exec [[PRAGMA journal_mode=WAL]]
  db:exec [[PRAGMA synchronous=NORMAL]]
  db:exec [[
    CREATE TABLE IF NOT EXISTS config (
      key TEXT PRIMARY KEY,
      value ANY NOT NULL
    ) WITHOUT ROWID
  ]]
  db:exec [[
    CREATE TABLE IF NOT EXISTS accounts (
      email TEXT PRIMARY KEY,
      key TEXT NOT NULL
    ) WITHOUT ROWID
  ]]
  db:exec [[
    CREATE TABLE IF NOT EXISTS domains (
      domain TEXT PRIMARY KEY,
      usage INTEGER NOT NULL DEFAULT 0,
      updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) WITHOUT ROWID
  ]]
  db:exec [[
    CREATE TRIGGER IF NOT EXISTS update_domains_updated_at
    AFTER UPDATE ON domains
    FOR EACH ROW BEGIN
      UPDATE domains
      SET updated_at = CURRENT_TIMESTAMP;
    END
  ]]
  db:close();
end

return M

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

function M:prepare(sql)
  local stmt = self.db:prepare(sql)
  if not stmt then error(self.db:errmsg(), 2) end
  return stmt
end

function M:getConfig(key)
  if not self._getConfig then
    self._getConfig = self:prepare [[SELECT value FROM config WHERE key = ?1]]
  end
  self._getConfig:reset()
  self._getConfig:bind(1, key)
  for value in self._getConfig:urows() do return value, nil end
  return nil, 'key not found: ' .. key
end

function M:putConfig(key, value)
  if not self._putConfig then
    self._putConfig =
      self:prepare [[INSERT INTO config (key, value) VALUES (?1, ?2) ON CONFLICT(key) DO UPDATE SET value = ?2]]
  end
  self._putConfig:reset()
  self._putConfig:bind(1, key)
  self._putConfig:bind(2, value)
  assert(self._putConfig:step() == sql.DONE)
end

function M:getAccounts() return self.db:nrows [[SELECT * FROM accounts]] end

function M:getDomains() return self.db:nrows [[SELECT * FROM account_domains]] end

function M:putAccount(email, key)
  if not self._putAccount then
    self._putAccount =
      self:prepare [[INSERT INTO accounts (email, key) VALUES (?1, ?2) ON CONFLICT(email) DO UPDATE SET key = ?2]]
  end
  self._putAccount:reset()
  self._putAccount:bind(1, email)
  self._putAccount:bind(2, key)
  assert(self._putAccount:step() == sql.DONE)
end

function M:deleteAccount(email)
  if not self._deleteAccount then
    self._deleteAccount = self:prepare [[DELETE FROM accounts WHERE email = ?1]]
  end
  self._deleteAccount:reset()
  self._deleteAccount:bind(1, email)
  assert(self._deleteAccount:step() == sql.DONE)
end

function M:updateDomains(email, cb)
  local delete = self:prepare [[DELETE FROM account_domains WHERE email = ?1]]
  local insert =
    self:prepare [[INSERT INTO account_domains (email, domain, usage, updated_at) VALUES (?1, ?2, ?3, ?4)]]
  local db = self.db
  local function update(domain, usage)
    local time = GetTime()
    insert:reset()
    insert:bind_values(email, domain, usage, time)
    if sql.DONE ~= insert:step() then
      error('failed to update domain: %s' % {db:errmsg()})
    end
    Log(kLogInfo, 'updated domain %s %s %s %s' % {email, domain, usage, time})
  end
  self.db:exec [[BEGIN IMMEDIATE]]
  local status, err = pcall(function()
    delete:reset()
    delete:bind(1, email)
    if sql.DONE ~= delete:step() then
      error('failed to delete domains: %s' % {db:errmsg()})
    end
    cb(update)
  end)
  if status then
    self.db:exec [[COMMIT]]
  else
    self.db:exec [[ROLLBACK]]
    error(err)
  end
end

function M:getMinUsageDomain()
  local stmt = assert(self:prepare [[
    SELECT domain, usage FROM account_domains
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
    CREATE TABLE IF NOT EXISTS account_domains (
      email TEXT NOT NULL,
      domain TEXT NOT NULL,
      usage INTEGER NOT NULL DEFAULT 0,
      updated_at NUMBER DEFAULT 0,
      PRIMARY KEY (email, domain),
      FOREIGN KEY (email) REFERENCES accounts(email) ON DELETE CASCADE
    )
  ]]
  db:exec [[
    CREATE INDEX IF NOT EXISTS account_domains_email_index
    ON account_domains(email)
  ]]
  db:close();
end

return M

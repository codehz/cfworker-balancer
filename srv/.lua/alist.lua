local re = require 're'
local config = require 'config'
local sharedstate = require 'sharedstate'

local function FetchJson(...)
  local status, headers, body = assert(Fetch(...))
  if status ~= 200 then error(body) end
  return assert(DecodeJson(body))
end

local M = {}

function M:new()
  local token = config.alist.token
  local address = config.alist.address
  local o = {
    token = token,
    address = address,
    sign = GetParam('sign'),
    path = GetPath()
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function M:verify()
  local _, expire = assert(self.sign:match('([^:]+):([^:]+)'))
  local parsed = tonumber(expire)
  if parsed > 0 and parsed < GetTime() then error 'token expired' end
  local input = '%s:%s' % {self.path, expire}
  local rawhash = GetCryptoHash('SHA256', input, self.token)
  local hash = EncodeBase64(rawhash):gsub('+', '-'):gsub('/', '_')
  local encoded = '%s:%s' % {hash, expire}
  if encoded ~= self.sign then error 'token invalid' end
end

function M:direct()
  local link = FetchJson(self.address .. '/api/fs/link', {
    method = 'POST',
    headers = {
      ['Content-Type'] = 'application/json',
      Authorization = self.token
    },
    body = EncodeJson {path = self.path}
  })
  ServeRedirect(302, link.data.url)
end

return function()
  local alist<close> = M:new()
  local IpCountry = GetHeader('CF-IPCountry')
  Log(kLogInfo, 'RemoteIp: %s' % {GetRemoteAddr() or '(nil)'})
  Log(kLogInfo, 'CF-IPCountry: %s' % {IpCountry or '(nil)'})
  alist:verify()
  if IpCountry == 'CN' then
    local domain = sharedstate.getMinUsageDomain()
    if domain then
      ServeRedirect(302, EncodeUrl {
        scheme = 'https',
        host = domain,
        path = alist.path,
        params = {{'sign', alist.sign}}
      })
      return
    end
  end
  alist:direct()
end

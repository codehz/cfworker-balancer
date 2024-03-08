local Config = require 'config'

local function verifyBasicAuth(auth, secret)
  local hashed = auth:match('Basic (%g+)')
  if not hashed then error 'invalid authorization header' end
  local user, pass = assert(DecodeBase64(hashed):match('^([^:]+):([^:]+)$'))
  if user ~= 'admin' or pass ~= secret then error 'invalid secret' end
  return function()
    SetCookie('secret', secret, {HttpOnly = true, SameSite = 'Lax'})
  end
end

local function verifyCookie(auth, secret)
  if auth ~= secret then error 'invalid secret' end
  return function() end
end

return function()
  local config<close> = Config:new()
  local secret = config:getConfig 'secret' or 'secret'
  local basicauth = GetHeader('Authorization')
  if basicauth then return verifyBasicAuth(basicauth, secret) end
  local cookie = GetCookie('secret')
  if cookie then return verifyCookie(cookie, secret) end
  error 'authorization required'
end

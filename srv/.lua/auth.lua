local config = require 'config'

local function verifyBasicAuth(auth, secret)
  local hashed = auth:match('Basic (%g+)')
  if not hashed then error 'invalid authorization header' end
  local user, pass = assert(DecodeBase64(hashed):match('^([^:]+):([^:]+)$'))
  if user ~= 'admin' or pass ~= secret then
    error('invalid secret: %s != %s' % {pass, secret})
  end
end

return function()
  local secret = config.admin.secret
  local basicauth = GetHeader('Authorization')
  if basicauth then return verifyBasicAuth(basicauth, secret) end
  error 'authorization required'
end

local config = require 'config'

local secret = GetParam('secret')
if not secret then error 'secret required' end
config.admin.secret = secret
config.save()
SetStatus(303)
SetHeader('Location', '/')
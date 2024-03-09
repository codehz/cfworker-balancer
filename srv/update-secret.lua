local Config = require 'config'

local secret = GetParam('secret')
if not secret then error 'secret required' end
local config<close> = Config:new()
config:putConfig('secret', secret)
SetStatus(303)
SetHeader('Location', '/')
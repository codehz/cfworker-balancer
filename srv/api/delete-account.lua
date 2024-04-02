local config = require 'config'
local sharedstate = require 'sharedstate'

local email = assert(GetParam('email'), 'Email is required')

config.deleteAccount(email)
sharedstate.delete(email)

SetHeader('Content-Type', 'application/json, charset=utf-8')
Write(EncodeJson {data = 'ok'})

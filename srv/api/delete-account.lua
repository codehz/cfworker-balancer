local Config = require 'config'

local config<close> = Config:new()
local email = assert(GetParam('email'), 'Email is required')

config:deleteAccount(email)

SetHeader('Content-Type', 'application/json, charset=utf-8')
Write(EncodeJson {data = 'ok'})

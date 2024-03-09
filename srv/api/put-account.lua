local Config = require 'config'

local config<close> = Config:new()
local email = assert(GetParam('email'), 'Email is required')
local key = assert(GetParam('key'), 'Key is required')

config:putAccount(email, key)

SetHeader('Content-Type', 'application/json, charset=utf-8')
Write(EncodeJson {data = 'ok'})

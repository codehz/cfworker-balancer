local Config = require 'config'

local config<close> = Config:new()
local address = assert(GetParam('address'), 'Address is required')
local token = assert(GetParam('token'), 'Token is required')

config:putConfig('alist-address', address)
config:putConfig('alist-token', token)

SetHeader('Content-Type', 'application/json, charset=utf-8')
Write(EncodeJson {data = 'ok'})

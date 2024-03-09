local Config = require 'config'

local config<close> = Config:new()
local address = config:getConfig 'alist-address' or ''
local token = config:getConfig 'alist-token' or ''
SetHeader('Content-Type', 'application/json, charset=utf-8')
Write(EncodeJson {data = {address = address, token = token}})

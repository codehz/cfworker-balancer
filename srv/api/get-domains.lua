local sharedstate = require 'sharedstate'

local domains = sharedstate.all()
SetHeader('Content-Type', 'application/json, charset=utf-8')
Write(EncodeJson {data = domains})

local config = require 'config'

config.alist.address = assert(GetParam('address'), 'Address is required')
config.alist.token = assert(GetParam('token'), 'Token is required')
config.save()

SetHeader('Content-Type', 'application/json, charset=utf-8')
Write(EncodeJson {data = 'ok'})

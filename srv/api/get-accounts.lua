local config = require 'config'

SetHeader('Content-Type', 'application/json, charset=utf-8')
Write(EncodeJson {data = config.accounts})

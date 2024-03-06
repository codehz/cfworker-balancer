local Config = require 'config'
local config<close> = Config:new()
local token = assert(config:getConfig 'alist-token')
local unparsed = assert(arg[1], 'you need provide a url')
local url = ParseUrl(unparsed)
local path = url.path
local rawhash = GetCryptoHash('SHA256', path, token)
local hash = EncodeBase64(rawhash):gsub('+', '-'):gsub('/', '_')
local encoded = '%s?sign=%s:0' % {path, hash}
print(encoded)

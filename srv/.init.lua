local reload = require 'reload'
local alist = require 'alist'
local auth = require 'auth'
local config = require 'config'

ProgramBrand('Cloudflare Worker Balancer')

function OnServerStart()
  ProgramTrustedIp(ParseIp("103.21.244.0"), 22)
  ProgramTrustedIp(ParseIp("103.22.200.0"), 22)
  ProgramTrustedIp(ParseIp("103.31.4.0"), 22)
  ProgramTrustedIp(ParseIp("104.16.0.0"), 13)
  ProgramTrustedIp(ParseIp("104.24.0.0"), 14)
  ProgramTrustedIp(ParseIp("108.162.192.0"), 18)
  ProgramTrustedIp(ParseIp("131.0.72.0"), 22)
  ProgramTrustedIp(ParseIp("141.101.64.0"), 18)
  ProgramTrustedIp(ParseIp("162.158.0.0"), 15)
  ProgramTrustedIp(ParseIp("172.64.0.0"), 13)
  ProgramTrustedIp(ParseIp("173.245.48.0"), 20)
  ProgramTrustedIp(ParseIp("188.114.96.0"), 20)
  ProgramTrustedIp(ParseIp("190.93.240.0"), 20)
  ProgramTrustedIp(ParseIp("197.234.240.0"), 22)
  ProgramTrustedIp(ParseIp("198.41.128.0"), 17)
end

function OnProcessDestroy()
  config.autoreload()
end

function OnServerHeartbeat()
  config.autoreload()
  reload()
end

function OnHttpRequest()
  config.autoreload()
  if GetParam('sign') then return alist() end
  local status, err = pcall(auth)
  if not status then
    Log(kLogError, err)
    SetStatus(401)
    SetHeader('Content-Type', 'application/json; charset=utf-8')
    SetHeader('WWW-Authenticate', 'Basic realm="admin", charset="UTF-8"')
    Write(EncodeJson {error = err})
    return
  end
  Route()
end

ProgramHeartbeatInterval(1000 * 60 * 5)

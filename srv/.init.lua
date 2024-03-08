local reload = require 'reload'
local alist = require 'alist'
local auth = require 'auth'

ProgramBrand('Cloudflare Worker Balancer')

function OnServerHeartbeat()
  reload()
end

function OnHttpRequest()
  if GetParam('sign') then return alist() end
  local status, res = pcall(auth)
  if not status then
    SetStatus(401)
    SetHeader('Content-Type', 'application/json; charset=utf-8')
    SetHeader('WWW-Authenticate', 'Basic realm="admin", charset="UTF-8"')
    if GetCookie('secret') then
      SetCookie('secret', 'deleted', {Expires = 0})
    end
    Write(EncodeJson {error = res})
    return
  end
  Route()
  res()
end

ProgramHeartbeatInterval(1000 * 60 * 5)

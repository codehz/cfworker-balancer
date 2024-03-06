local reload = require 'reload'
local alist = require 'alist'

ProgramBrand('Cloudflare Worker Balancer')

function OnServerHeartbeat()
  reload.reload()
end

function OnHttpRequest()
  if GetParam('sign') then return alist() end
  Route()
end

ProgramHeartbeatInterval(1000 * 60 * 5)

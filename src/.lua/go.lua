local unix = require 'unix'

return function(func, ...)
  local child = assert(unix.fork())
  if child == 0 then
    func(...)
    unix.exit(0)
  end
end

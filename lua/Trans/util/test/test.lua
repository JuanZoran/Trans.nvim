local M = {}

local a = {
    b = 'test',
}

local c = a
c.b = 'notest'



print(a.b)
return M

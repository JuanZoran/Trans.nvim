local M = {}

M.test = {
    'test1',
    'test1',
    'test1',
    'test1',
}


function M.tmp (start, stop)
    if start > stop then
        return
    end

    local value = M.test[start]
    start = start + 1
    return function ()

        return start
    end
end
-- function M:tmp(index)
-- end

for v in M.tmp, 1, #M.test do
    print(v)
end

-- for i,n in square,3,0
-- do
--    print(i,n)
-- end

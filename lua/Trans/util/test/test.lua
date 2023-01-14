-- 记录开始时间
local starttime = os.clock(); --> os.clock()用法

local function pw(str)
    -- local res = vim.fn.strdisplaywidth(str)
    local res = vim.fn.strwidth(str)
    print(res)
end

pw('n. either extremity of something that has length')
pw('n.the point in time at which something ends')
pw('n.the concluding parts of an event or occurrence')
pw('n.a final part or section')
-- 48
-- 43
-- 48
-- 25




-- 记录结束时间
local endtime = os.clock(); --> os.clock()用法
print(string.format("end time   : %.4f", endtime));
print(string.format("cost time  : %.4f", endtime - starttime));

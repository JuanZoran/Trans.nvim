-- 记录开始时间
local starttime = os.clock(); --> os.clock()用法

local str = 'test'
local len = #str

for i = 1, 100000000 do
    local size = len
end

-- 记录结束时间
local endtime = os.clock(); --> os.clock()用法
print(string.format("end time   : %.4f", endtime));
print(string.format("cost time  : %.4f", endtime - starttime));

-- 记录开始时间
local starttime = os.clock(); --> os.clock()用法

for i = 1, 10, 2 do
    print(i)
end


-- 记录结束时间
local endtime = os.clock(); --> os.clock()用法
print(string.format("end time   : %.4f", endtime));
print(string.format("cost time  : %.4f", endtime - starttime));

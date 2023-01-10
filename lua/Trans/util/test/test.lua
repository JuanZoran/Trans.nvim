local a = {
    'test1',
    'test2',
    'test3'
}


local function test(tmp)
    tmp = {
        'bbbbbb'
    }
end


test(a)
for i, v in ipairs(a) do
    print(v)
end

local M = {}

local exchange_map = {
    p = '过去式',
    d = '过去分词',
    i = '现在分词',
    r = '形容词比较级',
    t = '形容词最高级',
    s = '名词复数形式',
    f = '第三人称单数',
    ['0'] = '词根',
    ['1'] = '词根的变化形式',
    ['3'] = '第三人称单数',
}

M.component = function(field)
    -- TODO
    if field.exchange and field.exchange ~= '' then
        local ref = {
            { '词型变化', 'TransRef' },
        }
        local exchanges = {
            needformat = true,
            highlight = 'TransExchange',
            indent = 4,
            emptyline = true,
        }

        for _exchange in vim.gsplit(field.exchange, '/', true) do
            local prefix = exchange_map[_exchange:sub(1, 1)]
            if prefix then
                local exchange = prefix .. _exchange:sub(2)
                -- local exchange = exchange_map[_exchange:sub(1, 1)] .. _exchange:sub(2)
                table.insert(exchanges, exchange)

            else
                error('add exchange_map for [' .. _exchange .. ']')
            end
        end

        return { ref, exchanges }
    end
end

return M

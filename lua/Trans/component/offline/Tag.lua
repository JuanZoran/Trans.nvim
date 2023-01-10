local M = {}

local tag_map = {
    zk = '中考',
    gk = '高考',
    ky = '考研',
    cet4 = '四级',
    cet6 = '六级',
    ielts = '雅思',
    toefl = '托福',
    gre = 'GRE',
}

---从查询结果中获取字符串
---@param field table 查询的结果
---@return component? component 提取的组件信息[包含多个组件]
M.component = function(field)
    -- TODO
    if field.tag and field.tag ~= '' then
        local ref = {
            { '标签:', 'TransRef' },
        }

        local tags = {
            needformat = true,
            highlight = 'TransTag',
            indent = 4,
            emptyline = true,
        }

        for _tag in vim.gsplit(field.tag, ' ', true) do
            local tag = tag_map[_tag]

            if tag then
                table.insert(tags, tag)
            else
                error('add tag_map for [' .. _tag .. ']')
            end
        end

        return { ref, tags }
    end
end


return M

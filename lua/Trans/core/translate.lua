local Trans = require 'Trans'

local function process(opts)
    opts = opts or {}
    opts.mode = opts.mode or vim.fn.mode()
    local str = Trans.util.get_str(opts.mode)
    opts.str = str


    if not str or str == '' then
        Trans.debug 'No string to translate'
        return
    end


    if opts.from == nil and opts.to == nil then
        -- INFO : Default support [zh -> en] or [en -> zh]
        if Trans.util.is_english(str) then
            opts.from = 'en'
            opts.to = 'zh'
        else
            opts.from = 'zh'
            opts.to = 'en'
        end
    end
    assert(opts.from and opts.to, 'opts.from and opts.to must be set at the same time')

    opts.is_word = opts.is_word or Trans.util.is_word(str)


    -- Find in cache
    if Trans.cache[str] then
        local data = Trans.cache[str]
        return data.frontend:process(data)
    end




    -- Create new data
    local data = Trans.data.new(opts)
    if Trans.strategy[data.frontend.opts.query](data) then
        Trans.cache[data.str] = data
        data.frontend:process(data)
    else
        data.frontend:fallback()
    end
end


---@class TransDataOption
---@field mode string?
---@field frontend string?
---@field from string? @Source language type
---@field to string? @Target language type
---@field is_word? boolean @Is the str a word



--- NOTE : Use coroutine to stop and resume the process (for animation)

---@class Trans
---@field translate fun(opts: TransDataOption?) Translate string core function
return function(...) coroutine.wrap(process)(...) end

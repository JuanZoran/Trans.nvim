---@class Trans
---@field install fun() Download database and tts dependencies
return function()
    local Trans = require 'Trans'
    local fn = vim.fn
    -- INFO :Check ultimate.db exists
    local dir = Trans.conf.dir
    local path = dir .. '/ultimate.db'

    if fn.isdirectory(dir) == 0 then
        fn.mkdir(dir, 'p')
    end

    if fn.filereadable(path) == 1 then
        vim.notify('Database already exists', vim.log.WARN)
        return
    end

    -- INFO :Download ultimate.db
    local uri = 'https://github.com/skywind3000/ECDICT-ultimate/releases/download/1.0.0/ecdict-ultimate-sqlite.zip'
    local zip = dir .. '/ultimate.zip'
    local continue = fn.filereadable(zip) == 1
    local handle = function(output)
        if output.exit == 0 and fn.filereadable(zip) then
            local cmd =
                Trans.system == 'win' and
                string.format('powershell.exe -Command "Expand-Archive -Force %s %s"', zip, dir) or
                fn.executable('unzip') == 1 and string.format('unzip %s -d %s', zip, dir) or
                error('unzip not found, Please unzip ' .. zip .. ' manually')
            local status = os.execute(cmd)
            os.remove(zip)
            if status == 0 then
                vim.notify('Download database successfully', vim.log.INFO)
                return
            end
        end

        local debug_message = 'Download database failed:' .. vim.inspect(output)
        vim.notify(debug_message, vim.log.ERROR)
    end

    Trans.curl.get(uri, {
        output   = zip,
        callback = handle,
        extra    = continue and { '-C', '-' } or nil,
    })

    local message = continue and 'Continue download database' or 'Begin to download database'
    vim.notify(message, vim.log.levels.INFO)
end

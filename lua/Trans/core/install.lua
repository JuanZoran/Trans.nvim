---@class Trans
---@field install fun() Download database and tts dependencies
return function()
    local Trans = require('Trans')
    -- INFO :Check ultimate.db exists
    local dir = Trans.conf.dir
    local path = dir .. '/ultimate.db'

    local fn = vim.fn
    if fn.isdirectory(dir) == 0 then
        fn.mkdir(dir, 'p')
    end

    if fn.filereadable(path) == 1 then
        vim.notify('Database already exists', vim.log.WARN)
        return
    end

    vim.notify('Trying to download database', vim.log.INFO)

    -- INFO :Download ultimate.db
    local uri = 'https://github.com/skywind3000/ECDICT-ultimate/releases/download/1.0.0/ecdict-ultimate-sqlite.zip'
    local zip = dir .. '/ultimate.zip'
    if fn.filereadable(zip) then os.remove(zip) end

    local handle = function(output)
        if output.exit == 0 and fn.filereadable(zip) then
            if fn.executable('unzip') == 0 then
                vim.notify('unzip not found, Please unzip ' .. zip .. 'manually', vim.log.ERROR)
                return
            end

            local cmd = string.format('unzip %s -d %s', zip, dir)
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
        output = zip,
        callback = handle,
    })

    -- INFO : Install tts dependencies
    if fn.has('linux') == 0 and fn.has('mac') == 0 then
        os.execute('cd ./tts/ && npm install')
    end
end

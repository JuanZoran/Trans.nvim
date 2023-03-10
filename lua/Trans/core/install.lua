return function()
    -- INFO :Chceck ultimate.db exists
    local dir = require('Trans').conf.dir
    local path = dir .. '/ultimate.db'
    if vim.fn.filereadable(path) == 1 then
        vim.notify('Database already exists', vim.log.WARN)
        return
    else
        vim.notify('Trying to download database', vim.log.INFO)
    end


    -- INFO :Download ultimate.db
    local uri = 'https://github.com/skywind3000/ECDICT-ultimate/releases/download/1.0.0/ecdict-ultimate-sqlite.zip'
    local loc = dir .. '/ultimate.zip'
    require('plenary.curl').get(uri, {
        output = loc,
        callback = function(output)
            if output.exsit == 0 and output.status == 200 then
                if vim.fn.executable('unzip') == 0 then
                    vim.notify('unzip not found, Please unzip ' .. loc .. 'manually', vim.log.ERROR)
                    return
                end

                local cmd = string.format('unzip %s -d %s', path, dir)
                os.execute(cmd)
                os.remove(path)

                vim.notify('Download database successfully', vim.log.INFO)
                return
            end

            local debug_message = 'Download database failed:' .. vim.inspect(output)
            vim.notify(debug_message, vim.log.ERROR)
        end,
    })

    -- INFO : tts dependencies
    if vim.fn.has('linux') == 0 and vim.fn.has('mac') == 0 then
        os.execute('cd ./tts/ && npm install')
    end
end

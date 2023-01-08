local tmp = {
    '1111',
    '2222',
    '3333',
    interval = 4,
}

print(table.concat(tmp, (' '):rep(tmp.interval)))

.PHONE: test

test:
	nvim --headless --noplugin -u scripts/minimal_init.vim -c "PlenaryBustedDirectory lua/test/  { minimal_init = './scripts/minimal_init.vim' }" -c 'qa!'

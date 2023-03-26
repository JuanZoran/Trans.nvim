.PHONE: test

test:
	@nvim --headless -c "lua require'plenary'" -c "PlenaryBustedDirectory lua/test/"

all:
	@echo there is nothing to do

clean:
	@echo there is nothing to do

clean-backup:
	rm -rf $(wildcard ~/*_before_shiropro_dotfiles)
	rm -rf $(wildcard ~/.*_before_shiropro_dotfiles)
	rm -rf $(shell find ~/.config/ -name '*_before_shiropro_dotfiles')
	rm -rf $(shell find ~/.local/ -name '*_before_shiropro_dotfiles')

install: all
	mkdir -p ~/.config
	cp --suffix=_before_shiropro_dotfiles --backup=existing -rf dot-config/* ~/.config/
	cp --suffix=_before_shiropro_dotfiles --backup=existing -rf dot-local/* ~/.local/
	cp --suffix=_before_shiropro_dotfiles --backup=existing -rf home/. ~/

uninstall:
	@echo please remove all staffs manually

.PHONY: all clean clean-backup install uninstall

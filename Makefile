rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))
SRCS = $(wildcard srv/.*.lua) $(call rwildcard,srv,*) $(wildcard srv/.lua/*)
.DELETE_ON_ERROR:
server.com: redbean.com $(SRCS)
	cp redbean.com server.com
	cd srv && zip ../server.com $(SRCS:srv/%=%)
redbean.com:
	curl -L -o redbean.com https://cosmo.zip/pub/cosmos/bin/redbean
	chmod +x redbean.com
SRCS = $(wildcard src/.*.lua) $(wildcard src/*) $(wildcard src/.lua/*)
server.com: redbean.com $(SRCS)
	cp redbean.com server.com
	cd src && zip ../server.com $(SRCS:src/%=%)
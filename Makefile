all: build

release: build

build:
	docker build -t sulphur/ejabberd:$(shell cat VERSION) .


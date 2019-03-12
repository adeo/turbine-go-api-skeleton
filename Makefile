NAME := $(shell cat tom.yml | sed -r '/name:/!d;s/.*: *'"'"'?([^$$])'"'"'?/\1/')
VERSION := $(shell cat tom.yml | sed -r '/app:/!d;s/.*: *'"'"'?([^$$])'"'"'?/\1/')

.PHONY: help
help: ## display this help
	@echo "This is the list of available make targets:"
	@echo " $(shell cat Makefile | sed -r '/^[a-zA-Z-]+:.*##.*/!d;s/## *//;s/$$/\\n/')"

.PHONY: start
start: ## start the application
	go run main.go --config config/local.json

.PHONY: deps
deps: ## get the golang dependencies in the vendor folder
	GO111MODULE=on go mod vendor

.PHONY: build
build: ##  build the executable and set the version
	go build -o go-api-skeleton -ldflags "-X github.com/adeo/go-api-skeleton/handlers.ApplicationVersion=$(VERSION) -X github.com/adeo/go-api-skeleton/handlers.ApplicationName=$(NAME)" main.go

.PHONY: test
test: ## run go test
	go test -v ./...

.PHONY: bump
bump: ## bump the version in the tom.yml file
	NEW_VERSION=`standard-version --dry-run | sed -r '/tagging release/!d;s/.*tagging release *v?(.*)/\1/g'`; \
		sed -r -i 's/^(.*app: *).*$$/\1'$$NEW_VERSION'/' tom.yml

.PHONY: release
release: bump ## bump the version in the tom.yml, and make a release (commit, tag and push)
	git add tom.yml
	standard-version --message "chore(release): %s [ci skip]" --commit-all
	git push --follow-tags origin HEAD

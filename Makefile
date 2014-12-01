TESTS = test/*.test.coffee
REPORTER = spec
TIMEOUT = 20000
MOCHA = ./node_modules/mocha/bin/_mocha

test:
	@NODE_ENV=test $(MOCHA) -R $(REPORTER) -t $(TIMEOUT) \
		--compilers coffee:coffee-script/register \
		$(MOCHA_OPTS) \
		$(TESTS)

.PHONY: test

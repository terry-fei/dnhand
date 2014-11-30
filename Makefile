TESTS = test/*.test.coffee
REPORTER = spec
TIMEOUT = 20000
MOCHA = ./node_modules/mocha/bin/_mocha

docker:
	sudo docker run -i -t -p 7080:7080 --rm --link \
		mongodb:mongo -v `pwd`:/src ifeiteng/dnhand:dev

test:
	@NODE_ENV=test $(MOCHA) -R $(REPORTER) -t $(TIMEOUT) \
		--compilers coffee:coffee-script/register \
		$(MOCHA_OPTS) \
		$(TESTS)

.PHONY: test

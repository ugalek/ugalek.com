.PHONY: test docker-up docker-down docker-rebuild

test:
	@(docker-compose -f docker-compose.test.yml up \
		--force-recreate \
		--always-recreate-deps \
		--remove-orphans \
		--build \
		--abort-on-container-exit)

docker-up:
	@(docker-compose up -d)

docker-down:
	@(docker-compose down)

docker-rebuild:
	@(docker-compose up -d --force-recreate --build)

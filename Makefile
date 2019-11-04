.PHONY: all images generate clean distclean

JQ := $(shell which jq || echo ./jq)
OWNER := a8cdata
REPO := chromium

$(shell mkdir -p built)
$(shell ./calculate-largest-version.php)

all_versions := $(wildcard versions/*)
build_versions := $(subst versions,built,$(all_versions))

all: clean
	$(MAKE) generate
	$(MAKE) images

images: $(build_versions)
	docker system prune -f --all

built/%:
	DOCKER_BUILDKIT=1 docker build --pull --build-arg VERSION=$(notdir $@) -t $(OWNER)/$(REPO):$(notdir $@) \
	$(shell [ -z "$(shell cat versions/$(notdir $@))" ] && echo "" || echo -t $(OWNER)/$(REPO):$(shell cat versions/$(notdir $@))) .
	docker push $(OWNER)/$(REPO):$(notdir $@)
	$(shell [ -z "$(shell cat versions/$(notdir $@))" ] && echo "" || echo docker push $(OWNER)/$(REPO):$(shell cat versions/$(notdir $@)))
	touch $@

generate:
	truncate -s 0 versions/*
	./versions.sh

$(JQ):
	wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
	mv jq-linux64 $(JQ)
	chmod +x $(JQ)
	$(JQ) --help

clean:
	rm -f versions.sh

distclean: clean
	rm -rf built

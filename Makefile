.PHONY: all generate

JQ := $(shell which jq || echo ./jq)
OWNER := withinboredom
REPO := chromium

$(shell mkdir -p built)

all_versions := $(wildcard versions/*)
build_versions := $(subst versions,built,$(all_versions))

all: $(build_versions)
	docker system prune -f --all

built/%:
	DOCKER_BUILDKIT=1 docker build --pull --build-arg VERSION=$(notdir $@) -t $(OWNER)/$(REPO):$(notdir $@) \
	$(shell [ -z "$(shell cat versions/$(notdir $@))" ] && echo "" || echo -t $(OWNER)/$(REPO):$(shell cat versions/$(notdir $@))) .
	docker push withinboredom/chromium:$(notdir $@)
	$(shell [ -z "$(shell cat versions/$(notdir $@))" ] && echo "" || echo docker push $(OWNER)/$(REPO):$(shell cat versions/$(notdir $@)))
	touch $@

generate: versions.sh
	truncate -s 0 versions/*
	sh < ./versions.sh

versions.sh:
	curl https://omahaproxy.appspot.com/all.json | jq -r '.[] | select(.os == "linux") | .versions[] | "echo \"" + .channel + "\" > versions/" + .current_version' > versions.sh

$(JQ):
	wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
	mv jq-linux64 $(JQ)
	chmod +x $(JQ)
	$(JQ) --help
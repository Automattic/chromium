.PHONY: all generate

JQ := $(shell which jq || echo ./jq)

$(shell mkdir -p built)

all_versions := $(wildcard versions/*)
build_versions := $(subst versions,built,$(all_versions))

all: $(build_versions)

built/%:
	DOCKER_BUILDKIT=1 docker build --build-arg VERSION=$(notdir $@) -t withinboredom/chromium:$(notdir $@) .
	#docker push withinboredom/chromium:$(notdir $@)
	#touch $@

generate: versions.list
	echo $(build_versions)
	rm -rf versions
	mkdir -p versions
	cd versions; xargs -d '\n' touch < ../versions.list

versions.list:
	curl https://omahaproxy.appspot.com/all.json | jq -r '.[] | select(.os == "linux") | .versions[].current_version' - > versions.list

$(JQ):
	wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
	mv jq-linux64 $(JQ)
	chmod +x $(JQ)
	$(JQ) --help
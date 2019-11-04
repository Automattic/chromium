.PHONY: all images generate clean distclean

OWNER ?= a8cdata
REPO := chromium

$(shell mkdir -p built)
$(shell ./create-versions.php)

all_versions := $(wildcard versions/*)
build_versions := $(subst versions,built/$(OWNER),$(all_versions))

all:
	$(MAKE) generate
	$(MAKE) images

images: $(build_versions)

built/$(OWNER)/%:
	mkdir -p built/$(OWNER)
	DOCKER_BUILDKIT=1 docker build --pull --build-arg VERSION=$(notdir $@) -t $(OWNER)/$(REPO):$(notdir $@) \
	$(shell [ -z "$(shell cat versions/$(notdir $@))" ] && echo "" || echo -t $(OWNER)/$(REPO):$(shell cat versions/$(notdir $@))) .
	docker push $(OWNER)/$(REPO):$(notdir $@)
	$(shell [ -z "$(shell cat versions/$(notdir $@))" ] && echo "" || echo docker push $(OWNER)/$(REPO):$(shell cat versions/$(notdir $@)))
	touch $@

generate:
	truncate -s 0 versions/*
	./versions.sh
	./delete-empty.php

clean:
	rm -f versions.sh
	docker system prune -f --all

distclean: clean
	rm -rf built

/etc/docker/daemon.json:
	echo '{ "storage-driver": "zfs" }' > /etc/docker/daemon.json

# I'm being lazy -- this is mostly to document the process
/zfsdevs/file1:
	mkdir -p /zfsdevs
	fallocate -l 25G /zfsdevs/file1

/zfsdevs/file2:
	mkdir -p /zfsdevs
	fallocate -l 25G /zfsdevs/file2

/zfsdevs/file3:
	mkdir -p /zfsdevs
	fallocate -l 25G /zfsdevs/file3

/zfsdevs/file4:
	mkdir -p /zfsdevs
	fallocate -l 25G /zfsdevs/file4

zfs: /zfsdevs/file1 /zfsdevs/file2 /zfsdevs/file3 /zfsdevs/file4 /etc/docker/daemon.json
	zpool create -f zpool-docker /zfsdevs/file1 /zfsdevs/file2 /zfsdevs/file3 /zfsdevs/file4
	systemctl stop docker
	rm -rf /var/lib/docker
	zfs create -o mountpoint=/var/lib/docker zpool-docker/docker
	systemctl start docker
	docker info
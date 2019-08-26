# Chromium Builder

Builds Chromium stable / beta /dev

## Usage

```bash
docker create --name chromium a8cdata/chromium:76.0.3809.100 .
docker cp chromium:/chrome-linux-76.0.3809.100.zip
```

# Building

First, you need to update the version mappings

```bash
make generate
```

Then, start the build:

```bash
make -j
```

## Requirements

- at least 24GB ram
- decent amount of CPUs

On a machine with 12 cores and 64gb of ram, it takes several hours to build from scratch.

## Automation

Drop the following line in cron which will build the images daily at 5am:

```cron
  0 5  *   *   *     cd path/to/chromium; make all
``` 
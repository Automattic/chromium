# Chromium Builder

Builds Chromium stable / beta /dev

## Usage

```bash
docker create --name chromium withinboredom/chromium:76.0.3809.100 .
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
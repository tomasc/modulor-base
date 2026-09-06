# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

modulor-base is a Docker base image published to Docker Hub (`tomasce/modulor-base`). It provides a pre-configured Ruby environment with Node.js, media processing tools, and font handling libraries for Modulor-based Rails applications.

## Build Commands

### One-time setup for multi-platform builds

Multi-platform builds require a buildx builder with the `docker-container` driver:
```bash
docker buildx create --name multiplatform --driver docker-container --use
```

### Build and push multi-platform image
```bash
docker buildx build --platform=linux/amd64,linux/arm64 -t tomasce/modulor-base:<version> --push .
```

Build locally for testing (current platform only):
```bash
docker build -t tomasce/modulor-base:<version> .
```

## Version Components

Versions are defined as ARGs at the top of the Dockerfile:
- Ruby: 4.0.6 (base image, pinned)
- Node.js: 26.x
- Bundler: 4.0.20
- RubyGems: 4.0.20
- Harfbuzz: 14.4.0
- TTF2EOT: 0.0.2-2

## Included Tools

- **Media**: ffmpeg, libvips, mupdf, pdftk
- **Fonts**: fontforge, fontTools (+brotli, for woff/woff2 and vertical metrics), harfbuzz (hb-view), ttf2eot, ttfautohint, woff2
- **Graphics**: cairo, freetype, pango, librsvg
- **Package managers**: yarn, npm, bundler

## Versioning

Work lands on `master`; each released image is a **git tag** matching its Docker Hub tag exactly. There are no version branches — an image version is immutable, so a tag is the right primitive, and it means the commit that built any published image is always recoverable.

To release:
1. Update the Dockerfile ARGs on `master`.
2. Build and push the image with the new tag.
3. Tag the commit with the same version and push the tag.

```bash
git tag -a 4.0.7 -m "modulor-base 4.0.7" && git push origin 4.0.7
```

To patch an old version, branch from its tag on demand — `git checkout -b 4.0.6-fix 4.0.6` — and delete the branch once released.

Note that the moving Docker tags (`4.0`) deliberately have no permanent git tag of their own; they point at whichever release is current. The `4.0` git tag records only what that Docker tag pointed at when the repo migrated from branches to tags.

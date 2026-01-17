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
- Ruby: 4.0 (base image)
- Node.js: 25.x
- Bundler: 4.0.3
- RubyGems: 4.0.3
- Harfbuzz: 12.3.0
- TTF2EOT: 0.0.2-2

## Included Tools

- **Media**: ffmpeg, libvips, mupdf, pdftk
- **Fonts**: fontforge, harfbuzz (hb-view), ttf2eot, ttfautohint, woff2
- **Graphics**: cairo, freetype, pango, librsvg
- **Package managers**: yarn, npm, bundler

## Versioning

Branch names correspond to versions (e.g., `4.0`, `3.4.5`). When updating:
1. Create a new version branch
2. Update Dockerfile ARGs as needed
3. Build and push with the matching tag

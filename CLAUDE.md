# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

modulor-base is a Docker base image published to Docker Hub (`tomasce/modulor-base`). It provides a pre-configured Ruby environment with Node.js, media processing tools, and font handling libraries for Modulor-based Rails applications.

## Build Command

Build and push multi-platform image:
```bash
docker buildx build --platform=linux/amd64,linux/arm64 -t tomasce/modulor-base:<version> --push .
```

## Version Components

Current (4.0.0):
- Ruby: 4.0.0
- Node.js: 25.x
- Bundler: 4.0.3
- RubyGems: 4.0.3
- Harfbuzz: 12.3.0

## Included Tools

- **Media**: ffmpeg, libvips, mupdf, pdftk
- **Fonts**: fontforge, harfbuzz, ttf2eot, ttfautohint, woff2
- **Graphics**: cairo, freetype, pango, librsvg
- **Package managers**: yarn, npm, bundler

## Versioning

Branch names correspond to versions (e.g., `4.0.0`, `3.4.5`). When updating, create a new version branch and update the Dockerfile ARGs accordingly.

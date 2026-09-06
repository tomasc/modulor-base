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

- **Media**: ffmpeg (+ffprobe), libvips (+`vips` CLI), poppler-utils (`pdfinfo`, for PDF page metadata), imagemagick (from the ruby base)
- **Fonts**: fontforge (+python3-fontforge), fontTools (+brotli, for woff/woff2 and vertical metrics), harfbuzz (hb-view), ttf2eot, ttfautohint, woff2
- **Graphics**: cairo, freetype, pango, librsvg
- **Package managers**: yarn, npm, bundler
- **Misc**: zip/unzip (`modulor cli skill package` shells out to `zip`), nano (`EDITOR`/`VISUAL`)

Everything here is invoked by name from modulor or an app — `git grep` for
`Open3`/`%x(`/`system(` before removing one.

## Image Size

~2.5GB. The four things keeping it there, each of which a well-meaning edit
would undo:

- **harfbuzz is built `--buildtype=release --default-library=static` and
  installed**, so the source tree is deleted in the same layer. meson defaults
  to a debug build: leaving the tree behind (with `hb-view` symlinked into it)
  cost 806MB.
- **`--no-install-recommends`**, with `libvips-tools` and `poppler-data` named
  explicitly because we do want those two. Worth ~330MB.
- **`/etc/dpkg/dpkg.cfg.d/01-nodoc`**, written before the first install. ~150MB.
- **apt lists are removed inside the RUN that creates them.** A trailing
  `apt-get clean` in its own layer saves nothing — the bytes still ship.

Deliberately *not* installed: `libclang-dev` (387MB of llvm, nothing uses it),
`mupdf` (`mutool` is never called), `ruby-psych` (Debian's ruby 3.3, shadowed by
the compiled one; `libyaml-dev` is what psych actually needs), `gtk-doc-tools`
(only built harfbuzz's docs, now disabled). `libopenslide-dev` / `libmatio-dev`
are already `libvips-dev` dependencies.

`pdftk` was dropped in 4.0.6 and its 194MB `openjdk-21-jre-headless` with it:
it served one `dump_data` call in `HasPdfMetadata`, which `pdfinfo` answers in a
single call from a 1.1MB package (tomasc/modulor#2894).

`ruby:4.0.6-slim` is measured and declined — 210MB, against a hand-curated
header list that fails in an app's CI rather than here. See modulor-base#1 for
the numbers, including the 917MB that is build-only and what a runtime/builder
split would take.

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

# The Dead School — live build

Play the latest version: **https://stopitmax05.github.io/the-dead-school/**

A first-person horror escape for desktop browsers and iPad Safari. Use headphones. Chrome, Edge, Firefox or Safari with WebGL2.

## How versions work

- Every published version gets a number (v1, v2, ...) and its own permanent link, for example https://stopitmax05.github.io/the-dead-school/v1/. Old versions stay playable forever, so you can always compare.
- The main link always serves the newest version, unless it has been rolled back.
- [VERSIONS.md](VERSIONS.md) lists every version, when it went live, which source commit it came from, and what changed.
- Each version is also a [GitHub Release](https://github.com/StopItMax05/the-dead-school/releases) with the offline single-file copy attached.
- The same version number is tagged in the source repository (jmcewan-ava/MAXGAME, private), so the exact code behind any version can be found.

## Publishing a new version

From a clean MAXGAME checkout (everything committed), run:

```sh
tools/release.sh <path to MAXGAME> v2
```

It builds, copies the game to the main link and to `v2/`, commits, tags `v2` in both repositories, pushes, and creates the GitHub Release. Pick the next number each time.

## Going back to an older version

```sh
tools/rollback.sh v1
```

The main link serves v1 again. Nothing is deleted and every version's own link is unchanged. Publishing the next version moves the main link forward again.

## What is in this repository

Only built output: `index.html` and `assets/` for the main link, one folder per version, `The-Dead-School.html` (the self-contained offline copy; download it with "Download raw file" and open it in a desktop browser) and `LICENSES.txt` (dependency notices for the PlayCanvas engine and Ammo physics). The source code lives in the private repository jmcewan-ava/MAXGAME.

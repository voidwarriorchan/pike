# pike

A coding agent for the terminal: [Pi](https://github.com/earendil-works/pi)
with a set of extensions built in, as one executable. Install it, run `pike`,
log in to a model provider. Nothing else is installed first: no Node, no
packages, no settings file.

pike is Pi under another name, not a fork, and is not affiliated with Pi's
authors. This repository holds its releases, its installer and this README;
the extensions' source is not published.

## Install

With Homebrew, on macOS or Linux:

```sh
brew install voidwarriorchan/tap/pike
```

The full name matters. Homebrew's own `pike` is the Pike programming
language, an unrelated tool whose command has the same name.

Or with the installer script:

```sh
curl -fsSL https://github.com/voidwarriorchan/pike/releases/latest/download/install.sh | sh
```

It downloads the archive for your machine, checks it against the release's
`SHA256SUMS`, unpacks it under `~/.local/share/pike/versions/` and links
`~/.local/bin/pike` to it. `PIKE_INSTALL_DIR` and `PIKE_BIN_DIR` move the two
locations.

There are builds for macOS and Linux, each on arm64 and x64. Linux needs
glibc, so Alpine is not supported, and there is no Windows build.

## Update and uninstall

| Installed with | Update | Uninstall |
| --- | --- | --- |
| Homebrew | `brew upgrade voidwarriorchan/tap/pike` | `brew uninstall voidwarriorchan/tap/pike` |
| The installer script | `pike update` | delete `~/.local/share/pike` and `~/.local/bin/pike` |

`pike update` runs the installer from the latest release. It keeps the
version it replaces, which a session still running reads its themes from, and
removes older ones. On a Homebrew installation it changes nothing and names
the `brew` command instead.

Your settings, logins and sessions are in `~/.pike`, which neither uninstall
removes.

## First run

Run `pike` in a project. With no credentials it says so and waits: `/login`
signs in to a provider, or start it with a provider's API key in the
environment. `docs/providers.md` beside the executable lists the providers.

These extensions are built in. The ones that cost requests or start background
processes (hands, suggest, translate) stay off until you switch them on:

| Extension | What it adds | Before it does anything |
| --- | --- | --- |
| footer, quota | Working tree, model and subscription quota in the footer | Nothing |
| choose | Choice lists the model can put to you (`/choose`) | Nothing |
| session-recall | The model can search, read and query your past sessions | Nothing |
| hands, hands-models | Background tasks in a read-only, isolated or direct workspace, whose patches you choose to apply | `/hands on`, then `/hands-models` once, to choose the models tasks may use |
| exa | Web search and page fetching through Exa | `/exa` once, to save an Exa API key |
| openai-fast | Priority requests on OpenAI and Codex models | `/fast on`, per session |
| suggest | The next prompt, predicted and drawn as ghost text; Tab fills it in | `/suggest on` |
| translate | Japanese prompts rewritten into English for the model, and its answers shown in Japanese | `/translate on` |

`pike config` lists the built-in extensions and turns any of them off; so does
`"extensions": ["-builtin:translate"]` in `~/.pike/agent/settings.json`.

## Where things are

pike keeps to its own names, so it runs beside a Pi installation without
either seeing the other's settings, logins or sessions:

| Pi | pike |
| --- | --- |
| `pi` | `pike` |
| `~/.pi/agent/` | `~/.pike/agent/` |
| `.pi/` in a project | `.pike/` |
| `PI_CODING_AGENT_DIR`, `PI_CODING_AGENT_SESSION_DIR` | `PIKE_CODING_AGENT_DIR`, `PIKE_CODING_AGENT_SESSION_DIR` |

Pi's own documentation is shipped beside the executable and says `pi` and
`~/.pi` throughout; read them as the names above. Everything else is Pi's:
`AGENTS.md`, sessions, themes, MCP servers, and packages, which
`pike install` installs as `pi install` does; an npm package needs `npm` on
your `PATH`, as it does for Pi's own binary.

## What differs from Pi

- `pike --version` prints the executable's version and Pi's. The
  `package.json` beside the executable carries Pi's version, because Pi sends
  it to pi.dev to be served a model catalog its code can read.
- Pi's check for a newer Pi is off, since it would name Pi's installer.
  `pike update` updates the executable; `pike update --extensions` and
  `pike update --models` are Pi's and unchanged.
- Pi's install report to pi.dev, and the attribution it adds to provider
  requests while that report is on, are off. `PI_TELEMETRY=1` turns them on.
- Hands starts its background processes by running the executable again, and
  keeps their state under `~/.pike/agent/orderer/`.

## License

MIT; see `LICENSE`. `NOTICE.md` and, beside the executable,
`THIRD-PARTY-NOTICES.md` cover Pi, the Bun runtime and every bundled package.

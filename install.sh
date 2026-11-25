#!/bin/sh
# Installs or updates pike: downloads the latest release for this machine,
# checks it against the release's checksums, and links it onto PATH.
#
#   curl -fsSL https://github.com/voidwarriorchan/pike/releases/latest/download/install.sh | sh
#
# `pike update` runs this same script from the latest release.
#
#   PIKE_RELEASE_URL    where the release's files are (a mirror, or a directory as file://)
#   PIKE_INSTALL_DIR    where versions are kept; default ~/.local/share/pike
#   PIKE_BIN_DIR        where the `pike` link goes; default ~/.local/bin
#   PIKE_INSTALL_FORCE  set to 1 to install again over the same version
set -eu

release_url=${PIKE_RELEASE_URL:-https://github.com/voidwarriorchan/pike/releases/latest/download}
install_dir=${PIKE_INSTALL_DIR:-$HOME/.local/share/pike}
bin_dir=${PIKE_BIN_DIR:-$HOME/.local/bin}

fail() {
  echo "pike install: $*" >&2
  exit 1
}

fetch() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$1" -o "$2"
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$1" -O "$2"
  else
    fail "curl or wget is required"
  fi
}

sha256_of() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d ' ' -f 1
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | cut -d ' ' -f 1
  else
    fail "sha256sum or shasum is required"
  fi
}

case $(uname -s) in
  Darwin) os=darwin ;;
  Linux) os=linux ;;
  *) fail "no build for $(uname -s); the platforms are macOS and Linux" ;;
esac
case $(uname -m) in
  arm64 | aarch64) arch=arm64 ;;
  x86_64 | amd64) arch=x64 ;;
  *) fail "no build for $(uname -m); the architectures are arm64 and x64" ;;
esac
# A shell running under Rosetta reports x86_64 on Apple silicon.
if [ "$os" = darwin ] && [ "$(sysctl -n sysctl.proc_translated 2>/dev/null || echo 0)" = 1 ]; then
  arch=arm64
fi
# The builds link against glibc.
if [ "$os" = linux ] && ls /lib/ld-musl-* >/dev/null 2>&1; then
  fail "no build for musl libc (Alpine); use a glibc system"
fi
archive=pike-$os-$arch.tar.gz

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

fetch "$release_url/VERSION" "$work/VERSION" || fail "could not read $release_url/VERSION"
version=$(tr -d '[:space:]' <"$work/VERSION")
case $version in
  '' | *[!0-9A-Za-z.+-]*) fail "$release_url/VERSION does not hold a version" ;;
esac
target=$install_dir/versions/$version

if [ -x "$target/pike" ] && [ "${PIKE_INSTALL_FORCE:-}" != 1 ]; then
  echo "pike $version is already installed."
else
  echo "Downloading pike $version for $os-$arch..."
  fetch "$release_url/$archive" "$work/$archive" || fail "could not download $release_url/$archive"
  fetch "$release_url/SHA256SUMS" "$work/SHA256SUMS" || fail "could not download $release_url/SHA256SUMS"
  expected=$(awk -v name="$archive" '$2 == name { print $1 }' "$work/SHA256SUMS")
  [ -n "$expected" ] || fail "SHA256SUMS does not list $archive"
  actual=$(sha256_of "$work/$archive")
  [ "$expected" = "$actual" ] || fail "$archive does not match its checksum (expected $expected, got $actual)"
  tar -xzf "$work/$archive" -C "$work"
  [ -x "$work/pike/pike" ] || fail "$archive holds no pike executable"
  mkdir -p "$install_dir/versions"
  # Beside its final place, so the rename below stays on one filesystem.
  staged=$install_dir/versions/.$version.$$
  rm -rf "$staged"
  mv "$work/pike" "$staged"
  rm -rf "$target"
  mv "$staged" "$target"
fi

# A running session of the version linked until now still reads its assets,
# so that one stays; anything older goes.
previous=
if [ -L "$bin_dir/pike" ]; then
  previous=$(dirname "$(readlink "$bin_dir/pike")")
fi
mkdir -p "$bin_dir"
ln -sf "$target/pike" "$bin_dir/.pike.$$"
mv -f "$bin_dir/.pike.$$" "$bin_dir/pike"
for kept in "$install_dir"/versions/*; do
  [ -d "$kept" ] || continue
  [ "$kept" = "$target" ] || [ "$kept" = "$previous" ] || rm -rf "$kept"
done

echo "pike $version is installed: $bin_dir/pike"
case :$PATH: in
  *:"$bin_dir":*) ;;
  *) echo "Add $bin_dir to your PATH to run it as \`pike\`." ;;
esac

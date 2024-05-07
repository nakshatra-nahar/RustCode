# Installing rustcode

To install rustcode, follow the instructions specific to your operating system.
Note that:

- To get the latest nightly version of rustcode, you need to
  [build from source](./building-from-source.md).

- To take full advantage of rustcode, install the language servers for your
  preferred programming languages. See the
  [wiki](https://github.com/rustcode-editor/rustcode/wiki/How-to-install-the-default-language-servers)
  for instructions.

## Pre-built binaries

Download pre-built binaries from the [GitHub Releases page](https://github.com/rustcode-editor/rustcode/releases).
Add the `hx` binary to your system's `$PATH` to use it from the command line, and copy the `runtime` directory into the config directory (for example `~/.config/rustcode/runtime` on Linux/macOS).
The runtime location can be overriden via the rustcode_RUNTIME environment variable.


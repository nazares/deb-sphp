# Debian-based distributive PHP Switcher

![cover](cover.png)

Debian PHP switcher is a simple script to switch your Apache and CLI configs quickly between major versions of PHP.
This supports any version of php installed onto the Debian-based system.

If you support multiple products/projects that are built using either brand new or old legacy PHP functionality and you
find it a pain to change config files continually this will make the whole process just one command.

## Caveats

For use with Debian-based systems. For macOS php switching, I recommend  a [Phil Cook's php switcher script](https://github.com/rhukster/sphp.sh)

## Installation

```bash
curl -L https://raw.githubusercontent.com/nazares/deb-sphp/main/sphp.sh > /usr/local/bin/sphp
chmod +x /usr/local/bin/sphp
```

### Composer installation

```bash
composer global require nazares/deb-sphp
```

## Usage

Simply type `sphp` and the version you want to switch:

```bash
sphp 8.0 #to switch to PHP 8.0 version
sphp 8.1 #to switch to PHP 8.1 version
sphp 8.2 #to switch to PHP 8.2 version
# ...
# etc.
```

to get installed versions of PHP just run:

```bash
sphp
    # usage: sphp <version>
    # installed php versions: 8.0,8.1,8.2
```

## License

MIT

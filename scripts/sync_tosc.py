#!/usr/bin/env python3
"""
sync_tosc.py — Sync Lua scripts between TEEE-EMMEDIA.tosc and scripts/

Usage:
  python3 sync_tosc.py export   — Extract all scripts from .tosc → scripts/*.lua
  python3 sync_tosc.py inject   — Inject scripts/RootLuaScript.lua → .tosc root script
  python3 sync_tosc.py sync     — Export then inject (default)
"""

import zlib, re, os, sys

TOSC_PATH = os.path.join(os.path.dirname(__file__), '..', 'TEEE-EMMEDIA.tosc')
SCRIPTS_DIR = os.path.dirname(__file__)
ROOT_SCRIPT = os.path.join(SCRIPTS_DIR, 'RootLuaScript.lua')

# Control name → filename mapping for known controls with non-obvious names
NAME_MAP = {
    'group': 'RootLuaScript',
}


def read_tosc():
    with open(TOSC_PATH, 'rb') as f:
        return zlib.decompress(f.read()).decode('utf-8')


def write_tosc(xml):
    with open(TOSC_PATH, 'wb') as f:
        f.write(zlib.compress(xml.encode('utf-8')))
    print(f'  Wrote {os.path.getsize(TOSC_PATH):,} bytes → {os.path.basename(TOSC_PATH)}')


def extract_scripts(xml):
    """Return list of (control_name, script_body) for all non-empty scripts."""
    results = []
    for m in re.finditer(
        r'<key><!\[CDATA\[script\]\]></key><value><!\[CDATA\[(.*?)\]\]></value>',
        xml, re.DOTALL
    ):
        script = m.group(1).strip()
        if not script:
            continue
        preceding = xml[:m.start()]
        names = re.findall(
            r'<key><!\[CDATA\[name\]\]></key><value><!\[CDATA\[(.*?)\]\]>', preceding
        )
        name = names[-1] if names else 'unknown'
        results.append((name, script))
    return results


def export():
    """Extract all scripts from .tosc and write to scripts/*.lua"""
    print('Exporting scripts from .tosc...')
    xml = read_tosc()
    scripts = extract_scripts(xml)

    seen = {}
    for name, script in scripts:
        filename = NAME_MAP.get(name, name)
        count = seen.get(filename, 0)
        seen[filename] = count + 1
        suffix = '' if count == 0 else f'_{count}'
        path = os.path.join(SCRIPTS_DIR, f'{filename}{suffix}.lua')

        header = f'-- Source control: {name}\n-- File: {os.path.basename(TOSC_PATH)}\n\n'
        with open(path, 'w') as f:
            f.write(header + script + '\n')
        print(f'  Wrote {os.path.basename(path)}')

    print(f'Done. {len(scripts)} scripts exported.')


def inject():
    """Inject RootLuaScript.lua into the .tosc root script property."""
    print('Injecting RootLuaScript.lua into .tosc...')
    xml = read_tosc()

    with open(ROOT_SCRIPT, 'r') as f:
        new_script = f.read()

    pattern = (
        r'(<property type=\'s\'><key><!\[CDATA\[script\]\]></key>'
        r'<value><!\[CDATA\[)(.*?)(\]\]></value></property>)'
    )
    m = re.search(pattern, xml, re.DOTALL)
    if not m:
        print('ERROR: Root script property not found in .tosc')
        sys.exit(1)

    xml = xml[:m.start()] + m.group(1) + new_script + m.group(3) + xml[m.end():]
    write_tosc(xml)
    print('Done.')


def sync():
    export()
    print()
    inject()


if __name__ == '__main__':
    cmd = sys.argv[1] if len(sys.argv) > 1 else 'sync'
    if cmd == 'export':
        export()
    elif cmd == 'inject':
        inject()
    elif cmd == 'sync':
        sync()
    else:
        print(__doc__)
        sys.exit(1)

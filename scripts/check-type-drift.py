#!/usr/bin/env python3
"""Check that type definitions duplicated across modules haven't drifted.

HCL has no way to share a type between modules, so these types are copied:

- the ruleset type (`# BEGIN shared-ruleset-type`) in repository/ and
  repositories/ (profiles and repositories)
- the rules type (`# BEGIN shared-rules-type`) in those and in organization/
- the settings type (`# BEGIN settings-type`) in repositories/, which must have
  one attribute per repository/ input, with the same type

Run from the repository root. Exits 1 and prints the differences on drift.
"""
import difflib
import re
import sys

EXCLUDED_INPUTS = {
    "repository_name",
    "description",
    "rulesets",
}


def read(path):
    with open(path, encoding="utf-8") as f:
        return f.read()


def blocks(path, marker):
    """Return each marked block as a list of stripped, non-comment lines."""
    found = re.findall(
        rf"# BEGIN {marker}\b[^\n]*\n(.*?)\n[ \t]*# END {marker}\b", read(path), re.S
    )
    if not found:
        sys.exit(f"{path}: no '# BEGIN {marker}' block found")
    result = []
    for block in found:
        lines = [l.strip() for l in block.splitlines()]
        result.append([l for l in lines if l and not l.startswith("#")])
    return result


def compare(name, reference, others):
    ok = True
    ref_path, ref = reference
    for path, block in others:
        if block != ref:
            ok = False
            print(f"{name}: {path} differs from {ref_path}:")
            sys.stdout.writelines(
                l + "\n" for l in difflib.unified_diff(ref, block, ref_path, path, lineterm="")
            )
    return ok


def inner(block):
    # Drop the wrapper lines: `type = map(object({` ... `}))` in repository/,
    # `rulesets = optional(map(object({` ... `})), {})` in repositories/.
    return block[1:-1]


ok = True

rulesets = [("repository/variables.tf", inner(b)) for b in blocks("repository/variables.tf", "shared-ruleset-type")]
rulesets += [("repositories/variables.tf", inner(b)) for b in blocks("repositories/variables.tf", "shared-ruleset-type")]
ok &= compare("ruleset type", rulesets[0], rulesets[1:])

rules = []
for path in ("repository/variables.tf", "repositories/variables.tf", "organization/variables.tf"):
    rules += [(path, b) for b in blocks(path, "shared-rules-type")]
ok &= compare("rules type", rules[0], rules[1:])

inputs = {
    name: typ
    for name, typ in re.findall(r'variable "(\w+)" \{.*?\n  type\s*=\s*(\w+)', read("repository/variables.tf"), re.S)
    if name not in EXCLUDED_INPUTS
}
for block in blocks("repositories/variables.tf", "settings-type"):
    attrs = dict(re.findall(r"^(\w+)\s*=\s*optional\((\w+)\)$", "\n".join(block), re.M))
    if attrs != inputs:
        ok = False
        print("settings type in repositories/variables.tf doesn't match repository/ inputs:")
        for name in sorted(set(inputs) | set(attrs)):
            if inputs.get(name) != attrs.get(name):
                print(f"  {name}: repository/ has {inputs.get(name)}, repositories/ has {attrs.get(name)}")

if not ok:
    sys.exit(1)
print("No type drift between repository/, repositories/ and organization/.")

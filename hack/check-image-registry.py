#!/usr/bin/env python3
"""Every image the charts under helm/ reference by default comes from gsoci.azurecr.io.

Each chart is rendered with its default values and, where a feature switch hides more
defaults, once more with that switch on. Every string under a key ending in "image"
(image, defaultJobImage, rbacProxyImage, ...) in the rendered manifests -- including the
JSON blocks of the inferenceservice-config ConfigMap -- and in values.yaml has to start
with the registry. The first reference outside it fails the check.

Needs helm and PyYAML. Run from the repository root: hack/check-image-registry.py
"""

import json
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile

import yaml

REGISTRY = "gsoci.azurecr.io/"
HELM_DIR = pathlib.Path("helm")
# The chart version is stamped by the release pipeline; helm refuses the placeholder.
VERSION_PLACEHOLDER = 'version: "[[ .Version ]]"'
# Feature switches whose defaults only render when they are on. The classic
# ClusterServingRuntimes are not listed: they ship no image and refuse to render
# without one, which values.yaml below covers.
EXTRA_RENDERS = {
    "kserve-resources": [["kserve.localmodel.enabled=true"]],
    "kserve-llmisvc-resources": [["kserve.localmodel.enabled=true"]],
    "kserve-runtime-configs": [["kserve.llmisvcConfigs.enabled=true"]],
}
# Upstream documents the ConfigMap's options in a commented example block that KServe
# never reads; it is documentation, not a reference the cluster pulls.
SKIPPED_CONFIGMAP_KEYS = {"_example"}
JSON_IMAGE_RE = re.compile(r'"([A-Za-z]*[iI]mage)"\s*:\s*"([^"]*)"')


def image_refs(node, path=""):
    """Yield (path, value) for every string under a key ending in 'image'."""
    if isinstance(node, dict):
        for key, value in node.items():
            child = f"{path}.{key}" if path else str(key)
            if isinstance(value, str) and str(key).lower().endswith("image"):
                yield child, value
            else:
                yield from image_refs(value, child)
    elif isinstance(node, list):
        for index, value in enumerate(node):
            yield from image_refs(value, f"{path}[{index}]")


def configmap_refs(doc, path):
    """The inferenceservice-config keys are JSON documents with image fields."""
    for key, value in (doc.get("data") or {}).items():
        if key in SKIPPED_CONFIGMAP_KEYS or not isinstance(value, str):
            continue
        child = f"{path}.data.{key}"
        try:
            yield from image_refs(json.loads(value), child)
        except ValueError:
            for field, ref in JSON_IMAGE_RE.findall(value):
                yield f"{child}.{field}", ref


def manifest_refs(rendered):
    for doc in yaml.safe_load_all(rendered):
        if not isinstance(doc, dict):
            continue
        name = f"{doc.get('kind')}/{(doc.get('metadata') or {}).get('name')}"
        if doc.get("kind") == "ConfigMap":
            yield from configmap_refs(doc, name)
        yield from image_refs(doc, name)


def render(chart_dir, staged, sets):
    cmd = ["helm", "template", "check", str(staged), "--namespace", "kserve"]
    for value in sets:
        cmd += ["--set", value]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        sys.exit(f"helm template {chart_dir.name} {' '.join(sets)} failed:\n{result.stderr}")
    return result.stdout


def stage(chart_dir, tmp):
    staged = pathlib.Path(tmp) / chart_dir.name
    shutil.copytree(chart_dir, staged)
    chart_yaml = staged / "Chart.yaml"
    chart_yaml.write_text(chart_yaml.read_text().replace(VERSION_PLACEHOLDER, "version: 0.0.0"))
    return staged


def check_chart(chart_dir):
    offending, checked = [], 0
    values = yaml.safe_load((chart_dir / "values.yaml").read_text()) or {}
    refs = [(f"values.yaml:{path}", ref) for path, ref in image_refs(values)]
    with tempfile.TemporaryDirectory() as tmp:
        staged = stage(chart_dir, tmp)
        for sets in [[]] + EXTRA_RENDERS.get(chart_dir.name, []):
            label = " ".join(f"--set {s}" for s in sets) or "defaults"
            refs += [(f"{label}:{path}", ref) for path, ref in manifest_refs(render(chart_dir, staged, sets))]
    for where, ref in refs:
        if ref == "":
            continue  # no image shipped, nothing to pull
        checked += 1
        if not ref.startswith(REGISTRY):
            offending.append(f"{chart_dir.name}: {where} = {ref}")
    return offending, checked


def main():
    if not HELM_DIR.is_dir():
        sys.exit(f"{HELM_DIR}/ not found; run from the repository root")
    offending, checked = [], 0
    for chart_dir in sorted(p for p in HELM_DIR.iterdir() if (p / "Chart.yaml").is_file()):
        chart_offending, chart_checked = check_chart(chart_dir)
        offending += chart_offending
        checked += chart_checked
        print(f"{chart_dir.name}: {chart_checked} image references, {len(chart_offending)} outside {REGISTRY}")
    if offending:
        print("\nimage references outside " + REGISTRY + ":", file=sys.stderr)
        print("\n".join("  " + line for line in offending), file=sys.stderr)
        sys.exit(1)
    print(f"\nall {checked} image references come from {REGISTRY}")


if __name__ == "__main__":
    main()

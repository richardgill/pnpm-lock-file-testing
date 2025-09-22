#!/bin/bash

log_package_files() {
    echo "package.json:"
    cat package.json
    echo ""
    echo "pnpm-lock.yaml:"
    cat pnpm-lock.yaml
    echo ""
}

get_react_version() {
    local package_path="$(pwd)/node_modules/react/package.json"
    local version=$(jq -r '.version' "$package_path")
    echo "React version: $version (from $package_path)"
}

echo "Available React 19 versions:"
pnpm view react versions --json | jq -r '.[]' | grep '^19\.' | grep -v canary | grep -v rc | grep -v beta | grep -v alpha
echo ""

log_package_files
get_react_version

echo ""
echo "Running pnpm install..."
pnpm install

echo ""
echo "After pnpm install:"
log_package_files
get_react_version

echo ""
echo "Removing pnpm-lock.yaml..."
rm pnpm-lock.yaml

echo ""
echo "Running pnpm install without lock file..."
pnpm install

echo ""
echo "After fresh install:"
log_package_files
get_react_version
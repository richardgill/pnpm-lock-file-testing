#!/bin/bash

# Function to log package files
log_package_files() {
    echo "=== package.json contents ==="
    cat package.json
    echo ""

    echo "=== pnpm-lock.yaml contents ==="
    cat pnpm-lock.yaml
    echo ""
}

# Display package files
log_package_files

# Function to get React version from node_modules
get_react_version() {
    local package_path="$(pwd)/node_modules/react/package.json"
    local version=$(jq -r '.version' "$package_path")
    echo "React version: $version"
    echo "Found at: $package_path in \"version\" field"
}

# List stable React versions starting with 19
echo "=== Stable React versions starting with 19 ==="
pnpm view react versions --json | jq -r '.[]' | grep '^19\.' | grep -v canary | grep -v rc | grep -v beta | grep -v alpha

echo ""

# Call the function
echo "=== Installed React version ==="
get_react_version

echo ""
echo "=== Running pnpm install ==="
pnpm install

echo ""
echo "=== After pnpm install ==="
log_package_files

echo "=== Installed React version after pnpm install ==="
get_react_version

echo ""
echo "=== Removing pnpm-lock.yaml ==="
rm pnpm-lock.yaml

echo ""
echo "=== Running pnpm install (without lock file) ==="
pnpm install

echo ""
echo "=== After pnpm install without lock file ==="
log_package_files

echo "=== Installed React version after fresh install ==="
get_react_version

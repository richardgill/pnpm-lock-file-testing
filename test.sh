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

show_git_diff() {
    echo "git diff:"
    git diff
}

echo "Available React 19 versions:"
pnpm view react versions --json | jq -r '.[]' | grep '^19\.' | grep -v canary | grep -v rc | grep -v beta | grep -v alpha
echo ""

log_package_files
get_react_version

echo ""
echo "----------"
echo "Running pnpm install..."
pnpm install

echo ""
echo "After pnpm install:"
log_package_files
get_react_version
show_git_diff

echo ""
echo "----------"
echo "Removing pnpm-lock.yaml..."
rm pnpm-lock.yaml

echo ""
echo "Running pnpm install without lock file..."
pnpm install

echo ""
echo "After fresh install:"
log_package_files
get_react_version
show_git_diff

echo ""
echo "----------"
echo "Removing pnpm-lock.yaml and node_modules..."
rm pnpm-lock.yaml
rm -rf node_modules

echo ""
echo "Running pnpm install from scratch..."
pnpm install

echo ""
echo "After clean install:"
log_package_files
get_react_version
show_git_diff

echo ""
echo "----------"
echo "Restoring pnpm-lock.yaml from git and removing node_modules..."
git checkout pnpm-lock.yaml
rm -rf node_modules

echo ""
echo "Running pnpm install with restored lock file..."
pnpm install

echo ""
echo "After install with restored lock:"
log_package_files
get_react_version
show_git_diff
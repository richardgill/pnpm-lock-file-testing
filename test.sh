#!/bin/bash

log_package_files() {
    echo "📦 package.json:"
    jq -c '.dependencies.react' package.json | sed 's/^/  react: /'
    echo ""
    echo "🔒 pnpm-lock.yaml:"
    grep -A2 -B2 'react:' pnpm-lock.yaml | grep -E '(dependencies:|react:|specifier:|version:)' | sed 's/^/  /'
    echo ""
}

get_react_version() {
    local package_path="$(pwd)/node_modules/react/package.json"
    local version=$(jq -r '.version' "$package_path")
    echo "✅ Installed: React $version"
    echo "   Path: $package_path (\"verson\" property)"
}

show_git_diff() {
    if git diff --quiet; then
        echo "📋 Git status: No changes"
    else
        echo "📋 Git diff detected changes:"
        git diff --stat
    fi
}

echo "🔍 Available React 19 versions:"
pnpm view react versions --json | jq -r '.[]' | grep '^19\.' | grep -v canary | grep -v rc | grep -v beta | grep -v alpha | sed 's/^/  /'
echo ""

echo "📊 INITIAL STATE:"
log_package_files
get_react_version

echo ""
echo "=========================================="
echo "TEST 1: Running pnpm install..."
pnpm install

echo ""
echo "Result:"
log_package_files
get_react_version
show_git_diff

echo ""
echo "=========================================="
echo "TEST 2: Remove lock file & reinstall"
echo "Action: rm pnpm-lock.yaml"
rm pnpm-lock.yaml

pnpm install

echo ""
echo "Result:"
log_package_files
get_react_version
show_git_diff

echo ""
echo "=========================================="
echo "TEST 3: Clean install (no lock, no node_modules)"
echo "Action: rm pnpm-lock.yaml && rm -rf node_modules"
rm pnpm-lock.yaml
rm -rf node_modules

pnpm install

echo ""
echo "Result:"
log_package_files
get_react_version
show_git_diff

echo ""
echo "=========================================="
echo "TEST 4: Restore lock from git, fresh node_modules"
echo "Action: git checkout pnpm-lock.yaml && rm -rf node_modules"
git checkout pnpm-lock.yaml
rm -rf node_modules

pnpm install

echo ""
echo "Result:"
log_package_files
get_react_version
show_git_diff

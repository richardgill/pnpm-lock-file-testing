#!/bin/bash

log_package_files() {
    echo "📦 package.json:"
    jq -c '.dependencies.react' package.json | sed 's/^/  react: /'
    echo ""
    local lock_version=$(grep -A1 'react:' pnpm-lock.yaml | grep 'version:' | head -1 | awk '{print $2}')
    echo "🔒 pnpm-lock.yaml: version $lock_version"
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

test() {
    local test_name="$1"
    local setup_action="$2"

    echo ""
    echo "=========================================="
    echo "$test_name"

    if [ -n "$setup_action" ]; then
        echo "Action: $setup_action"
        eval "$setup_action"
    fi

    echo ""
    echo "Before install:"
    log_package_files
    get_react_version

    pnpm install

    echo ""
    echo "After install:"
    log_package_files
    get_react_version
    show_git_diff

    # Restore git state
    echo ""
    echo "🔄 Restoring git state..."
    git checkout -- .
    rm -rf node_modules
    pnpm install --silent
}

echo "🔍 Available React 19 versions:"
pnpm view react versions --json | jq -r '.[]' | grep '^19\.' | grep -v canary | grep -v rc | grep -v beta | grep -v alpha | sed 's/^/  /'

# Run tests
test "TEST 1: Regular pnpm install"

test "TEST 2: Remove lock file & reinstall" "rm pnpm-lock.yaml"

test "TEST 3: Clean install (no lock, no node_modules)" "rm pnpm-lock.yaml && rm -rf node_modules"

test "TEST 4: Restore lock from git, fresh node_modules" "git checkout pnpm-lock.yaml && rm -rf node_modules"

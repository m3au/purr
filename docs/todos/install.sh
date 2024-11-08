#!/bin/sh

set -euo pipefail

VERSION=$(cat VERSION 2>/dev/null || echo "0.0.1")

# Installation logic
install_command() {
    info "Installing purr..."
    # Create XDG directories
    mkdir -p "$USER_CONFIG_DIR" "$USER_DATA_DIR/backups" "$USER_CACHE_DIR"
    chmod 700 "$USER_CONFIG_DIR" "$USER_DATA_DIR" "$USER_CACHE_DIR"

    # Install completion script
    mkdir -p "$COMPLETION_DIR"
    cp "$PURR_ROOT/src/completion/completion.zsh" "$COMPLETION_DIR/_purr"

    # Setup shell integration
    setup_shell_integration
}

# Generator logic
case "${1:-}" in
    --generate)
        case "${2:-}" in
            --test)
                cat << 'SCRIPT_START'
#!/bin/sh
PURR_TEST=1
TEST_DIST=tests/dist/purr-test.tar.gz
SCRIPT_START
                ;;
            *)
                cat << 'SCRIPT_START'
#!/bin/sh
VERSION=$VERSION
RELEASE_URL=https://github.com/m3au/purr/releases/download/v${VERSION}/purr-${VERSION}.tar.gz
SCRIPT_START
                ;;
        esac
        # Include our own installation logic
        cat "$0"
        ;;
    *)
        echo "Usage: $0 --generate [--test]"
        exit 1
        ;;
esac

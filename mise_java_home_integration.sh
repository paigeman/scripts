#!/bin/bash

# ==========================================
# Mise Java -> macOS System Integration Tool
# ==========================================
#
# Based on mise documentation:
# https://mise.jdx.dev/lang/java.html
#
# Note: Not all distributions support this integration (e.g. liberica)
# ==========================================

# 1. Check if mise exists
if ! command -v mise &> /dev/null; then
    echo "❌ Error: mise command not found. Please ensure it is installed and added to PATH."
    exit 1
fi

# 2. Get current Mise-activated Java information
# Get the currently activated version number (e.g., openjdk-21)
JAVA_VERSION_NAME=$(mise current java 2>/dev/null | awk '{print $1}')
# Get the absolute installation path of this version
JAVA_INSTALL_PATH=$(mise where java 2>/dev/null)

if [ -z "$JAVA_INSTALL_PATH" ]; then
    echo "❌ Error: No Mise Java version is active in the current directory."
    echo "💡 Please run: mise use java@21 (or your desired version)"
    exit 1
fi

# Additional validation: ensure version name is valid
if [ -z "$JAVA_VERSION_NAME" ]; then
    echo "❌ Error: Unable to retrieve Java version name."
    exit 1
fi

# 3. Define target path (following mise official documentation naming convention, no prefix)
TARGET_DIR="/Library/Java/JavaVirtualMachines/${JAVA_VERSION_NAME}.jdk"

# ==========================================
# Function Definitions
# ==========================================

function do_link() {
    echo "🔍 Detected current Java: $JAVA_VERSION_NAME"
    echo "📂 Source path: $JAVA_INSTALL_PATH"

    # --- Core check: Does the source JDK have a Contents directory? ---
    if [ ! -d "$JAVA_INSTALL_PATH/Contents" ]; then
        echo "⚠️  Warning: This JDK version does not contain the standard macOS 'Contents' directory structure."
        echo "🚫 This is a non-macOS standard build (possibly a Linux version) and cannot be directly linked to the system."
        echo "🧹 No cleanup needed, operation cancelled."
        exit 1
    fi

    # Check if target already exists
    if [ -d "$TARGET_DIR" ]; then
        echo "⚠️  Target already exists: $TARGET_DIR"
        read -p "Overwrite? (y/n): " confirm
        # Use tr to convert to lowercase for compatibility with older Bash versions (macOS default Bash 3.2)
        if [[ $(echo "$confirm" | tr '[:upper:]' '[:lower:]') != "y" ]]; then exit 0; fi

        if ! sudo rm -rf "$TARGET_DIR"; then
            echo "❌ Failed to remove old directory, please check permissions."
            exit 1
        fi
    fi

    echo "🚀 Starting link creation..."

    # Create directory and link following official documentation
    # Use && to ensure proper cleanup if mkdir succeeds but ln fails
    if sudo mkdir "$TARGET_DIR" && sudo ln -s "$JAVA_INSTALL_PATH/Contents" "$TARGET_DIR/Contents"; then
        echo "✅ Link created successfully!"
        echo "🔗 Mapping: $TARGET_DIR/Contents -> $JAVA_INSTALL_PATH/Contents"

        # Verify that the link points to the expected source path
        # Use realpath to normalize paths for comparison (handles potential relative path issues)
        REAL_LINK_TARGET=$(realpath "$TARGET_DIR/Contents" 2>/dev/null)
        EXPECTED_TARGET=$(realpath "$JAVA_INSTALL_PATH/Contents" 2>/dev/null)

        # If realpath is not available or fails, compare readlink results directly
        if [ -z "$REAL_LINK_TARGET" ] || [ -z "$EXPECTED_TARGET" ]; then
            REAL_LINK_TARGET=$(readlink "$TARGET_DIR/Contents")
            EXPECTED_TARGET="$JAVA_INSTALL_PATH/Contents"
        fi

        if [ "$REAL_LINK_TARGET" != "$EXPECTED_TARGET" ]; then
            echo "❌ Link target mismatch!"
            echo "   Expected: $EXPECTED_TARGET"
            echo "   Actual: $REAL_LINK_TARGET"
            echo "🧹 Performing cleanup..."
            sudo rm -rf "$TARGET_DIR"
            echo "✅ Cleanup completed."
            exit 1
        fi

        # Verify that macOS actually recognizes this JDK
        echo "------------------------------------------------"
        echo "🔎 Verifying if macOS recognizes this JDK..."
        # Check if the target directory appears in java_home output
        # Use -Fi for case-insensitive fixed string matching
        if /usr/libexec/java_home -V 2>&1 | grep -Fiq "${JAVA_VERSION_NAME}.jdk"; then
            echo "✅ macOS has successfully recognized this JDK!"
            echo "------------------------------------------------"
            echo ""
            echo "💡 Use the following command to view all available Java versions:"
            echo "   /usr/libexec/java_home -V"
        else
            echo "⚠️  macOS could not recognize this JDK."
            echo ""
            echo "📚 This usually means the distribution does not support macOS system integration."
            echo "💡 Common unsupported distributions include: liberica, etc."
            echo ""
            read -p "Keep the link anyway and continue? (y/n): " keep_link
            # Use tr to convert to lowercase for compatibility with older Bash versions (macOS default Bash 3.2)
            if [[ $(echo "$keep_link" | tr '[:upper:]' '[:lower:]') != "y" ]]; then
                echo "🧹 Performing cleanup..."
                sudo rm -rf "$TARGET_DIR"
                echo "✅ Cleanup completed."
                exit 1
            fi
        fi
        echo "------------------------------------------------"
    else
        echo "❌ Link command execution failed!"
        echo "🧹 Performing cleanup (removing empty directory)..."
        sudo rm -rf "$TARGET_DIR"
        echo "✅ Cleanup completed."
        exit 1
    fi
}

function do_unlink() {
    echo "🗑  Preparing to remove system mapping: $TARGET_DIR"
    
    if [ ! -d "$TARGET_DIR" ]; then
        echo "⚠️  This path does not exist, may not have been linked: $TARGET_DIR"
        exit 0
    fi

    sudo rm -rf "$TARGET_DIR"
    echo "✅ Link removed. Original Mise files retained, only system integration disconnected."
}

# ==========================================
# Main Logic
# ==========================================

ACTION=$1

case "$ACTION" in
    link)
        do_link
        ;;
    unlink)
        do_unlink
        ;;
    *)
        echo "Usage: $0 [link | unlink]"
        echo ""
        echo "  link   : Link current Mise Java to macOS system directory"
        echo "  unlink : Unlink current Mise Java from system"
        echo ""
        echo "Currently detected version: $JAVA_VERSION_NAME"
        exit 1
        ;;
esac
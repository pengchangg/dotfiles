#!/usr/bin/env bash
# ~/.config/lf/pv.sh — lf previewer
# Only previews text files. No images, no multimedia.
#
# Usage: pv.sh <file>
# lf calls this on every file selection change.

file="$1"

# ── Directory ─────────────────────────────────────────────────
if [[ -d "$file" ]]; then
    ls -lh --color=always "$file" | head -40
    exit 0
fi

# ── Not a regular file ────────────────────────────────────────
[[ -f "$file" ]] || { echo "(not a regular file)"; exit 0; }

# ── Empty file ────────────────────────────────────────────────
[[ -s "$file" ]] || { echo "(empty)"; exit 0; }

# ── Binary check ──────────────────────────────────────────────
mime=$(file -b --mime-type "$file" 2>/dev/null)
# Skip binary/archive/image/audio/video
case "$mime" in
    text/*|application/json|application/xml|application/javascript|application/x-shellscript|inode/x-empty)
        ;;
    *)
        echo "[binary: $mime — $({ LC_ALL=C stat -c%s "$file" 2>/dev/null | numfmt --to=iec; } 2>/dev/null || echo '?')]"
        exit 0
        ;;
esac

# ── Markdown → glow ───────────────────────────────────────────
ext="${file##*.}"
if [[ "$ext" == "md" || "$ext" == "markdown" || "$ext" == "mkd" || "$ext" == "mdx" ]]; then
    glow -s dark -w "${COLUMNS:-80}" "$file" 2>/dev/null
    exit $?
fi

# ── Other text → bat ──────────────────────────────────────────
bat --color=always --style=numbers,header --line-range :100 --wrap=auto "$file" 2>/dev/null

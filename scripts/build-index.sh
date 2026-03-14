#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_FILE="$ROOT_DIR/index.html"
PARTIALS_DIR="$ROOT_DIR/partials"
LAST_UPDATED="$(date '+%B %d, %Y')"

SECTIONS=(
  "about.html"
  "projects.html"
  "publications.html"
  "experience.html"
  "skills.html"
  "education.html"
  "service.html"
)

{
  printf '%s\n' '<!doctype html>'
  printf '%s\n' '<html lang="en">'
  printf '%s\n' '  <head>'
  sed 's/^/  /' "$PARTIALS_DIR/head-meta.html"
  printf '%s\n' '  </head>'
  printf '%s\n' '  <body id="page-top">'
  sed 's/^/  /' "$PARTIALS_DIR/nav.html"
  printf '%s\n' ''
  printf '%s\n' '    <main class="container-fluid p-0">'

  for part in "${SECTIONS[@]}"; do
    sed 's/^/  /' "$PARTIALS_DIR/$part"
    printf '%s\n' ''
  done

  printf '%s\n' '    </main>'
  printf '%s\n' ''
  sed "s/{{LAST_UPDATED}}/$LAST_UPDATED/g" "$PARTIALS_DIR/footer.html" | sed 's/^/  /'
  printf '%s\n' ''
  sed 's/^/  /' "$PARTIALS_DIR/schema.html"
  printf '%s\n' '  </body>'
  printf '%s\n' '</html>'
} > "$OUTPUT_FILE"

perl -0pi -e 's/[ \t]+\n/\n/g' "$OUTPUT_FILE"

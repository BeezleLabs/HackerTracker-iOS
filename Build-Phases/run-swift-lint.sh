set -Eeuo pipefail

# Adds support for Apple Silicon brew directory
export PATH="$PATH:/opt/homebrew/bin"

if ! command -v swiftlint > /dev/null; then
  echo "error: SwiftLint is not installed. Visit http://github.com/realm/SwiftLint to learn more."
  exit 1
fi

swiftlint

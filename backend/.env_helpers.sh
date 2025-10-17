# workspace helper: add npm global bin to PATH if present
if command -v npm >/dev/null 2>&1; then
  PG=$(npm bin -g 2>/dev/null || echo "")
  if [ -n "$PG" ] && [ -d "$PG" ]; then
    case ":$PATH:" in
      *":$PG:") ;;
      *) export PATH="$PG:$PATH" ;;
    esac
  fi
fi

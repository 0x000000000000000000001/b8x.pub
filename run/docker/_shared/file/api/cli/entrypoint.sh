#!/bin/bash

TARGET=${TARGET:-js}
SPAGO_PROFILE="spago.$TARGET.yaml"
if [ "$TARGET" = rust ]; then SPAGO_PROFILE=spago.yaml; fi

if [ ! -L /var/www/b8x/output ]; then
    ln -s "run/bak/$TARGET/output" /var/www/b8x/output 2>/dev/null || true
    ln -s "run/bak/$TARGET/.spago" /var/www/b8x/.spago 2>/dev/null || true
    ln -s "run/bak/$TARGET/$SPAGO_PROFILE" /var/www/b8x/spago.yaml 2>/dev/null || true
    ln -s "run/bak/$TARGET/spago.lock" /var/www/b8x/spago.lock 2>/dev/null || true
fi

NEW_PATH=""

while IFS= read -r dir; do
    case ":$NEW_PATH:" in
        *":$dir:"*) ;;
        *) NEW_PATH="${NEW_PATH:+$NEW_PATH:}$dir" ;;
    esac
done <<EOF
$(find "/var/www/b8x/bin" -type d 2>/dev/null)
EOF

export PATH="$NEW_PATH:$PATH"

# Persist for interactive shells (e.g. docker exec with portainer)
echo "export PATH=\"$NEW_PATH:\$PATH\"" > /etc/profile.d/b8x_path.sh
if [ -f /etc/bash.bashrc ] && ! grep -q "/etc/profile.d/b8x_path.sh" /etc/bash.bashrc; then
    echo ". /etc/profile.d/b8x_path.sh" >> /etc/bash.bashrc
fi

exec "$@"

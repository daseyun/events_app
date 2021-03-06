export MIX_ENV=prod
export PORT=4803

CFGD=$(readlink -f ~/.config/events_app)

if [ ! -e "$CFGD/base" ]; then
    echo "run deploy first"
    exit 1
fi

DB_PASS=$(cat "$CFGD/db_pass")
export DATABASE_URL=ecto://u_events:$DB_PASS@localhost/events_app_prod

SECRET_KEY_BASE=$(cat "$CFGD/base")
export SECRET_KEY_BASE

_build/prod/rel/events_app/bin/events_app start

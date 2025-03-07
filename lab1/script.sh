while true; do
    read -p "Введите название схемы: " SCHEMA_NAME

    if psql -tAc "SELECT 1 FROM information_schema.schemata WHERE schema_name = '$SCHEMA_NAME'" | grep -q 1; then
        has_create_privilege=$(psql -tAc "SELECT has_schema_privilege(current_user, '$SCHEMA_NAME', 'CREATE');")

        if [ "$has_create_privilege" != "t" ]; then
            echo "У вас нет прав на схему '$SCHEMA_NAME'. Попробуйте другую схему."
            continue
        fi

        psql -q -tA -v ON_ERROR_STOP=1 -c "CALL rename_columns_in_schema('$SCHEMA_NAME');" 2>&1 | sed 's/^INFO: //'
        break
    else
        echo "Схема не существует, попробуйте ещё раз."
    fi
done

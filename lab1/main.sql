CREATE OR REPLACE PROCEDURE rename_columns_in_schema(p_schema_name VARCHAR(63))
LANGUAGE plpgsql
AS $$
DECLARE
    column_record RECORD;
    new_column_name TEXT;
    columns_renamed INT := 0;
    tables_changed TEXT[] := '{}';
    schema_exists BOOLEAN;
    column_exists BOOLEAN;
    has_privilege BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1 FROM information_schema.schemata WHERE schema_name = p_schema_name
    ) INTO schema_exists;

    IF NOT schema_exists THEN
        RAISE INFO 'Схема "%" не существует', p_schema_name;
        RETURN;
    END IF;

    SELECT has_schema_privilege(current_user, p_schema_name, 'CREATE') OR
       has_schema_privilege(current_user, p_schema_name, 'USAGE')
    INTO has_privilege;

    IF NOT has_privilege THEN
        RAISE INFO 'У вас нет прав на схему "%". Попробуйте другую схему.', p_schema_name;
    END IF;


    FOR column_record IN
        SELECT table_name, column_name
        FROM information_schema.columns
        WHERE table_schema = p_schema_name
          AND (column_name ~ '["'']')
    LOOP
        new_column_name := regexp_replace(column_record.column_name, '["'']+', '', 'g');

        SELECT EXISTS (
            SELECT 1 FROM information_schema.columns
            WHERE table_schema = p_schema_name
              AND table_name = column_record.table_name
              AND column_name = new_column_name
        ) INTO column_exists;

        IF column_exists THEN
            RAISE INFO 'Пропускаем: в таблице "%" уже есть столбец "%"',
                column_record.table_name, new_column_name;
            CONTINUE;
        END IF;

        EXECUTE format('ALTER TABLE %I.%I RENAME COLUMN %I TO %I',
                       p_schema_name, column_record.table_name,
                       column_record.column_name, new_column_name);
        columns_renamed := columns_renamed + 1;

        IF NOT column_record.table_name = ANY(tables_changed) THEN
            tables_changed := array_append(tables_changed, column_record.table_name);
        END IF;
    END LOOP;

    RAISE INFO E'\nСхема: %\nCтолбцов переименовано: %\nТаблиц изменено: %',
                 p_schema_name, columns_renamed, COALESCE(array_length(tables_changed, 1), 0);
END;
$$;

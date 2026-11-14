package Infra_Client_Postgres_Postgres

import (
	"context"
	"fmt"
	"slices"
	"strconv"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Pools, dedicated connections and transactions expose the same query methods.
type postgresQuerier interface {
	Query(context.Context, string, ...any) (pgx.Rows, error)
	Exec(context.Context, string, ...any) (pgconn.CommandTag, error)
}

func _CreateConnectionPoolHandle(host string, port int64, database string, user string, password string, idleTimeoutMs int64) *pgxpool.Pool {
	connString := fmt.Sprintf("postgres://%s:%s@%s:%d/%s?pool_max_conns=100", user, password, host, port, database)
	config, err := pgxpool.ParseConfig(connString)
	if err != nil {
		panic(fmt.Sprintf("Failed to parse postgres config: %v", err))
	}
	pool, err := pgxpool.NewWithConfig(context.Background(), config)
	if err != nil {
		panic(fmt.Sprintf("Failed to create postgres pool: %v", err))
	}
	return pool
}

func _CloseHandle(pool *pgxpool.Pool) { pool.Close() }

// These are the application's SQL parameter conventions, including its chosen
// JSON serializer. Transporting Foreign values does not choose SQL encoding.
func postgresParameters(encodeJson func(any) string, params []any) ([]any, error) {
	if params == nil {
		return nil, nil
	}
	converted := make([]any, len(params))
	for i, value := range params {
		var err error
		converted[i], err = postgresParameter(encodeJson, value)
		if err != nil {
			return nil, err
		}
	}
	return converted, nil
}

func postgresParameter(encodeJson func(any) string, value any) (any, error) {
	switch value := value.(type) {
	case int64:
		return strconv.FormatInt(value, 10), nil
	case int:
		return strconv.Itoa(value), nil
	case float64:
		return strconv.FormatFloat(value, 'f', -1, 64), nil
	case bool:
		if value {
			return "t", nil
		}
		return "f", nil
	case map[string]any:
		return encodeJson(value), nil
	case []any:
		array, err := postgresArrayParameter(encodeJson, value)
		if err != nil {
			return nil, err
		}
		if len(array.Dims) <= 1 {
			return array.Elements, nil
		}
		return array, nil
	default:
		return value, nil
	}
}

// Explicit SDK dimensions prevent pgx from treating inner SQL arrays as JSON
// values when the element codec accepts slices (notably jsonb).
func postgresArrayParameter(encodeJson func(any) string, values []any) (pgtype.Array[any], error) {
	array := pgtype.Array[any]{Valid: values != nil}
	if values == nil {
		return array, nil
	}
	array.Dims = []pgtype.ArrayDimension{{Length: int32(len(values)), LowerBound: 1}}
	array.Elements = make([]any, 0, len(values))
	var childDims []pgtype.ArrayDimension
	nested := false
	for i, value := range values {
		child, isArray := value.([]any)
		if i == 0 {
			nested = isArray
		}
		if isArray != nested {
			return pgtype.Array[any]{}, fmt.Errorf("PostgreSQL array parameter has mixed dimensions")
		}
		if isArray {
			row, err := postgresArrayParameter(encodeJson, child)
			if err != nil {
				return pgtype.Array[any]{}, err
			}
			if len(child) == 0 || (i > 0 && !slices.Equal(childDims, row.Dims)) {
				return pgtype.Array[any]{}, fmt.Errorf("PostgreSQL array parameter has mismatched dimensions")
			}
			childDims = row.Dims
			array.Elements = append(array.Elements, row.Elements...)
		} else {
			element, err := postgresParameter(encodeJson, value)
			if err != nil {
				return pgtype.Array[any]{}, err
			}
			array.Elements = append(array.Elements, element)
		}
	}
	array.Dims = append(array.Dims, childDims...)
	return array, nil
}

func _Query(ctx context.Context, encodeJson func(any) string, handle postgresQuerier, query string, params []any) ([]any, error) {
	prepared, err := postgresParameters(encodeJson, params)
	if err != nil {
		return nil, err
	}
	rows, err := handle.Query(ctx, query, prepared...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	results := make([]any, 0)
	fields := rows.FieldDescriptions()
	for rows.Next() {
		values, err := rows.Values()
		if err != nil {
			return nil, err
		}
		row := make(map[string]any, len(fields))
		for i, field := range fields {
			row[field.Name] = values[i]
		}
		results = append(results, row)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	return results, nil
}

func _QueryCount(ctx context.Context, encodeJson func(any) string, handle postgresQuerier, query string, params []any) (int64, error) {
	prepared, err := postgresParameters(encodeJson, params)
	if err != nil {
		return 0, err
	}
	tag, err := handle.Exec(ctx, query, prepared...)
	if err != nil {
		return 0, err
	}
	return tag.RowsAffected(), nil
}

func _EscapeIdentifier(identifier string) string {
	return `"` + strings.ReplaceAll(identifier, `"`, `""`) + `"`
}

// A successful delivery transfers ownership to the PureScript caller. If
// cancellation wins during acquisition, the adapter invokes the release once.
func _Dedicate(ctx context.Context, pool *pgxpool.Pool) (*pgxpool.Conn, func(), error) {
	conn, err := pool.Acquire(ctx)
	if err != nil {
		return nil, nil, err
	}
	return conn, conn.Release, nil
}

func _Release(conn *pgxpool.Conn) { conn.Release() }

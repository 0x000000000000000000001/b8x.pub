package main

import (
	"context"
	"fmt"
	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	pool, err := pgxpool.New(context.Background(), "postgres://b8x:b8x@localhost:5432/store_test_01kz72rhx8jhgx9rjqfmx4mxfw")
	if err != nil {
		panic(err)
	}
	defer pool.Close()

	str := `["type1"]`
	rows, err := pool.Query(context.Background(), "SELECT unnest($1::text[])", str)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}
	defer rows.Close()

	count := 0
	for rows.Next() {
		count++
	}
	if rows.Err() != nil {
		fmt.Println("Rows Error:", rows.Err())
	} else {
		fmt.Println("Rows returned:", count)
	}
}

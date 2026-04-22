# Database File Order

Use these files in order:

1. `00_database.sql`
2. `01_tables.sql`
3. `02_indexes.sql`
4. `03_functions.sql`
5. `04_procedures.sql`
6. `05_views.sql`
7. `06_triggers.sql`
8. `07_seed_data.sql`
9. `08_demo_queries.sql`

If you want one split-file installer, use:

```sql
SOURCE init_all.sql;
```

If you want the older combined setup, use:

- `schema.sql`
- `seed.sql`

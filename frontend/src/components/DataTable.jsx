import { useMemo, useState } from "react";

export default function DataTable({ title, columns, rows, actions, searchPlaceholder = "Search records", filterKey }) {
  const [search, setSearch] = useState("");
  const [filterValue, setFilterValue] = useState("all");

  const filterOptions = useMemo(() => {
    if (!filterKey) return [];
    return [...new Set(rows.map((row) => row[filterKey]).filter(Boolean))];
  }, [rows, filterKey]);

  const filteredRows = useMemo(() => {
    return rows.filter((row) => {
      const rowMatchesSearch =
        search.trim() === "" ||
        Object.values(row).some((value) =>
          String(value ?? "")
            .toLowerCase()
            .includes(search.toLowerCase())
        );

      const rowMatchesFilter = filterKey ? filterValue === "all" || row[filterKey] === filterValue : true;

      return rowMatchesSearch && rowMatchesFilter;
    });
  }, [rows, search, filterKey, filterValue]);

  return (
    <section className="rounded-3xl border border-black/5 bg-white/80 p-5 shadow-glow">
      <div className="mb-4 flex items-center justify-between">
        <h3 className="font-display text-2xl text-brand-forest">{title}</h3>
        <span className="text-sm text-slate-500">{filteredRows.length} records</span>
      </div>
      <div className="mb-4 flex flex-col gap-3 md:flex-row">
        <input
          value={search}
          onChange={(event) => setSearch(event.target.value)}
          placeholder={searchPlaceholder}
          className="w-full rounded-2xl border border-slate-200 bg-white px-4 py-3 outline-none focus:border-brand-forest"
        />
        {filterKey ? (
          <select
            value={filterValue}
            onChange={(event) => setFilterValue(event.target.value)}
            className="rounded-2xl border border-slate-200 bg-white px-4 py-3 outline-none focus:border-brand-forest"
          >
            <option value="all">All</option>
            {filterOptions.map((option) => (
              <option key={option} value={option}>
                {option}
              </option>
            ))}
          </select>
        ) : null}
      </div>
      <div className="overflow-x-auto">
        <table className="min-w-full text-sm">
          <thead>
            <tr className="border-b border-slate-200 text-left text-slate-500">
              {columns.map((column) => (
                <th key={column.key} className="px-3 py-3 font-medium">{column.label}</th>
              ))}
              {actions ? <th className="px-3 py-3 font-medium">Actions</th> : null}
            </tr>
          </thead>
          <tbody>
            {filteredRows.map((row, index) => (
              <tr key={index} className="border-b border-slate-100">
                {columns.map((column) => (
                  <td key={column.key} className="px-3 py-3">
                    {row[column.key] ?? "-"}
                  </td>
                ))}
                {actions ? (
                  <td className="px-3 py-3">
                    <div className="flex flex-wrap gap-2">
                      {actions(row).map((action) => (
                        <button
                          key={action.label}
                          type="button"
                          onClick={(event) => {
                            event.preventDefault();
                            event.stopPropagation();
                            if (!action.disabled) {
                              action.onClick();
                            }
                          }}
                          disabled={action.disabled}
                          className={`rounded-full px-3 py-1 text-xs font-medium ${
                            action.variant === "danger"
                              ? "bg-red-100 text-red-700"
                              : "bg-brand-forest/10 text-brand-forest"
                          } ${action.disabled ? "cursor-not-allowed opacity-40" : ""}`}
                        >
                          {action.label}
                        </button>
                      ))}
                    </div>
                  </td>
                ) : null}
              </tr>
            ))}
            {!filteredRows.length ? (
              <tr>
                <td colSpan={columns.length + (actions ? 1 : 0)} className="px-3 py-8 text-center text-slate-500">
                  No records match the current view.
                </td>
              </tr>
            ) : null}
          </tbody>
        </table>
      </div>
    </section>
  );
}

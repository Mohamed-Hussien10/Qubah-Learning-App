import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:web_dashboard/core/constants/app_colors.dart';
import 'package:web_dashboard/core/constants/app_strings.dart';
import 'package:web_dashboard/core/widgets/empty_state_widget.dart';
import 'package:web_dashboard/core/widgets/loading_widget.dart';

/// Definition of a column in the data table.
class AppDataColumn {
  final String label;
  final double? fixedWidth;
  final ColumnSize size;
  final bool numeric;
  final bool sortable;

  const AppDataColumn({
    required this.label,
    this.fixedWidth,
    this.size = ColumnSize.M,
    this.numeric = false,
    this.sortable = true,
  });
}

/// Reusable data table wrapper with search, pagination, sorting, selection,
/// and action buttons.
class DataTableWidget<T> extends StatefulWidget {
  /// Column definitions.
  final List<AppDataColumn> columns;

  /// The data rows.
  final List<T> data;

  /// Builds cells for a single row.
  final List<DataCell> Function(T item) cellBuilder;

  /// Whether the table is loading.
  final bool isLoading;

  /// Current sort column index.
  final int? sortColumnIndex;

  /// Current sort ascending.
  final bool sortAscending;

  /// Called when a column header is tapped for sorting.
  final void Function(int columnIndex, bool ascending)? onSort;

  /// Whether rows are selectable.
  final bool selectable;

  /// Currently selected items.
  final Set<T>? selectedItems;

  /// Called when selection changes.
  final void Function(Set<T> selected)? onSelectionChanged;

  /// Called when "Add" button is pressed.
  final VoidCallback? onAdd;

  /// Called when "Delete Selected" is pressed.
  final VoidCallback? onDeleteSelected;

  /// Called when "Export" is pressed.
  final VoidCallback? onExport;

  /// Title for the add button.
  final String? addButtonLabel;

  /// Search hint text.
  final String? searchHint;

  /// Called when search text changes.
  final void Function(String query)? onSearch;

  /// Total number of rows (for server-side pagination).
  final int? totalRows;

  /// Rows per page.
  final int rowsPerPage;

  /// Called when page changes.
  final void Function(int page)? onPageChanged;

  /// Current page (0-indexed).
  final int currentPage;

  /// Optional header actions.
  final List<Widget>? headerActions;

  /// Empty state message.
  final String? emptyMessage;

  /// Key extractor for selection identification.
  final dynamic Function(T item)? keyExtractor;

  const DataTableWidget({
    super.key,
    required this.columns,
    required this.data,
    required this.cellBuilder,
    this.isLoading = false,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    this.selectable = false,
    this.selectedItems,
    this.onSelectionChanged,
    this.onAdd,
    this.onDeleteSelected,
    this.onExport,
    this.addButtonLabel,
    this.searchHint,
    this.onSearch,
    this.totalRows,
    this.rowsPerPage = 10,
    this.onPageChanged,
    this.currentPage = 0,
    this.headerActions,
    this.emptyMessage,
    this.keyExtractor,
  });

  @override
  State<DataTableWidget<T>> createState() => _DataTableWidgetState<T>();
}

class _DataTableWidgetState<T> extends State<DataTableWidget<T>> {
  final _searchController = TextEditingController();
  late Set<T> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedItems ?? {};
  }

  @override
  void didUpdateWidget(covariant DataTableWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedItems != null) {
      _selected = widget.selectedItems!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _totalPages {
    final total = widget.totalRows ?? widget.data.length;
    return (total / widget.rowsPerPage).ceil().clamp(1, 999);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────────
          _buildHeader(theme, isDark),

          // ── Divider ─────────────────────────────────────────────────
          Divider(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),

          // ── Table ───────────────────────────────────────────────────
          Expanded(child: _buildTable(theme, isDark)),

          // ── Pagination ──────────────────────────────────────────────
          if (widget.onPageChanged != null) ...[
            Divider(
              height: 1,
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
            _buildPagination(theme, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Search bar
          if (widget.onSearch != null)
            SizedBox(
              width: 300,
              child: TextField(
                controller: _searchController,
                onChanged: widget.onSearch,
                decoration: InputDecoration(
                  hintText: widget.searchHint ?? AppStrings.search,
                  prefixIcon:
                      const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            widget.onSearch?.call('');
                          },
                        )
                      : null,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                ),
              ),
            ),

          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Custom header actions
              if (widget.headerActions != null) ...widget.headerActions!,

              // Delete selected
              if (widget.onDeleteSelected != null && _selected.isNotEmpty) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: widget.onDeleteSelected,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: Text(
                      '${AppStrings.deleteSelected} (${_selected.length})'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ],

              // Export
              if (widget.onExport != null) ...[
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: widget.onExport,
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: const Text(AppStrings.exportData),
                ),
              ],

              // Add button
              if (widget.onAdd != null) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: widget.onAdd,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Text(widget.addButtonLabel ?? AppStrings.add),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTable(ThemeData theme, bool isDark) {
    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: LoadingWidget.table(),
      );
    }

    if (widget.data.isEmpty) {
      return EmptyStateWidget(
        title: widget.emptyMessage ?? AppStrings.noData,
        icon: Icons.table_rows_rounded,
        actionLabel: widget.onAdd != null ? AppStrings.add : null,
        onAction: widget.onAdd,
      );
    }

    return DataTable2(
      columnSpacing: 16,
      horizontalMargin: 16,
      minWidth: 600,
      sortColumnIndex: widget.sortColumnIndex,
      sortAscending: widget.sortAscending,
      showCheckboxColumn: widget.selectable,
      headingRowColor: WidgetStateProperty.all(
        isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
      ),
      headingRowDecoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      columns: widget.columns
          .map(
            (col) => DataColumn2(
              label: Text(col.label),
              size: col.size,
              fixedWidth: col.fixedWidth,
              numeric: col.numeric,
              onSort: col.sortable && widget.onSort != null
                  ? (colIndex, asc) => widget.onSort!(colIndex, asc)
                  : null,
            ),
          )
          .toList(),
      rows: widget.data.map((item) {
        final isSelected = _selected.contains(item);
        return DataRow2(
          selected: isSelected,
          onSelectChanged: widget.selectable
              ? (selected) {
                  setState(() {
                    if (selected == true) {
                      _selected.add(item);
                    } else {
                      _selected.remove(item);
                    }
                  });
                  widget.onSelectionChanged?.call(_selected);
                }
              : null,
          cells: widget.cellBuilder(item),
        );
      }).toList(),
    );
  }

  Widget _buildPagination(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Info text
          Text(
            'صفحة ${widget.currentPage + 1} من $_totalPages',
            style: theme.textTheme.bodySmall,
          ),

          // Page controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.first_page_rounded, size: 20),
                onPressed:
                    widget.currentPage > 0 ? () => widget.onPageChanged!(0) : null,
                visualDensity: VisualDensity.compact,
                tooltip: 'الصفحة الأولى',
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 20),
                onPressed: widget.currentPage > 0
                    ? () => widget.onPageChanged!(widget.currentPage - 1)
                    : null,
                visualDensity: VisualDensity.compact,
                tooltip: 'الصفحة السابقة',
              ),

              // Page number
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.currentPage + 1}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),

              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 20),
                onPressed: widget.currentPage < _totalPages - 1
                    ? () => widget.onPageChanged!(widget.currentPage + 1)
                    : null,
                visualDensity: VisualDensity.compact,
                tooltip: 'الصفحة التالية',
              ),
              IconButton(
                icon: const Icon(Icons.last_page_rounded, size: 20),
                onPressed: widget.currentPage < _totalPages - 1
                    ? () => widget.onPageChanged!(_totalPages - 1)
                    : null,
                visualDensity: VisualDensity.compact,
                tooltip: 'الصفحة الأخيرة',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

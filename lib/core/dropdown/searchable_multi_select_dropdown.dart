// lib/core/widgets/dropdown/searchable_multi_select_dropdown.dart

import 'package:flutter/material.dart';

/// A searchable, multi-select dropdown that matches the purple-themed design.
///
/// Usage:
/// ```dart
/// SearchableMultiSelectDropdown(
///   hint: 'Select cities',
///   icon: '🏙️',
///   items: ['New Jersey', 'New Orleans', 'New York', 'Boston'],
///   selectedItems: _selected,
///   onChanged: (items) => setState(() => _selected = items),
/// )
/// ```
class SearchableMultiSelectDropdown extends StatefulWidget {
  final String hint;
  final String icon;
  final List<String> items;
  final List<String> selectedItems;
  final ValueChanged<List<String>> onChanged;

  /// For single-select mode, set [multiSelect] to false.
  final bool multiSelect;

  const SearchableMultiSelectDropdown({
    super.key,
    required this.hint,
    required this.icon,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
    this.multiSelect = true,
  });

  @override
  State<SearchableMultiSelectDropdown> createState() =>
      _SearchableMultiSelectDropdownState();
}

class _SearchableMultiSelectDropdownState
    extends State<SearchableMultiSelectDropdown>
    with SingleTickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  bool _isOpen = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _filtered = [];
  late List<String> _selected;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  // ── Colours ────────────────────────────────────────────────────────────────
  static const _purple = Color(0xFF5B5BD6);
  static const _purpleLight = Color(0xFFEEEEFA);
  static const _border = Color(0xFFE0E0E0);
  static const _textDark = Color(0xFF1A1A1A);
  static const _textGrey = Color(0xFF9E9E9E);

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedItems);
    _filtered = List.from(widget.items);
    _searchController.addListener(_onSearch);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isOpen) _close();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearch);
    _searchController.dispose();
    _focusNode.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  // ── Search ─────────────────────────────────────────────────────────────────
  void _onSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() => _isSearching = query.isNotEmpty);

    // Simulate async search with brief spinner
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      final results = query.isEmpty
          ? List<String>.from(widget.items)
          : widget.items
          .where((e) => e.toLowerCase().contains(query))
          .toList();
      setState(() {
        _filtered = results;
        _isSearching = false;
      });
      _overlayEntry?.markNeedsBuild();
    });
  }

  // ── Overlay ────────────────────────────────────────────────────────────────
  void _open() {
    _filtered = List.from(widget.items);
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
    _focusNode.requestFocus();
  }

  void _close() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _searchController.clear();
    _filtered = List.from(widget.items);
    setState(() {
      _isOpen = false;
      _isSearching = false;
    });
  }

  void _toggle() => _isOpen ? _close() : _open();

  void _toggleItem(String item) {
    setState(() {
      if (_selected.contains(item)) {
        _selected.remove(item);
      } else {
        if (widget.multiSelect) {
          _selected.add(item);
        } else {
          _selected = [item];
        }
      }
    });
    widget.onChanged(List.from(_selected));
    _overlayEntry?.markNeedsBuild();
    if (!widget.multiSelect) _close();
  }

  OverlayEntry _buildOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (ctx) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            color: Colors.transparent,
            child: _DropdownList(
              filtered: _filtered,
              selected: _selected,
              isSearching: _isSearching,
              icon: widget.icon,
              onToggle: _toggleItem,
              purple: _purple,
              textDark: _textDark,
              textGrey: _textGrey,
            ),
          ),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final hasValue = _selected.isNotEmpty;

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isOpen ? _purple : _border,
              width: _isOpen ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _isOpen
          // ── Search field ──────────────────────────────────────
              ? Row(
            children: [
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  style: const TextStyle(
                    fontSize: 15,
                    color: _textDark,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: _textGrey, fontSize: 15),
                    isDense: true,
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (_isSearching)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _purple,
                  ),
                )
              else
                GestureDetector(
                  onTap: _close,
                  child: const Icon(Icons.close,
                      size: 18, color: _textGrey),
                ),
              const SizedBox(width: 14),
            ],
          )
          // ── Collapsed display ─────────────────────────────────
              : Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Text(widget.icon,
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasValue
                        ? _selected.join(', ')
                        : widget.hint,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      color: hasValue ? _textDark : _textGrey,
                      fontWeight: hasValue
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 22, color: Color(0xFF6B6B6B)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Dropdown list (rendered in overlay) ────────────────────────────────────
class _DropdownList extends StatelessWidget {
  final List<String> filtered;
  final List<String> selected;
  final bool isSearching;
  final String icon;
  final ValueChanged<String> onToggle;
  final Color purple;
  final Color textDark;
  final Color textGrey;

  const _DropdownList({
    required this.filtered,
    required this.selected,
    required this.isSearching,
    required this.icon,
    required this.onToggle,
    required this.purple,
    required this.textDark,
    required this.textGrey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 260),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: filtered.isEmpty
            ? Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'No results found',
              style: TextStyle(color: textGrey, fontSize: 14),
            ),
          ),
        )
            : ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: filtered.length,
          itemBuilder: (ctx, i) {
            final item = filtered[i];
            final isSelected = selected.contains(item);
            return _DropdownItem(
              label: item,
              icon: icon,
              isSelected: isSelected,
              onTap: () => onToggle(item),
              purple: purple,
              textDark: textDark,
              textGrey: textGrey,
            );
          },
        ),
      ),
    );
  }
}

// ── Individual dropdown item ────────────────────────────────────────────────
class _DropdownItem extends StatelessWidget {
  final String label;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color purple;
  final Color textDark;
  final Color textGrey;

  const _DropdownItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.purple,
    required this.textDark,
    required this.textGrey,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: isSelected ? purple : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            // Emoji icon in a rounded square container
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.20)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : textDark,
                ),
              ),
            ),
            // Checkmark on the right when selected
            if (isSelected)
              const Icon(Icons.check_rounded, size: 18, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
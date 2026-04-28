import 'package:flutter/material.dart';
import '../models/filter_state.dart';

class FiltersBottomSheet extends StatefulWidget {
  final FilterState initial;

  const FiltersBottomSheet({super.key, required this.initial});

  @override
  State<FiltersBottomSheet> createState() => _FiltersBottomSheetState();
}

class _FiltersBottomSheetState extends State<FiltersBottomSheet> {
  late FilterState state;

  final types = const ['All', 'SUV', 'Sedan', 'Hatchback'];
  final sorts = const ['None', 'priceAsc', 'priceDesc'];

  @override
  void initState() {
    super.initState();
    state = widget.initial.copy();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              const SizedBox(height: 16),

              const Text('Car Type', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              _dropdown(
                value: state.type,
                items: types,
                onChanged: (v) => setState(() => state.type = v ?? 'All'),
              ),

              const SizedBox(height: 16),
              const Text('Price Range (₪/day)', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              RangeSlider(
                min: 0,
                max: 300,
                divisions: 30,
                labels: RangeLabels(
                  state.minPrice.round().toString(),
                  state.maxPrice.round().toString(),
                ),
                values: RangeValues(state.minPrice, state.maxPrice),
                onChanged: (v) => setState(() {
                  state.minPrice = v.start;
                  state.maxPrice = v.end;
                }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Min: ${state.minPrice.round()}'),
                  Text('Max: ${state.maxPrice.round()}'),
                ],
              ),

              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Available only', style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle: const Text('Show only available cars'),
                value: state.availableOnly,
                onChanged: (v) => setState(() => state.availableOnly = v),
              ),

              const SizedBox(height: 8),
              const Text('Sort', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              _dropdown(
                value: state.sort,
                items: sorts,
                onChanged: (v) => setState(() => state.sort = v ?? 'None'),
              ),

              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, FilterState()),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, state),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Filters',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

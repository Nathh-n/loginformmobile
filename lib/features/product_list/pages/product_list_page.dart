import 'package:flutter/material.dart';
import '../controllers/product_list_controller.dart';
import '../widgets/product_tile.dart';

class ProductListPage extends StatefulWidget {
  final ProductListController controller;

  const ProductListPage({super.key, required this.controller});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Fetch halaman pertama, tapi cuma kalau listnya masih kosong
    // (biar gak fetch ulang tiap kali balik ke tab ini).
    if (widget.controller.items.isEmpty) {
      widget.controller.loadMore();
    }

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final threshold = _scrollController.position.maxScrollExtent - 200;
    if (_scrollController.position.pixels >= threshold) {
      widget.controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            itemCount: controller.items.length + 1,
            itemBuilder: (context, index) {
              // Item terakhir: slot khusus buat indikator loading/error/habis.
              if (index == controller.items.length) {
                return _buildFooter(controller);
              }
              return ProductTile(product: controller.items[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildFooter(ProductListController controller) {
    if (controller.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            controller.errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (controller.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!controller.hasMore) {
      return const SizedBox.shrink();
    }

    return const SizedBox.shrink();
  }
}
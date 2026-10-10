
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../services/api_service.dart';
import '../providers/cart_provider.dart';
import '../providers/theme_provider.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() =>
      _ProductListScreenState();
}

class _ProductListScreenState
    extends State<ProductListScreen> {
  final ApiService apiService = ApiService();
  final TextEditingController searchController =
      TextEditingController();

  late Future<List<Product>> productsFuture;

  String searchText = '';
  String selectedCategory = 'All';
  bool favoritesOnly = false;

  @override
  void initState() {
    super.initState();
    productsFuture = apiService.getProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> refreshProducts() async {
    final future = apiService.getProducts();

    setState(() {
      productsFuture = future;
    });

    try {
      await future;
    } catch (_) {
      // FutureBuilder displays the error.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ShopEasy',
                      style: TextStyle(
                fontWeight: FontWeight.bold,
                      fontSize: 23,
              ),
            ),
            Text(
              'Find your favourites',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                tooltip: 'Toggle dark mode',
                onPressed: themeProvider.toggleTheme,
                icon: Icon(
                  themeProvider.isDarkMode
                      ? Icons.light_mode
                      : Icons.dark_mode_outlined,
                ),
              );
            },
          ),
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                            Icons.shopping_bag_outlined,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CartScreen(),
                        ),
                      );
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: Colors.deepPurple,
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // const Icon(
                    //   Icons.wifi_off_rounded,
                    //   size: 55,
                    // ),
                    const SizedBox(height: 12),
                    const Text('Unable to load products'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: refreshProducts,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(
              child: Text('No products available'),
            );
          }

          final categories = <String>[
            'All',
            ...products.map((p) => p.category).toSet(),
          ];

          final filteredProducts = products.where((product) {
            final matchesSearch = product.title
                .toLowerCase()
                .contains(searchText.toLowerCase());

            final matchesCategory =
                selectedCategory == 'All' ||
                     product.category == selectedCategory;

            return matchesSearch && matchesCategory;
          }).toList();

          return RefreshIndicator(
            onRefresh: refreshProducts,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF6750A4),
                        Color(0xFF9580D9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Discover your style',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Find something you will love.',
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchText.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();
                              setState(() {
                                searchText = '';
                              });
                            },
                            icon: const Icon(Icons.close),
                          )
                        : null,
                    filled: true,
                    fillColor: theme.cardTheme.color ??
                        theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(
                              category,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedCategory = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilterChip(
                      label: const Text('Wishlist'),
                      avatar: Icon(
                        favoritesOnly
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 18,
                      ),
                      selected: favoritesOnly,
                      onSelected: (value) {
                        setState(() {
                          favoritesOnly = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      favoritesOnly
                          ? 'My Wishlist'
                          : 'Popular Products',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${filteredProducts.where((p) => !favoritesOnly || context.read<CartProvider>().isWishlisted(p.id)).length} items',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    final visibleProducts =
                        filteredProducts.where((product) {
                      return !favoritesOnly ||
                          cart.isWishlisted(product.id);
                    }).toList();

                    if (visibleProducts.isEmpty) {
                      return Padding(
                             padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 50,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              favoritesOnly
                                  ? 'Your wishlist is empty'
                                  : 'No matching products found',
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: visibleProducts.length,
                     
gridDelegate:
    const SliverGridDelegateWithFixedCrossAxisCount(
  crossAxisCount: 2,
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
  childAspectRatio: 0.48,
),
                      itemBuilder: (context, index) {
                        final product = visibleProducts[index];

                        return Card(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailsScreen(
                                    product: product,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.all(12),
                                          child: Image.network(
                                            product.image,
                                            fit: BoxFit.contain,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stack,
                                            ) {
                                              return const Icon(
                                                Icons.broken_image,
                                                size: 45,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 4,
                                        top: 4,
                                        child: IconButton(
                                          tooltip: 'Wishlist',
                                          onPressed: () {
                                            cart.toggleWishlist(
                                              product,
                                            );
                                          },
                                          icon: Icon(
                                            cart.isWishlisted(
                                              product.id,
                                            )
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: cart.isWishlisted(
                                              product.id,
                                            )
                                                ? Colors.red
                                                : theme.colorScheme
                                                    .onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(
                                      10, 4, 10, 10,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.category
                                              .toUpperCase(),
                                          maxLines: 1,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: theme
                                                .colorScheme.primary,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          product.title,
                                          maxLines: 2,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight:
                                                FontWeight.w600,
                                          ),
                                        ),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '\$${product.price.toStringAsFixed(2)}',
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton.filled(
                                              tooltip: 'Add to cart',
                                              padding:
                                                  EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(
                                                minWidth: 36,
                                                minHeight: 36,
                                              ),
                                              onPressed: () {
                                                cart.addToCart(
                                                  product,
                                                );

                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Added to cart',
                                                    ),
                                                    duration:
                                                        Duration(
                                                      seconds: 1,
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.add,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
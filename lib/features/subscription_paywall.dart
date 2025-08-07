// lib/features/pages/subscription_paywall.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../core/providers/revenuecat_provider.dart';

class SubscriptionPaywall extends ConsumerWidget {
  const SubscriptionPaywall({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offeringsAsync = ref.watch(offeringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("S'abonner"),
      ),
      body: offeringsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: $err')),
        data: (offerings) {
          if (offerings == null || offerings.current == null) {
            return const Center(child: Text('Aucune offre disponible.'));
          }

          final packages = offerings.current!.availablePackages;

          return ListView.builder(
            itemCount: packages.length,
            itemBuilder: (context, index) {
              final package = packages[index];
              final product = package.storeProduct;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(product.title),
                  subtitle: Text(product.description),
                  trailing: Text(product.priceString),
                  onTap: () async {
                    final service = ref.read(revenueCatServiceProvider);
                    try {
                      await service.purchasePackage(package);

                      // Tu peux ensuite actualiser les données locales ici si besoin.
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Abonnement réussi !")),
                        );
                        Navigator.pop(context); // Retour à la page précédente
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Erreur : $e")),
                        );
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import '../features/ownership/application/determine_ownership_use_case.dart';
import '../features/ownership/data/local_ownership_repository.dart';
import '../features/ownership/data/ownership_database_loader.dart';
import '../features/product_lookup/application/lookup_product_by_barcode_use_case.dart';
import '../features/product_lookup/application/lookup_product_ownership_by_barcode_use_case.dart';
import '../features/product_lookup/data/api/open_food_facts_client.dart';
import '../features/product_lookup/data/repository/open_food_facts_product_repository.dart';

class AppDependencies {
  const AppDependencies({
    required this.lookupProductOwnershipByBarcodeUseCase,
    required this.determineOwnershipUseCase,
  });

  factory AppDependencies.production() {
    final openFoodFactsClient = OpenFoodFactsClient();

    final productRepository = OpenFoodFactsProductRepository(
      client: openFoodFactsClient,
    );

    final ownershipRepository = LocalOwnershipRepository(
      databaseLoader: OwnershipDatabaseLoader(),
    );

    final lookupProductByBarcodeUseCase = LookupProductByBarcodeUseCase(
      productRepository: productRepository,
    );

    final determineOwnershipUseCase = DetermineOwnershipUseCase(
      ownershipRepository: ownershipRepository,
    );

    final lookupProductOwnershipByBarcodeUseCase =
        LookupProductOwnershipByBarcodeUseCase(
          lookupProductByBarcodeUseCase: lookupProductByBarcodeUseCase,
          determineOwnershipUseCase: determineOwnershipUseCase,
        );

    return AppDependencies(
      lookupProductOwnershipByBarcodeUseCase:
          lookupProductOwnershipByBarcodeUseCase,
      determineOwnershipUseCase: determineOwnershipUseCase,
    );
  }

  final LookupProductOwnershipByBarcodeUseCase
  lookupProductOwnershipByBarcodeUseCase;

  final DetermineOwnershipUseCase determineOwnershipUseCase;
}

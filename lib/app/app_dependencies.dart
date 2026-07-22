import '../features/ownership/application/determine_ownership_use_case.dart';
import '../features/ownership/data/local_ownership_repository.dart';
import '../features/ownership/data/ownership_database_loader.dart';
import '../features/ownership/domain/ownership_repository.dart';
import '../features/product_lookup/application/lookup_product_by_barcode_use_case.dart';
import '../features/product_lookup/application/lookup_product_ownership_by_barcode_use_case.dart';
import '../features/product_lookup/data/api/open_food_facts_client.dart';
import '../features/product_lookup/data/repository/open_food_facts_product_repository.dart';
import '../features/product_lookup/domain/product_repository.dart';

class AppDependencies {
  AppDependencies();

  late final OpenFoodFactsClient openFoodFactsClient = OpenFoodFactsClient();

  late final ProductRepository productRepository =
      OpenFoodFactsProductRepository(client: openFoodFactsClient);

  late final OwnershipRepository ownershipRepository = LocalOwnershipRepository(
    databaseLoader: OwnershipDatabaseLoader(),
  );

  late final LookupProductByBarcodeUseCase lookupProductByBarcodeUseCase =
      LookupProductByBarcodeUseCase(productRepository: productRepository);

  late final DetermineOwnershipUseCase determineOwnershipUseCase =
      DetermineOwnershipUseCase(ownershipRepository: ownershipRepository);

  late final LookupProductOwnershipByBarcodeUseCase
  lookupProductOwnershipByBarcodeUseCase =
      LookupProductOwnershipByBarcodeUseCase(
        lookupProductByBarcodeUseCase: lookupProductByBarcodeUseCase,
        determineOwnershipUseCase: determineOwnershipUseCase,
      );
}

import 'package:flasholator/core/services/ad_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingAdService extends AdService {
  int loadCount = 0;

  @override
  Future<void> loadInterstitial(Future<bool> Function() eligible) async {
    loadCount++;
  }
}

void main() {
  test('un interstitiel refusé ou inconnu ne déclenche aucun chargement',
      () async {
    final service = _RecordingAdService();
    await service.showInterstitial(() async => false);
    expect(service.loadCount, 0);
    await service.showInterstitial(() async {
      throw StateError('autorisation indisponible');
    });
    expect(service.loadCount, 0);
  });

  test('un interstitiel autorisé peut être demandé', () async {
    final service = _RecordingAdService();
    await service.showInterstitial(() async => true);
    expect(service.loadCount, 1);
  });
}

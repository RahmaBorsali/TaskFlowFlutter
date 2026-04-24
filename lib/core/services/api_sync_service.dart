import 'package:flutter/foundation.dart';

/// Simule une synchronisation avec une API REST 
class ApiSyncService {
  static Future<bool> syncDataWithCloud() async {
    debugPrint('🔄 Début de la synchronisation avec l\'API REST (Mock)...');
    
    try {
      // Simulation d'un délai réseau de 2 secondes
      await Future.delayed(const Duration(seconds: 2));
      
      
      debugPrint('✅ Synchronisation API réussie.');
      return true;
    } catch (e) {
      debugPrint('❌ Échec de la synchronisation: $e');
      return false;
    }
  }
}

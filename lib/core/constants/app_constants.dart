class AppConstants {
  static const String appName = 'AgriExpert';
  static const String appVersion = '1.0.0';

  // API
  static const String devBaseUrl = 'http://192.168.1.100:5000/api/v1';
  static const String prodBaseUrl = 'https://api.agriexpert.com/api/v1';
  static const String baseUrl = devBaseUrl;

  // Crop options
  static const List<String> cropOptions = [
    'Rice', 'Wheat', 'Cotton', 'Sugarcane', 'Maize', 'Soybean', 'Groundnut',
    'Tomato', 'Potato', 'Onion', 'Chilli', 'Turmeric', 'Banana', 'Mango', 'Coconut',
  ];

  // Soil types
  static const List<String> soilTypes = [
    'clay', 'sandy', 'loamy', 'silt', 'peat', 'chalky', 'other',
  ];

  // Irrigation types
  static const List<String> irrigationTypes = [
    'rainfed', 'drip', 'sprinkler', 'flood', 'canal', 'borewell', 'other',
  ];

  // Community topic filters
  static const List<String> topicFilters = [
    'pest', 'irrigation', 'fertilizer', 'disease', 'harvest', 'soil',
  ];

  // Task category icons
  static const Map<String, String> categoryIcons = {
    'land_prep': '🚜',
    'sowing': '🌱',
    'irrigation': '💧',
    'fertilizer': '🧪',
    'pesticide': '🐛',
    'weeding': '🌿',
    'harvest': '🌾',
    'post_harvest': '📦',
    'other': '📋',
  };

  // Open source placeholder images
  static const String heroFarmImage = 'https://images.unsplash.com/photo-1500595046743-cd271d694d30?w=800&q=80';
  static const String cropFieldImage = 'https://images.unsplash.com/photo-1574943320219-553eb213f72d?w=600&q=80';
  static const String soilImage = 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=600&q=80';
  static const String marketImage = 'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=600&q=80';
  static const String communityImage = 'https://images.unsplash.com/photo-1593113598332-cd288d649433?w=600&q=80';
  static const String weatherImage = 'https://images.unsplash.com/photo-1504386106331-3e4e71712b38?w=600&q=80';
}

import 'package:flutter/foundation.dart';
import 'package:hearth_prayer/models/dua.dart';

enum Category { all, personal, health, newOnly }

class MyDuasController extends ChangeNotifier {
  String _query = '';
  Category _category = Category.all;
  
  final List<Dua> _all = [
    Dua(
      id: '1',
      title: 'Morning Gratitude',
      preview: 'Allahumma inni as\'aluka min khayri hadha ad-dunya wa\'l-akhirah...',
      tags: ['gratitude', 'morning'],
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      favorite: true,
    ),
    Dua(
      id: '2',
      title: 'Healing Prayer',
      preview: 'Ya Shafi, ya Kaafi, cure me from all ailments and grant me health...',
      tags: ['health', 'healing'],
      createdAt: DateTime.now().subtract(Duration(days: 3)),
      favorite: false,
    ),
    Dua(
      id: '3',
      title: 'Rizq Blessing',
      preview: 'Allahumma inni a\'udhu bika min dhalal ba\'da\'l-hidayah...',
      tags: ['rizq', 'provision'],
      createdAt: DateTime.now().subtract(Duration(days: 5)),
      favorite: true,
    ),
    Dua(
      id: '4',
      title: 'Family Unity',
      preview: 'O Allah, unite our hearts and strengthen the bonds of our family...',
      tags: ['family', 'unity'],
      createdAt: DateTime.now().subtract(Duration(hours: 2)),
      favorite: false,
    ),
    Dua(
      id: '5',
      title: 'Strength & Guidance',
      preview: 'Guide me on the straight path and grant me strength to face trials...',
      tags: ['guidance', 'strength'],
      createdAt: DateTime.now().subtract(Duration(hours: 12)),
      favorite: false,
    ),
    Dua(
      id: '6',
      title: 'Evening Protection',
      preview: 'Allahumma innaka affuwwun tuhibb al-afwa fa\'afu anna...',
      tags: ['protection', 'evening'],
      createdAt: DateTime.now(),
      favorite: false,
    ),
  ];

  String get query => _query;
  Category get category => _category;
  List<Dua> get all => _all;

  Map<Category, int> get counts {
    final personal = _all.where((d) => d.tags.contains('personal')).length;
    final health = _all.where((d) => d.tags.contains('health')).length;
    final newCount = _all.where((d) => d.isNew()).length;
    return {
      Category.all: _all.length,
      Category.personal: personal,
      Category.health: health,
      Category.newOnly: newCount,
    };
  }

  List<Dua> get filtered {
    var result = _all;

    if (query.isNotEmpty) {
      result = result
        .where((d) =>
          d.title.toLowerCase().contains(query.toLowerCase()) ||
          d.preview.toLowerCase().contains(query.toLowerCase()))
        .toList();
    }

    switch (category) {
      case Category.personal:
        result = result.where((d) => d.tags.contains('personal')).toList();
      case Category.health:
        result = result.where((d) => d.tags.contains('health')).toList();
      case Category.newOnly:
        result = result.where((d) => d.isNew()).toList();
      case Category.all:
        break;
    }

    return result;
  }

  Set<String> get allTags {
    final tags = <String>{};
    for (final dua in _all) {
      tags.addAll(dua.tags);
    }
    return tags;
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void setCategory(Category cat) {
    _category = cat;
    notifyListeners();
  }

  void onCreateNew() {
    debugPrint('[MyDuasController] onCreateNew() called');
  }

  void onOpenDua(String id) {
    debugPrint('[MyDuasController] onOpenDua($id) called');
  }

  void onEditDua(String id) {
    debugPrint('[MyDuasController] onEditDua($id) called');
  }

  void deleteById(String id) {
    debugPrint('[MyDuasController] deleteById($id) called');
    _all.removeWhere((d) => d.id == id);
    notifyListeners();
  }
}

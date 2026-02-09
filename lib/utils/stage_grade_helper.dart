class StageGradeHelper {
  static const Map<String, List<String>> stageGrades = {
    'prepatory': ['One', 'Two', 'Three'],
    'secondary': ['One', 'Two', 'Three'],
    'college': ['One', 'Two', 'Three', 'Four', 'Five'],
  };

  static List<String> getGradesForStage(String stage) {
    return stageGrades[stage] ?? [];
  }

  static List<String> getAllStages() {
    return stageGrades.keys.toList();
  }
}

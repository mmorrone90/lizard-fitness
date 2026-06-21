import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lizard_fitness/models/exercise.dart';
import 'package:lizard_fitness/providers/auth_provider.dart';

final exercisesProvider = StreamProvider<List<Exercise>>((ref) {
  return ref.watch(firestoreServiceProvider).watchExercises();
});

final exerciseSearchProvider = StateProvider<String>((ref) => '');
final exerciseMuscleFilterProvider = StateProvider<MuscleGroup?>((ref) => null);
final exerciseEquipmentFilterProvider = StateProvider<EquipmentType?>((ref) => null);
final exerciseDifficultyFilterProvider = StateProvider<DifficultyLevel?>((ref) => null);

final filteredExercisesProvider = Provider<AsyncValue<List<Exercise>>>((ref) {
  final exercises = ref.watch(exercisesProvider);
  final search = ref.watch(exerciseSearchProvider).toLowerCase();
  final muscle = ref.watch(exerciseMuscleFilterProvider);
  final equipment = ref.watch(exerciseEquipmentFilterProvider);
  final difficulty = ref.watch(exerciseDifficultyFilterProvider);

  return exercises.whenData((list) {
    return list.where((e) {
      if (search.isNotEmpty && !e.name.toLowerCase().contains(search)) return false;
      if (muscle != null && e.primaryMuscle != muscle && !e.secondaryMuscles.contains(muscle)) return false;
      if (equipment != null && !e.equipment.contains(equipment)) return false;
      if (difficulty != null && e.difficulty != difficulty) return false;
      return true;
    }).toList();
  });
});

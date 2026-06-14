import 'package:workout/features/profile/domain/user_profile.dart';
import 'package:workout/features/fitness_intelligence/body_goal_engine/body_goal_engine.dart';

class MealSuggestion {
  final String title;
  final String description;
  const MealSuggestion({required this.title, required this.description});
}

class NutritionPlan {
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatsGrams;
  final List<MealSuggestion> meals;
  final String hydrationRecommendation;

  const NutritionPlan({
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatsGrams,
    required this.meals,
    required this.hydrationRecommendation,
  });
}

class NutritionEngine {
  const NutritionEngine();

  NutritionPlan generatePlan({
    required UserProfile profile,
    required BodyGoalMode mode,
  }) {
    final tdee = profile.estimatedTDEE;
    double calories = tdee;
    double protein = profile.weightKg * 1.6;
    double fats = profile.weightKg * 1.0;

    List<MealSuggestion> meals = [];
    switch (mode) {
      case BodyGoalMode.muscleGain:
      case BodyGoalMode.weightGain:
        final surplus = mode == BodyGoalMode.weightGain ? 500.0 : 300.0;
        calories = tdee + surplus;
        protein = profile.weightKg * 2.0;
        fats = profile.weightKg * 1.0;
        meals = const [
          MealSuggestion(
            title: 'Breakfast: Power Oats',
            description: 'Oatmeal cooked in soy or dairy milk, topped with ground chia seeds, chopped walnuts, and a scoop of unflavored plant/whey protein powder.',
          ),
          MealSuggestion(
            title: 'Lunch: Fuel Bowl',
            description: 'Grilled skinless chicken breast or baked extra-firm tofu served over a large bed of brown rice and steamed mixed vegetables (broccoli, carrots, peas).',
          ),
          MealSuggestion(
            title: 'Snack: Energetic Toast',
            description: 'Two slices of whole wheat sourdough toast spread with natural peanut butter, sliced banana, and a sprinkle of hemp hearts.',
          ),
          MealSuggestion(
            title: 'Dinner: Recovery Stew',
            description: 'Lean beef mince or thick red lentil curry with baked sweet potato wedges, sauteed dark kale, and side avocado salad.',
          ),
        ];
        break;

      case BodyGoalMode.fatLoss:
        calories = tdee - 500;
        protein = profile.weightKg * 2.2;
        fats = profile.weightKg * 0.8;
        meals = const [
          MealSuggestion(
            title: 'Breakfast: Protein Omelette',
            description: 'Scrambled eggs or crumbled tofu cooked with fresh baby spinach, sliced white mushrooms, diced onions, and cherry tomatoes.',
          ),
          MealSuggestion(
            title: 'Lunch: Garden Salmon Salad',
            description: 'Pan-seared salmon fillet or steamed tempeh strips tossed over a large raw green salad (lettuce, cucumber, bell peppers) with olive oil and lemon juice.',
          ),
          MealSuggestion(
            title: 'Snack: Creamy Berry Bowl',
            description: 'Plain unsweetened Greek yogurt or coconut yogurt topped with fresh red raspberries, blueberries, and a few raw whole almonds.',
          ),
          MealSuggestion(
            title: 'Dinner: Lean Turkey & Veggies',
            description: 'Grilled turkey breast cutlets or baked chickpea patty served with a side of stir-fried cauliflower rice and roasted asparagus spears.',
          ),
        ];
        break;

      case BodyGoalMode.strength:
      case BodyGoalMode.generalFitness:
        calories = mode == BodyGoalMode.strength ? tdee + 150 : tdee;
        protein = profile.weightKg * 1.8;
        fats = profile.weightKg * 1.0;
        meals = const [
          MealSuggestion(
            title: 'Breakfast: Chia Oatmeal',
            description: 'Rolled oats soaked overnight in almond milk with chia seeds, flax seeds, and fresh blackberries.',
          ),
          MealSuggestion(
            title: 'Lunch: Whole Wheat Wrap',
            description: 'Tuna flakes or chickpea salad mixed with low-fat yogurt, wrapped in a whole-grain tortilla with sliced avocado and shredded baby spinach.',
          ),
          MealSuggestion(
            title: 'Snack: Hummus & Crunch',
            description: 'Traditional hummus dip served with fresh celery sticks, raw carrot sticks, and sliced cucumbers.',
          ),
          MealSuggestion(
            title: 'Dinner: Chicken or Tofu Quinoa Plate',
            description: 'Baked chicken breast cubes or marinated tofu cubes cooked in sesame oil, served with cooked quinoa and stir-fried bell peppers.',
          ),
        ];
        break;
    }

    // Solve for carbs: (calories - protein*4 - fats*9) / 4
    final remainingCalories = calories - (protein * 4.0) - (fats * 9.0);
    final carbs = remainingCalories > 0 ? remainingCalories / 4.0 : 50.0;

    // Hydration calculation: 35ml per kg of weight + 500ml for workout days
    final hydrationVolumeMl = (profile.weightKg * 35.0) + 500.0;
    final hydrationLitres = (hydrationVolumeMl / 1000.0).toStringAsFixed(1);
    final hydration = 'Drink approximately $hydrationLitres Litres ($hydrationVolumeMl mL) of pure water daily to support workout recovery and cell hydration.';

    return NutritionPlan(
      calories: calories,
      proteinGrams: protein,
      carbsGrams: carbs,
      fatsGrams: fats,
      meals: meals,
      hydrationRecommendation: hydration,
    );
  }
}

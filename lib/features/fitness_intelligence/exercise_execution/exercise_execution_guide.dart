class ExecutionInstructions {
  final List<String> steps;
  final List<String> commonMistakes;
  final String breathing;
  final String tempo;
  final List<String> safetyTips;

  const ExecutionInstructions({
    required this.steps,
    required this.commonMistakes,
    required this.breathing,
    required this.tempo,
    required this.safetyTips,
  });
}

class ExerciseExecutionGuide {
  const ExerciseExecutionGuide();

  static ExecutionInstructions getGuide(String exerciseName) {
    final name = exerciseName.toLowerCase();

    if (name.contains('squat')) {
      return const ExecutionInstructions(
        steps: [
          'Stand with feet slightly wider than shoulder-width, toes flared out 15-30 degrees.',
          'Brace your core, look forward, and initiate the movement by bending at your hips and knees.',
          'Lower your hips back and down until your thighs are at least parallel to the floor.',
          'Push through your mid-foot to drive back up to the starting position, keeping knees stable.'
        ],
        commonMistakes: [
          'Knees caving inward (valgus collapse).',
          'Heels lifting off the ground.',
          'Rounding the lower back (butt wink) at the bottom.'
        ],
        breathing: 'Inhale deeply as you descend, hold and brace your core at the bottom, and exhale forcefully as you drive back up.',
        tempo: '3-1-1-0 (3 seconds descent, 1 second pause at parallel, 1 second rise, 0 seconds rest)',
        safetyTips: [
          'Always squat inside a power rack with safety arms adjusted to chest height when squatting heavy.',
          'Stop immediately if you feel sharp pain in your knees or lower back.'
        ],
      );
    } else if (name.contains('bench') || name.contains('chest press')) {
      return const ExecutionInstructions(
        steps: [
          'Lie flat on the bench with your feet planted firmly on the floor.',
          'Grip the barbell slightly wider than shoulder-width, pulling your shoulder blades together.',
          'Unrack the bar and lower it under control to your mid-chest.',
          'Press the bar straight up until your elbows are fully locked, keeping shoulders retracted.'
        ],
        commonMistakes: [
          'Flaring elbows out to 90 degrees (keep them at 45-60 degrees instead).',
          'Bouncing the barbell off your chest.',
          'Lifting your hips/butt off the bench during the press.'
        ],
        breathing: 'Inhale on the eccentric phase (descent), hold briefly, and exhale on the concentric phase (press).',
        tempo: '2-1-1-0 (2 seconds descent, 1 second chest pause, 1 second press)',
        safetyTips: [
          'Use a spotter or safety pins if you are training close to failure.',
          'Do not use a thumbless (suicide) grip; wrap your thumbs fully around the bar.'
        ],
      );
    } else if (name.contains('deadlift')) {
      return const ExecutionInstructions(
        steps: [
          'Stand with feet hip-width apart, the barbell positioned directly over your mid-foot.',
          'Bend at the hips and knees, grabbing the bar with hands just outside your shins.',
          'Flatten your back, depress your shoulder blades, and pull the slack out of the bar.',
          'Drive through your heels, pulling the bar up along your shins, locking out hips at the top.'
        ],
        commonMistakes: [
          'Rounding the lower spine (lumbar flexion) during the pull.',
          'Starting with the bar too far forward from your shins.',
          'Hyperextending the lower back at lockout.'
        ],
        breathing: 'Inhale and brace your core at the bottom, pull while holding breath, and exhale as you lock out.',
        tempo: '2-0-1-0 (2 seconds controlled descent, 0 seconds pause, 1 second pull)',
        safetyTips: [
          'Never yank the bar off the floor; build tension first and push the floor away.',
          'Keep your arms fully extended throughout the movement to protect your biceps.'
        ],
      );
    } else if (name.contains('overhead press') || name.contains('shoulder press') || name.contains('military press')) {
      return const ExecutionInstructions(
        steps: [
          'Rack a barbell at upper-chest height, grip it slightly wider than shoulder-width.',
          'Keep your elbows slightly forward under the bar, squeeze your glutes and core.',
          'Press the bar straight up overhead, pulling your head back slightly to let the bar clear your chin.',
          'Push your head forward through the window at the top as your elbows lock out.'
        ],
        commonMistakes: [
          'Excessive arching of the lower back (lean back).',
          'Flaring elbows completely outward.',
          'Not completing the full range of motion.'
        ],
        breathing: 'Inhale and brace at the chest, press, and exhale at the top lockout.',
        tempo: '2-0-1-0 (2 seconds descent, 1 second press)',
        safetyTips: [
          'Keep your core and glutes locked tight to stabilize your lumbar spine.',
          'Use a weight that allows you to complete the lockout without tilting your neck back.'
        ],
      );
    } else {
      // General movement guide
      return const ExecutionInstructions(
        steps: [
          'Set up in a stable position with a neutral spine and active core bracing.',
          'Focus on squeezing the target muscle group throughout the entire range of motion.',
          'Control the eccentric (lowering) phase of the lift, avoiding sudden drops.',
          'Return to the starting position smoothly without using momentum.'
        ],
        commonMistakes: [
          'Using excessive momentum (swinging or rocking your body).',
          'Partial range of motion (skipping the stretch or contraction).',
          'Losing core engagement mid-movement.'
        ],
        breathing: 'Exhale during the active lifting phase (exertion), inhale during the controlled lowering phase.',
        tempo: '2-0-2-0 (2 seconds concentric squeeze, 2 seconds eccentric release)',
        safetyTips: [
          'Use a controlled pace and prioritize strict form over adding extra weight.',
          'Discontinue the exercise immediately if you feel joint pain or grinding sensations.'
        ],
      );
    }
  }
}

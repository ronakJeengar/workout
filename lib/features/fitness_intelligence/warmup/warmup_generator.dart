class WarmupSet {
  final double percent;
  final int reps;
  const WarmupSet({required this.percent, required this.reps});
}

class WarmupPlan {
  final List<WarmupSet> sets;
  final List<String> mobilitySuggestions;
  final List<String> activationExercises;
  final String restTiming;
  final String injuryPreventionNotes;

  const WarmupPlan({
    required this.sets,
    required this.mobilitySuggestions,
    required this.activationExercises,
    required this.restTiming,
    required this.injuryPreventionNotes,
  });
}

class WarmupGenerator {
  const WarmupGenerator();

  static WarmupPlan generate(String muscleGroup, double workWeight) {
    final m = muscleGroup.toLowerCase();
    
    // Default warm-up set structure (20%, 40%, 60% of work weight)
    final sets = [
      WarmupSet(percent: 20.0, reps: 10),
      WarmupSet(percent: 40.0, reps: 6),
      WarmupSet(percent: 60.0, reps: 3),
    ];

    List<String> mobility = [];
    List<String> activation = [];
    String rest = '60-90 seconds rest between warm-up sets.';
    String injuryNotes = '';

    if (m.contains('chest') || m.contains('shoulder') || m.contains('tricep') || m.contains('arm')) {
      mobility = [
        'Dynamic arm swings (15 reps)',
        'Shoulder dislocates with light band (10 reps)',
        'Scapular wall slides (10 reps)',
      ];
      activation = [
        'Band pull-aparts (15 reps)',
        'Light knee push-ups (8 reps)',
      ];
      injuryNotes = 'Scapular retraction: Retract and depress your shoulder blades during chest and shoulder exercises. Do not flare elbows past 75 degrees.';
    } else if (m.contains('back') || m.contains('bicep')) {
      mobility = [
        'Cat-cow stretch (10 repetitions)',
        'Thoracic spine rotations (8 reps/side)',
        'Passive dead hang from bar (30 seconds)',
      ];
      activation = [
        'Scapular pull-ups (10 reps)',
        'Face pulls with light band (15 reps)',
      ];
      injuryNotes = 'Lat activation: Initiate pulls with your elbows, not your hands, to focus work on the latissimus dorsi. Keep a neutral lower back.';
    } else if (m.contains('leg') || m.contains('glute') || m.contains('quad') || m.contains('hamstring') || m.contains('calf')) {
      mobility = [
        'Deep goblet squat hold (30 seconds)',
        'Standing leg swings (12 reps/side)',
        'Ankle dorsiflexion stretch (10 reps/side)',
      ];
      activation = [
        'Bodyweight glute bridges (15 reps)',
        'Monster walks with mini-band (15 steps/side)',
        'Bodyweight squats (10 reps)',
      ];
      injuryNotes = 'Knee alignment: Ensure knees track outwards in line with your middle toes. Maintain a flat back and avoid excessive lumbar flexion (butt wink).';
    } else {
      // General full body warm-up
      mobility = [
        'Hip openers / world\'s greatest stretch (5 reps/side)',
        'Dynamic chest openers (10 reps)',
        'Gentle neck rolls (5 reps/side)',
      ];
      activation = [
        'Jumping jacks (30 seconds)',
        'Plank hold (30 seconds)',
      ];
      injuryNotes = 'Bracing: Maintain proper intra-abdominal pressure (core bracing) for all heavy movements to protect the spine.';
    }

    return WarmupPlan(
      sets: sets,
      mobilitySuggestions: mobility,
      activationExercises: activation,
      restTiming: rest,
      injuryPreventionNotes: injuryNotes,
    );
  }
}

import os, re
import glob

replacements = {
    "Text('TRAINING CALENDAR'": "Text(AppLocalizations.of(context)!.trainingCalendar",
    "Text('NEW GOAL'": "Text(AppLocalizations.of(context)!.newGoal",
    "Text('GOAL TYPE'": "Text(AppLocalizations.of(context)!.goalType",
    "Text('MOTIVATION'": "Text(AppLocalizations.of(context)!.motivation",
    "Text('SET GOAL'": "Text(AppLocalizations.of(context)!.setGoal",
    "Text('MY PROFILE'": "Text(AppLocalizations.of(context)!.myProfile",
    "Text('CREATE PROGRAM'": "Text(AppLocalizations.of(context)!.createProgram",
    "Text('PROGRAMS'": "Text(AppLocalizations.of(context)!.trainingPrograms",
    "Text('DUPLICATE'": "Text(AppLocalizations.of(context)!.duplicate",
    "Text('DELETE'": "Text(AppLocalizations.of(context)!.delete",
    "Text('NEW PROGRAM'": "Text(AppLocalizations.of(context)!.newProgram",
    "Text('DELETE PROGRAM?'": "Text(AppLocalizations.of(context)!.deleteProgramTitle",
    "Text('CANCEL'": "Text(AppLocalizations.of(context)!.cancel",
    "Text('RENAME PROGRAM'": "Text(AppLocalizations.of(context)!.renameProgram",
    "Text('SAVE'": "Text(AppLocalizations.of(context)!.save",
    "Text('CREATE A WORKOUT FIRST!'": "Text(AppLocalizations.of(context)!.createWorkoutFirst",
    "Text('CHOOSE WORKOUT'": "Text(AppLocalizations.of(context)!.chooseWorkout",
    "Text('PROGRESS'": "Text(AppLocalizations.of(context)!.progress",
    "Text('LIFETIME VOLUME'": "Text(AppLocalizations.of(context)!.lifetimeVolume",
    "Text('MONTHLY SCORE'": "Text(AppLocalizations.of(context)!.monthlyScore",
    "Text('NO DATA'": "Text(AppLocalizations.of(context)!.noData",
    "Text('Settings'": "Text(AppLocalizations.of(context)!.settings",
    "Text('Default Rest Timer'": "Text(AppLocalizations.of(context)!.defaultRestTimer",
    "Text('Add Exercise'": "Text(AppLocalizations.of(context)!.addExercise",
    "Text('Create Workout'": "Text(AppLocalizations.of(context)!.createWorkout",
    "Text('Save Workout'": "Text(AppLocalizations.of(context)!.saveWorkout",
    "Text('Workout History'": "Text(AppLocalizations.of(context)!.workoutHistory",
    "Text('DASHBOARD'": "Text(AppLocalizations.of(context)!.dashboard",
    "Text('MANAGE PROGRAMS'": "Text(AppLocalizations.of(context)!.managePrograms",
    "Text('GOALS & ACHIEVEMENTS'": "Text(AppLocalizations.of(context)!.goalsAchievements",
    "Text('STAY ON TRACK'": "Text(AppLocalizations.of(context)!.stayOnTrack",
    "Text('NEW WORKOUT'": "Text(AppLocalizations.of(context)!.newWorkout",
    "Text('No active session.'": "Text(AppLocalizations.of(context)!.noActiveSession",
    "Text('REST FINISHED!'": "Text(AppLocalizations.of(context)!.restFinished",
    "Text('Workout Summary'": "Text(AppLocalizations.of(context)!.workoutSummary",
}

for filepath in glob.glob('lib/features/**/*.dart', recursive=True):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    for old, new in replacements.items():
        content = content.replace(old, new)
        
    if content != original_content:
        # Check if import exists
        if 'package:flutter_gen/gen_l10n/app_localizations.dart' not in content:
            content = "import 'package:flutter_gen/gen_l10n/app_localizations.dart';\n" + content
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'Updated {filepath}')

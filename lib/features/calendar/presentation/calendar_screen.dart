import 'package:workout/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../shared/constants/app_sizes.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_loading.dart';
import '../providers/calendar_providers.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final activityAsync = ref.watch(calendarActivityProvider);
    final scheduleAsync = ref.watch(calendarProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.trainingCalendar, 
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
          )
        ),
      ),
      body: Column(
        children: [
          _buildMonthHeader(),
          Expanded(
            child: activityAsync.when(
              data: (activity) => scheduleAsync.when(
                data: (schedule) => _buildCalendarGrid(activity, schedule),
                loading: () => const AppLoading(),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
              loading: () => const AppLoading(),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    final months = ['JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE', 'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'];
    return Padding(
      padding: const EdgeInsets.all(AppSizes.m),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1)),
            icon: const Icon(Icons.chevron_left),
          ),
          Text('${months[_focusedDay.month - 1]} ${_focusedDay.year}', 
            style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)
          ),
          IconButton(
            onPressed: () => setState(() => _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1)),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(Map<DateTime, bool> activity, List<dynamic> schedule) {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final leadingDays = firstDayOfMonth.weekday - 1;

    return GridView.builder(
      padding: const EdgeInsets.all(AppSizes.m),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: daysInMonth + leadingDays,
      itemBuilder: (context, index) {
        if (index < leadingDays) return const SizedBox.shrink();

        final day = index - leadingDays + 1;
        final date = DateTime(_focusedDay.year, _focusedDay.month, day);
        final hasActivity = activity.containsKey(DateTime(date.year, date.month, date.day));
        final scheduled = schedule.any((s) => DateTime(s.date.year, s.date.month, s.date.day).isAtSameMomentAs(date));
        final isToday = DateTime(date.year, date.month, date.day).isAtSameMomentAs(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

        return _buildDayCell(day, hasActivity, scheduled, isToday);
      },
    );
  }

  Widget _buildDayCell(int day, bool hasActivity, bool scheduled, bool isToday) {
    Color? bgColor;
    if (hasActivity) {
      bgColor = AppTheme.primaryLime;
    } else if (scheduled) {
      bgColor = Colors.white10;
    }

    return AppCard(
      padding: EdgeInsets.zero,
      showBorder: isToday,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text('$day', 
            style: TextStyle(
              fontWeight: FontWeight.w900, 
              color: hasActivity ? Colors.black : (scheduled ? Colors.white : Colors.white24)
            )
          ),
        ),
      ),
    );
  }
}

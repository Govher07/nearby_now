import 'package:flutter/material.dart';

import '../core/data/current_user.dart';
import '../core/models/event.dart';
import '../core/services/event_service.dart';
import 'create_event_screen.dart';
import 'event_details_screen.dart';
import 'my_events_screen.dart';

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key});

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  late Future<List<Event>> eventsFuture;
  late Future<Map<String, int>> analyticsFuture;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  void loadDashboard() {
    final user = currentUser;

    if (user == null) {
      eventsFuture = Future.value([]);
      analyticsFuture = Future.value({
        'total_events': 0,
        'total_views': 0,
        'total_saves': 0,
      });
      return;
    }

    eventsFuture = EventService.fetchMyEvents(user.id);
    analyticsFuture = EventService.fetchBusinessAnalytics(user.id);
  }

  void refreshDashboard() {
    setState(() {
      loadDashboard();
    });
  }

  void openCreateEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEventScreen(
          onEventPosted: () {
            refreshDashboard();
          },
        ),
      ),
    );
  }

  void openMyEvents() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyEventsScreen(),
      ),
    );
  }

  void openEventDetails(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(event: event),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWebLayout = MediaQuery.sizeOf(context).width >= 900;

    if (currentUser == null) {
      return buildLoggedOutView();
    }

    return Scaffold(
      appBar: isWebLayout
          ? null
          : AppBar(
              title: const Text('Business Dashboard'),
              actions: [
                IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh),
                  onPressed: refreshDashboard,
                ),
              ],
            ),
      body: SafeArea(
        child: isWebLayout ? buildWebBody() : buildMobileBody(),
      ),
    );
  }

  Widget buildLoggedOutView() {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Please sign in as a business owner to manage your events.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  Widget buildMobileBody() {
    return RefreshIndicator(
      onRefresh: () async {
        refreshDashboard();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildMobileHeader(),
            const SizedBox(height: 18),
            buildAnalyticsSection(isWebLayout: false),
            const SizedBox(height: 18),
            buildMobileQuickActions(),
            const SizedBox(height: 24),
            buildRecentEventsSection(isWebLayout: false),
          ],
        ),
      ),
    );
  }

  Widget buildWebBody() {
    return Column(
      children: [
        buildWebHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 28, 104, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildAnalyticsSection(isWebLayout: true),
                const SizedBox(height: 28),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: buildRecentEventsSection(isWebLayout: true),
                    ),
                    const SizedBox(width: 24),
                    SizedBox(
                      width: 320,
                      child: buildWebSidePanel(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMobileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Business Dashboard',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Welcome back, ${currentUser?.name ?? 'Business Owner'}',
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget buildWebHeader() {
    return Container(
      height: 88,
      padding: const EdgeInsets.fromLTRB(32, 0, 104, 0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.30),
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.storefront_outlined,
            size: 32,
          ),
          const SizedBox(width: 14),
          const Text(
            'Business Dashboard',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 18),
          Text(
            'Manage your events and performance',
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.70),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: openCreateEvent,
            icon: const Icon(Icons.add),
            label: const Text('Create Event'),
          ),
        ],
      ),
    );
  }

  Widget buildAnalyticsSection({
    required bool isWebLayout,
  }) {
    return FutureBuilder<Map<String, int>>(
      future: analyticsFuture,
      builder: (context, snapshot) {
        final Map<String, int> analytics = snapshot.data ??
            {
              'total_events': 0,
              'total_views': 0,
              'total_saves': 0,
            };

        final bool isLoading =
            snapshot.connectionState == ConnectionState.waiting;

        final Widget totalEventsCard = buildStatCard(
          icon: Icons.event_available_outlined,
          title: 'Total Events',
          value: isLoading ? '...' : '${analytics['total_events'] ?? 0}',
          subtitle: 'Events you created',
        );

        final Widget viewsCard = buildStatCard(
          icon: Icons.visibility_outlined,
          title: 'Views',
          value: isLoading ? '...' : '${analytics['total_views'] ?? 0}',
          subtitle: 'Total event views',
        );

        final Widget savesCard = buildStatCard(
          icon: Icons.bookmark_border,
          title: 'Saves',
          value: isLoading ? '...' : '${analytics['total_saves'] ?? 0}',
          subtitle: 'Total event saves',
        );

        if (isWebLayout) {
          return Row(
            children: [
              Expanded(child: totalEventsCard),
              const SizedBox(width: 18),
              Expanded(child: viewsCard),
              const SizedBox(width: 18),
              Expanded(child: savesCard),
            ],
          );
        }

        return Column(
          children: [
            totalEventsCard,
            const SizedBox(height: 12),
            viewsCard,
            const SizedBox(height: 12),
            savesCard,
          ],
        );
      },
    );
  }

  Widget buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Card(
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMobileQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: openCreateEvent,
                icon: const Icon(Icons.add),
                label: const Text('Create New Event'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: openMyEvents,
                icon: const Icon(Icons.event_note_outlined),
                label: const Text('View My Events'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWebSidePanel() {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: openCreateEvent,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Event'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: openMyEvents,
                    icon: const Icon(Icons.event_note_outlined),
                    label: const Text('My Events'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Business Tips',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                buildTipRow(
                  icon: Icons.image_outlined,
                  text: 'Use a clear event image.',
                ),
                buildTipRow(
                  icon: Icons.place_outlined,
                  text: 'Add a complete location.',
                ),
                buildTipRow(
                  icon: Icons.schedule_outlined,
                  text: 'Keep date and time accurate.',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTipRow({
    required IconData icon,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  Widget buildRecentEventsSection({
    required bool isWebLayout,
  }) {
    return FutureBuilder<List<Event>>(
      future: eventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Could not load your events.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final List<Event> events = snapshot.data ?? [];

        if (events.isEmpty) {
          return buildEmptyEventsCard();
        }

        if (isWebLayout) {
          return buildWebEventsTable(events);
        }

        return buildMobileEventsList(events);
      },
    );
  }

  Widget buildEmptyEventsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const Icon(
              Icons.event_busy_outlined,
              size: 52,
            ),
            const SizedBox(height: 14),
            const Text(
              'No events yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create your first event so people nearby can discover it.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: openCreateEvent,
              icon: const Icon(Icons.add),
              label: const Text('Create Event'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMobileEventsList(List<Event> events) {
    final List<Event> recentEvents = events.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Events',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...recentEvents.map((event) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.event_outlined),
              title: Text(
                event.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text('${event.date} • ${event.time}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                openEventDetails(event);
              },
            ),
          );
        }),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: openMyEvents,
            child: const Text('View All Events'),
          ),
        ),
      ],
    );
  }

  Widget buildWebEventsTable(List<Event> events) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTableHeader(events.length),
            const Divider(height: 1),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 48,
                dataRowMinHeight: 58,
                dataRowMaxHeight: 70,
                columns: const [
                  DataColumn(
                    label: Text('Event'),
                  ),
                  DataColumn(
                    label: Text('Category'),
                  ),
                  DataColumn(
                    label: Text('Date'),
                  ),
                  DataColumn(
                    label: Text('Time'),
                  ),
                  DataColumn(
                    label: Text('Location'),
                  ),
                  DataColumn(
                    label: Text('Action'),
                  ),
                ],
                rows: events.map((event) {
                  return DataRow(
                    cells: [
                      DataCell(
                        SizedBox(
                          width: 260,
                          child: Text(
                            event.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        Chip(
                          label: Text(event.category),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      DataCell(Text(event.date)),
                      DataCell(Text(event.time)),
                      DataCell(
                        SizedBox(
                          width: 220,
                          child: Text(
                            event.fullAddress,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        TextButton(
                          onPressed: () {
                            openEventDetails(event);
                          },
                          child: const Text('Open'),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTableHeader(int eventCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Recent Events',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            '$eventCount total',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.65),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: openMyEvents,
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }
}
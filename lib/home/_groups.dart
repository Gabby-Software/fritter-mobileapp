import 'package:flutter/material.dart';
import 'package:fritter/generated/l10n.dart';
import 'package:fritter/group/group_model.dart';
import 'package:fritter/home/home_screen.dart';
import 'package:fritter/subscriptions/_groups.dart';
import 'package:provider/provider.dart';

class GroupsScreen extends StatelessWidget with AppBarMixin {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  AppBar getAppBar(BuildContext context) {
    return AppBar(
      title: Text(L10n.current.groups),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.sort),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'name',
              child: Text(L10n.of(context).name),
            ),
            PopupMenuItem(
              value: 'created_at',
              child: Text(L10n.of(context).date_created),
            ),
          ],
          onSelected: (value) => context.read<GroupsModel>().changeOrderSubscriptionGroupsBy(value),
        ),
        IconButton(
          icon: const Icon(Icons.sort_by_alpha),
          onPressed: () => context.read<GroupsModel>().toggleOrderSubscriptionGroupsAscending(),
        ),
        ...createCommonAppBarActions(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SubscriptionGroups();
  }
}

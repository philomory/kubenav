import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:kubenav/repositories/app_repository.dart';
import 'package:kubenav/repositories/sponsor_repository.dart';
import 'package:kubenav/repositories/theme_repository.dart';
import 'package:kubenav/utils/showmodal.dart';
import 'package:kubenav/widgets/settings/settings/sponsor/settings_sponsor_subscribe.dart';
import 'package:kubenav/widgets/shared/app_actions_widget.dart';

/// The [SettingsSponsorActions] widget shows an action menu with all available
/// sponsoring options (products). When the user clicks on one of the products
/// the [SettingsSponsorSubscribe] will be opened like it is done in the
/// settings screen.
class SettingsSponsorActions extends StatelessWidget {
  const SettingsSponsorActions({
    Key? key,
    required this.showDismiss,
  }) : super(key: key);

  final bool showDismiss;

  @override
  Widget build(BuildContext context) {
    AppRepository appRepository = Provider.of<AppRepository>(
      context,
      listen: true,
    );
    SponsorRepository sponsorRepository = Provider.of<SponsorRepository>(
      context,
      listen: true,
    );

    return AppActionsWidget(
      actions: showDismiss
          ? [
              ...sponsorRepository.products
                  .map(
                    (e) => AppActionsWidgetAction(
                      title: e.title,
                      color: theme(context).colorPrimary,
                      onTap: () {
                        Navigator.pop(context);
                        showModal(
                          context,
                          SettingsSponsorSubscribe(product: e),
                        );
                      },
                    ),
                  )
                  .toList(),
              AppActionsWidgetAction(
                title: 'Not Now',
                color: theme(context).colorDanger,
                onTap: () {
                  // For testing we can set the reminder to 1 minute, by default
                  // it is set to 7 days.
                  // final remindmeafter =
                  //     DateTime.now().millisecondsSinceEpoch + 60000;
                  final remindmeafter =
                      DateTime.now().millisecondsSinceEpoch + 604800000;
                  appRepository.setSponsorReminder(remindmeafter);
                  Navigator.pop(context);
                },
              ),
            ]
          : sponsorRepository.products
              .map(
                (e) => AppActionsWidgetAction(
                  title: e.title,
                  color: theme(context).colorPrimary,
                  onTap: () {
                    Navigator.pop(context);
                    showModal(
                      context,
                      SettingsSponsorSubscribe(product: e),
                    );
                  },
                ),
              )
              .toList(),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:kubenav/models/kubernetes/io_k8s_api_autoscaling_v2_horizontal_pod_autoscaler.dart';
import 'package:kubenav/models/resource_model.dart';
import 'package:kubenav/pages/resources_list/widgets/list_item_widget.dart';
import 'package:kubenav/utils/resources/general.dart';

class HorizontalPodAutoscalerListItemWidget extends StatelessWidget
    implements IListItemWidget {
  const HorizontalPodAutoscalerListItemWidget({
    Key? key,
    required this.title,
    required this.resource,
    required this.path,
    required this.scope,
    required this.item,
  }) : super(key: key);

  @override
  final String? title;
  @override
  final String? resource;
  @override
  final String? path;
  @override
  final ResourceScope? scope;
  @override
  final dynamic item;

  Status getStatus(
    int replicas,
    int minPods,
    int maxPods,
  ) {
    if (replicas < minPods || replicas > maxPods) {
      return Status.danger;
    }

    return Status.success;
  }

  @override
  Widget build(BuildContext context) {
    final hpa = IoK8sApiAutoscalingV2HorizontalPodAutoscaler.fromJson(item);
    final age = getAge(hpa?.metadata?.creationTimestamp);
    final reference =
        '${hpa?.spec?.scaleTargetRef.kind ?? '-'}/${hpa?.spec?.scaleTargetRef.name ?? '-'}';
    final replicas = hpa?.status?.currentReplicas ?? 0;
    final minPods = hpa?.spec?.minReplicas ?? 0;
    final maxPods = hpa?.spec?.maxReplicas ?? 0;

    return ListItemWidget(
      title: title,
      resource: resource,
      path: path,
      scope: scope,
      name: hpa?.metadata?.name ?? '',
      namespace: hpa?.metadata?.namespace,
      info: [
        'Namespace: ${hpa?.metadata?.namespace ?? '-'}',
        'Reference: $reference',
        'Replicas: $replicas',
        'Min. Pods: $minPods',
        'Max. Pods: $maxPods',
        'Age: $age',
      ],
      status: getStatus(
        replicas,
        minPods,
        maxPods,
      ),
    );
  }
}
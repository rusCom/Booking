import 'package:booking/constants/style.dart';
import 'package:booking/ui/utils/core.dart';
import 'package:flutter/material.dart' hide ReorderableList;
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';

import '../../../models/main_application.dart';
import '../../../models/route_point.dart';
import '../../../services/app_blocs.dart';
import '../../route_point/route_point_screen.dart';

class NewOrderRoutePointsReorderDialog extends StatefulWidget {
  const NewOrderRoutePointsReorderDialog({super.key});

  @override
  State<NewOrderRoutePointsReorderDialog> createState() => _NewOrderRoutePointsReorderDialogState();
}

class _NewOrderRoutePointsReorderDialogState extends State<NewOrderRoutePointsReorderDialog> {
  int _indexOfKey(Key key) {
    return MainApplication().curOrder.routePoints.indexWhere((RoutePoint d) => d.key == key);
  }

  bool _reorderCallback(Key item, Key newPosition) {
    return MainApplication().curOrder.reorderRoutePoints(item, newPosition);
  }

  void _reorderDone(Key item) {
    final draggedItem = MainApplication().curOrder.routePoints[_indexOfKey(item)];
    // debugPrint("Reordering finished for ${draggedItem.name}}");
    DebugPrint().log("NewOrderRoutePointsReorderDialog", "reorderDone", draggedItem.name);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text("Корректировка маршрута", style: TextStyle(color: Colors.black)),
          backgroundColor: mainColor,
        ),
        body: ReorderableList(
          onReorder: _reorderCallback,
          onReorderDone: _reorderDone,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                sliver: StreamBuilder<List<RoutePoint>>(
                    stream: AppBlocs().orderRoutePointsStream,
                    builder: (context, snapshot) {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            if (index == MainApplication().curOrder.routePoints.length) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Expanded(
                                    child: TextButton.icon(
                                      icon: const Icon(Icons.add, color: Colors.black),
                                      label: const Text("Добавить", style: TextStyle(color: Colors.black)),
                                      onPressed: () async {
                                        RoutePoint? routePoint = await Navigator.push<RoutePoint>(
                                            context, MaterialPageRoute(builder: (context) => const RoutePointScreen()));
                                        if (routePoint != null) {
                                          MainApplication().curOrder.addRoutePoint(routePoint);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 40, child: VerticalDivider(color: mainColor)),
                                  Expanded(
                                    child: TextButton.icon(
                                      icon: const Icon(Icons.cached, color: Colors.black),
                                      label: const Text("Обратно", style: TextStyle(color: Colors.black)),
                                      onPressed: MainApplication().curOrder.routePoints.first.placeId ==
                                              MainApplication().curOrder.routePoints.last.placeId
                                          ? null
                                          : () =>
                                              MainApplication().curOrder.addRoutePoint(RoutePoint.copy(MainApplication().curOrder.routePoints.first)),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Item(
                              data: MainApplication().curOrder.routePoints[index],
                              // first and last attributes affect border drawn during dragging
                              isFirst: index == 0,
                              isLast: index == MainApplication().curOrder.routePoints.length - 1,
                            );
                          },
                          childCount: MainApplication().curOrder.routePoints.length + 1,
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Item extends StatelessWidget {
  const Item({
    super.key,
    required this.data,
    required this.isFirst,
    required this.isLast,
  });

  final RoutePoint data;
  final bool isFirst;
  final bool isLast;

  Widget _buildChild(BuildContext context, ReorderableItemState state) {
    BoxDecoration decoration;

    if (state == ReorderableItemState.dragProxy || state == ReorderableItemState.dragProxyFinished) {
      // slightly transparent background white dragging (just like on iOS)
      decoration = const BoxDecoration(color: Color(0xD0FFFFFF));
    } else {
      bool placeholder = state == ReorderableItemState.placeholder;
      decoration = BoxDecoration(
          border: Border(
              top: isFirst && !placeholder
                  ? Divider.createBorderSide(context) //
                  : BorderSide.none,
              bottom: isLast && placeholder
                  ? BorderSide.none //
                  : Divider.createBorderSide(context)),
          color: placeholder ? null : Colors.white);
    }

    // For iOS dragging mdoe, there will be drag handle on the right that triggers
    // reordering; For android mode it will be just an empty container
    Widget dragHandle = ReorderableListener(
      child: Container(
        padding: const EdgeInsets.only(right: 18.0, left: 18.0),
        color: const Color(0x08000000),
        child: const Center(
          child: Icon(Icons.import_export, color: Color(0xFF888888)),
        ),
      ),
    );

    Widget content = Container(
      decoration: decoration,
      child: SafeArea(
          top: false,
          bottom: false,
          child: Opacity(
            // hide content for placeholder
            opacity: state == ReorderableItemState.placeholder ? 0.0 : 1.0,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  IconButton(
                      icon: const Icon(Icons.delete_forever),
                      onPressed: () {
                        MainApplication().curOrder.deleteRoutePoint(data.key);
                      }),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14.0,
                        horizontal: 14.0,
                      ),
                      child: Text(
                        data.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  // Triggers the reordering
                  dragHandle,
                ],
              ),
            ),
          )),
    );

    return content;
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableItem(
      key: data.key, //
      childBuilder: _buildChild,
    );
  }
}

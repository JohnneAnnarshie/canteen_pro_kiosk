import 'dart:math';

import 'package:canteen_pro/models/canteen_setting.dart';
import 'package:canteen_pro/models/order.dart';
import 'package:canteen_pro/utils/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../../models/active_meal.dart';

class OrderMealCard extends StatefulWidget {
  final ActiveMeal meal;
  final int quantity;
  final Function() onQuantityIncreased;
  final Function() onQuantityReduced;
  final String availableDate;
  final bool hasOrdered;
  final bool canOrderMultiple;
  final Function() onAddToCart;
  final Function() onSaveOrder;
  final Function() onPrintOrder;
  final bool isAddedToCart;
  final String mealType;
  final CanteenSetting? selectedLocation;
  final Function(CanteenSetting) onSelectLocation;
  final List<CanteenSetting> serveLocations;
  final DineType selectedDineType;
  final ValueChanged<DineType?> onSelectDineType;
  final Order? order;

  const OrderMealCard({
    super.key,
    required this.meal,
    required this.quantity,
    required this.onQuantityIncreased,
    required this.onQuantityReduced,
    required this.availableDate,
    required this.hasOrdered,
    required this.canOrderMultiple,
    required this.onAddToCart,
    required this.onSaveOrder,
    required this.onPrintOrder,
    this.isAddedToCart = false,
    required this.mealType,
    this.selectedLocation,
    required this.onSelectLocation,
    required this.serveLocations,
    required this.selectedDineType,
    required this.onSelectDineType,
    this.order,
  });

  @override
  State<OrderMealCard> createState() => _OrderMealCardState();
}

class _OrderMealCardState extends State<OrderMealCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isCompact = ResponsiveLayout.getScreenWidth(context) < 700;
    return GestureDetector(
      onTap: () {
        if (widget.canOrderMultiple && !widget.hasOrdered) {
          widget.onAddToCart();
        } else if (widget.canOrderMultiple && widget.hasOrdered) {
          widget.onSaveOrder();
        } else if (!widget.canOrderMultiple && !widget.hasOrdered) {
          widget.onSaveOrder();
        } else if (!widget.canOrderMultiple && widget.hasOrdered) {
          widget.onPrintOrder();
        }
      },
      child: Card(
        elevation: 2,
        clipBehavior: Clip.hardEdge,
        child: Container(
          margin: const EdgeInsets.all(8.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color:
                  widget.hasOrdered || widget.isAddedToCart
                      ? colorScheme.tertiary
                      : AppTheme.cardBorderDeep,
              width:
                  widget.hasOrdered
                      ? 2
                      : widget.isAddedToCart
                      ? 6
                      : 1.5,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.hasOrdered) ...[
                Positioned(
                  right: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: colorScheme.tertiary.withAlpha(120),
                        size: 40,
                      ),
                      Text(
                        "Ordered",
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.tertiary.withAlpha(160),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (widget.isAddedToCart) ...[
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiary.withAlpha(190),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Selected",
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        children: [
                          widget.isAddedToCart ? Icon(
                            Icons.check_circle,
                            color: colorScheme.tertiary.withAlpha(190),
                            size: 60,
                          ) :
                          Image.asset(
                            'assets/images/breakfast4.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 10),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth:
                                  isCompact
                                      ? 350
                                      : ResponsiveLayout.getMaxContentWidth(
                                            context,
                                          ) *
                                          0.6,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  widget.meal.name,
                                  softWrap: true,
                                  style: textTheme.titleMedium?.copyWith(
                                    color:
                                        widget.hasOrdered
                                            ? colorScheme.tertiary
                                            : colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                if (widget.meal.description != null && widget.meal.description!.isNotEmpty) ...[
                                Text(
                                  widget.meal.description ?? "",
                                  softWrap: true,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                ],
                                Text(
                                  "Serve date: ${widget.availableDate}",
                                  softWrap: true,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.primary.withAlpha(120),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                widget.hasOrdered ? SizedBox(height: 2) : SizedBox.shrink(),
                                Wrap(
                                  alignment: WrapAlignment.start,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    if (widget.hasOrdered) ...[
                                      Icon(
                                        Icons.print,
                                        color: colorScheme.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        "Tap to print ticket",
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurface,
                                        ),
                                      )
                                    ] else ...[
                                    Text(
                                      "Select dine type:",
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    ...DineType.values.map(
                                      (dineType) => RadioGroup<DineType>(
                                        groupValue: widget.selectedDineType,
                                        onChanged: widget.onSelectDineType,
                                        child: Wrap(
                                          alignment: WrapAlignment.start,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Radio(
                                              value: dineType,
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                            InkWell(
                                              onTap:
                                                  () => widget.onSelectDineType(
                                                    dineType,
                                                  ),
                                              child: Text(dineType.label),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),]
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (widget.canOrderMultiple && !widget.hasOrdered) ...[
                    const SizedBox(width: 10),
                    _buildQuantityControlButtons(
                      quantity: widget.quantity,
                      onQuantityIncreased: () {
                        widget.onQuantityIncreased();
                      },
                      onQuantityReduced: () {
                        widget.onQuantityReduced();
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityControlButtons({
    required int quantity,
    required Function() onQuantityIncreased,
    required Function() onQuantityReduced,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        _buildControlButton(
          icon: LucideIcons.plus,
          onPressed: () => onQuantityIncreased(),
          iconColor: colorScheme.primary,
        ),
        Text(
          quantity.toString(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        _buildControlButton(
          icon: LucideIcons.minus,
          onPressed: () => onQuantityReduced(),
          iconColor: colorScheme.primary,
        ),
      ],
    );
  }
}

Widget _buildControlButton({
  required IconData icon,
  required VoidCallback onPressed,
  Color iconColor = Colors.black,
  double iconSize = 30.0,
  double buttonSize = 40.0,
  bool enabled = true
}) {
  return IconButton(
    icon: Icon(icon, color: enabled ? iconColor : Colors.grey),
    iconSize: iconSize,
    onPressed: enabled ? onPressed : null,
    style: IconButton.styleFrom(
      backgroundColor: Colors.white,
      shape: CircleBorder(
        side: BorderSide(color: AppTheme.cardBorderDeep, width: 1.5),
      ),
    ),
  );
}

class OrderMealTimeIndicator extends StatefulWidget {
  final List<OrderMealTimeGroup> groups;

  const OrderMealTimeIndicator({super.key, required this.groups});

  @override
  State<OrderMealTimeIndicator> createState() => _OrderMealTimeIndicatorState();
}

class _OrderMealTimeIndicatorState extends State<OrderMealTimeIndicator> {
  final Set<String> _expandedGroups = {};

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return ExpansionPanelList(
      elevation: 0,
      expandIconColor: colorScheme.primary,
      dividerColor: Colors.transparent,
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          final title = widget.groups[index].title;
          if (isExpanded) {
            _expandedGroups.add(title);
          } else {
            _expandedGroups.remove(title);
          }
        });
      },
      children: [
        ...widget.groups.map(
          (group) => ExpansionPanel(
            isExpanded: _expandedGroups.contains(group.title),
            backgroundColor: Colors.transparent,
            canTapOnHeader: true,
            headerBuilder: (BuildContext context, bool isExpanded) {
              return Container(
                width: double.infinity,
                height: 40,
                margin:
                    isExpanded
                        ? EdgeInsets.zero
                        : const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: getColorByMealTime(group.title),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(26),
                    bottomRight: Radius.circular(26),
                  ),
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          isExpanded ? Icons.check_circle: Icons.circle_outlined,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          group.title,
                          textAlign: TextAlign.start,
                          style: textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Start Time: ${group.orderStartTime}",
                          textAlign: TextAlign.start,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "End Time: ${group.orderEndTime}",
                          textAlign: TextAlign.start,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    isExpanded
                        ? SizedBox.shrink()
                        : Text(
                          "Tap to expand",
                          textAlign: TextAlign.start,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ],
                ),
              );
            },
            body: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
              child: Column(children: [...group.meals]),
            ),
          ),
        ),
      ],
    );
    //   Padding(
    //   padding: const EdgeInsets.only(right: 10.0),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.stretch,
    //     children: [
    //       Container(
    //         width: double.infinity,
    //         height: 40,
    //         padding: const EdgeInsets.symmetric(horizontal: 16),
    //         decoration: BoxDecoration(
    //             color: getColorByMealTime(widget.mealTime),
    //             borderRadius: BorderRadius.only(
    //               topRight: Radius.circular(16),
    //               bottomRight: Radius.circular(16),
    //             ),
    //           boxShadow: [
    //             BoxShadow(
    //               color: Colors.black.withOpacity(0.5),
    //               spreadRadius: 4,
    //               blurRadius: 5,
    //               offset: Offset(0, 3),
    //             )
    //           ]
    //         ),
    //         alignment: Alignment.centerLeft,
    //         child: Text(widget.mealTime,
    //             textAlign: TextAlign.start,
    //             style: textTheme.titleLarge?.copyWith(
    //               color: Colors.white,
    //               fontWeight: FontWeight.bold,
    //             )),
    //       ),
    //       AnimatedContainer(
    //         duration: const Duration(milliseconds: 300),
    //         width: 20,
    //         padding: const EdgeInsets.only(bottom: 10, left: 10, top: 10),
    //         decoration: BoxDecoration(
    //             borderRadius: BorderRadius.only(
    //               bottomLeft: Radius.elliptical(0,110),
    //             ),
    //           border: Border(
    //             left: BorderSide(
    //               color: getColorByMealTime(widget.mealTime),
    //               width: 12,
    //             )
    //           )
    //         ),
    //         child:
    //         Expanded(
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.start,
    //             children: [
    //               ...widget.meals.animate(
    //                 effects: [
    //                   SlideEffect(
    //                     delay: const Duration(milliseconds: 100),
    //                     duration: const Duration(milliseconds: 300),
    //                     curve: Curves.easeInOut,
    //                   )
    //                 ],
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}

class OrderPageControls extends StatelessWidget {
  final String? currentDate;
  final Function() onNextDate;
  final Function() onPreviousDate;
  final Function() onClearMeals;
  final Function() onGoToConfirm;
  final bool nextDateDisabled;
  final bool previousDateDisabled;
  final bool showConfirmControls;
  final bool showDateControls;
  final bool isCompact;


  const OrderPageControls({super.key,
    this.currentDate,
    required this.onNextDate,
    required this.onPreviousDate,
    required this.onClearMeals,
    required this.onGoToConfirm,
    this.nextDateDisabled = false,
    this.previousDateDisabled = false,
    this.showConfirmControls = false,
    this.showDateControls = true,
    required this.isCompact,
  });


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      width: isCompact ? double.infinity : ResponsiveLayout.getMaxContentWidth(context) * 0.6,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white
      ),
      child: isCompact ?  Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 10.0,
        alignment: WrapAlignment.center,
        children: [
          if (showDateControls) ...[
          _buildControlButton(
              icon: Icons.arrow_left_sharp,
              iconSize: 50,
              onPressed: () => onPreviousDate(),
              enabled: !previousDateDisabled,
              iconColor: colorScheme.primary,
          ),
          const SizedBox(width: 10),
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 200
            ),
            child: Text(
              currentDate ?? "--,---,---",
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildControlButton(
              icon: Icons.arrow_right_sharp,
              iconSize: 50,
              onPressed: () => onNextDate(),
              enabled: !nextDateDisabled,
              iconColor: colorScheme.primary,
          )
          ],
          if (showConfirmControls) ...[
            Row(
              children: [
                Expanded(child: buildMealControlButton(
                  context: context,
                  icon: Icons.clear_all,
                  label: "Clear Meals",
                  buttonColor: colorScheme.error,
                  onPressed: () => onClearMeals(),
                )),
                const SizedBox(width: 10),
                Expanded(child: buildMealControlButton(
                  context: context,
                  icon: Icons.check,
                  label: "Check Out",
                  onPressed: () => onGoToConfirm(),
                )),
              ],
            )
          ]
        ],
      ) : Column(
        children: [
          if (showDateControls) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: Icons.arrow_left_sharp,
                  iconSize: 50,
                  onPressed: () => onPreviousDate(),
                  enabled: !previousDateDisabled,
                  iconColor: colorScheme.primary,
                ),
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: 160
                  ),
                  child: Text(
                    currentDate ?? "--,---,---",
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _buildControlButton(
                  icon: Icons.arrow_right_sharp,
                  iconSize: 50,
                  onPressed: () => onNextDate(),
                  enabled: !nextDateDisabled,
                  iconColor: colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(
              thickness: 0.5,
              color: colorScheme.primary.withAlpha(100),
            )
          ],
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(bottom: 10),
              children: [
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.info,
                        size: 24,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Instructions",
                        textAlign: TextAlign.center,
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ]
                  ),
                ),
                const SizedBox(height: 10),
                _buildInstructionCard(
                    context: context,
                    title: "Hint",
                    icon: LucideIcons.info,
                    description: "Tap on meal type header to expand or collapse meal list."
                ),
                _buildInstructionCard(
                  context: context,
                    title: "Step 1",
                    icon: LucideIcons.pointer,
                    description: "Tap on the meal to add to cart/place order."
                ),
                _buildInstructionCard(
                  context: context,
                    title: "Step 2",
                    icon: LucideIcons.check,
                    description: "Review your order and proceed to checkout"
                ),
                _buildInstructionCard(
                  context: context,
                    title: "Step 3",
                    icon: LucideIcons.qrCode,
                    description: "Tap on ordered meal after submitting to print QR code ticket."
                ),
                _buildInstructionCard(
                  context: context,
                    title: "Step 4",
                    icon: LucideIcons.logOut,
                    description: "Make sure to logout after submitting order and or printing ticket."
                ),
              ],
            ),
          ),
          if (showConfirmControls) ...[
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(child: buildMealControlButton(
                      context: context,
                      icon: Icons.clear_all,
                      label: "Clear",
                      buttonColor: colorScheme.error,
                      onPressed: () => onClearMeals(),
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: buildMealControlButton(
                      context: context,
                      icon: Icons.check,
                      label: "Check Out",
                      onPressed: () => onGoToConfirm(),
                    )),
                  ],
                ),
              ),
            )
          ]
        ],
      ),
    );
  }
}

Widget _buildInstructionCard({
  required BuildContext context,
  required String title,
  required IconData icon,
  required String description,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  return Card(
    elevation: 0,
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primary.withAlpha(20),
              child: Icon(icon, size: 20,
              color: colorScheme.primary)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              SizedBox(
                width: ResponsiveLayout.getMaxContentWidth(context) * 0.4,
                  child: Text(description,
                      softWrap: true,
                      textAlign: TextAlign.start)),
            ],
          ),
        ],
      ),
    ),
  );
}

Future<bool?> showActionConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
  IconData? icon,
  String confirmButtonText = "Confirm",
  String cancelButtonText = "Cancel",
}) async {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      constraints: BoxConstraints(
        maxWidth: ResponsiveLayout.getMaxContentWidth(context) * 0.8,
        minWidth: ResponsiveLayout.getMaxContentWidth(context) * 0.8,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: textTheme.headlineLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: 20),
          CircleAvatar(
            backgroundColor: colorScheme.primary.withAlpha(20),
            radius: 44,
            child: Icon(
              icon ?? Icons.question_mark_outlined,
              color: colorScheme.primary,
              size: 60,
            ),
          ),
          const SizedBox(height: 16),
          Text(content, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: SizedBox(
                    height: 65,
                    child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.tertiary,
                        ),
                        child: Text(confirmButtonText,
                            style: textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ))
                    ),
                  )
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: SizedBox(
                    height: 65,
                    child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.error,
                        ),
                        child: Text(cancelButtonText,
                            style: textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ))
                    ),
                  )
              ),
            ],
          )
        ],
      ),
    ),
  );
}



Widget buildMealControlButton({
  required BuildContext context,
  required IconData icon,
  required String label,
  required VoidCallback? onPressed,
  Color iconColor = Colors.white,
  Color? buttonColor,
  bool enabled = true,
}) {
  final textTheme = Theme.of(context).textTheme;
  return ElevatedButton.icon(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: buttonColor ?? AppTheme.tertiary,
    ),
    icon: Icon(icon, color: iconColor),
    label: Text(label, style: textTheme.titleMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
  ))
  );
}


class OrderMealTimeGroup {
  final String title;
  final String orderStartTime;
  final String orderEndTime;
  final List<OrderMealCard> meals;

  const OrderMealTimeGroup({required this.title,
    required this.orderStartTime,
    required this.orderEndTime, required this.meals});
}

Color getColorByMealTime(String mealType) {
  switch (mealType) {
    case 'Breakfast':
      return Color(0xFF8C201C);
    case 'Lunch':
      return Color(0xFFA15E0B);
    case 'Supper':
      return Color(0xFF086C61);
    default:
      return getRandomCustomColor();
        //Color(0xFF4F2E93);
  }
}

Color getRandomCustomColor() {
  final random = Random();
  final red = random.nextInt(256);
  final green = random.nextInt(256);
  final blue = random.nextInt(256);
  return Color.fromARGB(2, red, green, blue);
}

enum DineType {
  dineIn('Dine In'),
  takeAway('Take Away');

  final String label;
  const DineType(this.label);
}

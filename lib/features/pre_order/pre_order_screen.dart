import 'dart:math';

import 'package:canteen_pro/core/router/app_router.dart';
import 'package:canteen_pro/features/landing/get_started_provider.dart';
import 'package:canteen_pro/features/pre_order/order_provider.dart';
import 'package:canteen_pro/features/pre_order/order_widgets.dart';
import 'package:canteen_pro/models/active_meal.dart';
import 'package:canteen_pro/models/meal.dart';
import 'package:canteen_pro/models/models.dart';
import 'package:canteen_pro/network/repos/network_config.dart';
import 'package:canteen_pro/shared/widgets/segmented_switch.dart';
import 'package:canteen_pro/utils/app_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:dart_extensions_methods/dart_extension_methods.dart';

import '../../core/theme/app_theme.dart';
import '../../services/qrcode_print_service/print_helper.dart';
import '../../services/qrcode_print_service/qr_code_generator.dart';
import '../../shared/widgets/ui_utils.dart';
import '../../utils/responsive_layout.dart';
import '../admin/configuration_proivder.dart';

class PreOrderScreen extends ConsumerStatefulWidget {
  const PreOrderScreen({super.key});

  @override
  ConsumerState<PreOrderScreen> createState() => _PreOrderScreenState();
}

class _PreOrderScreenState extends ConsumerState<PreOrderScreen> {
  DineType selectedDineType = DineType.dineIn;
  int _mealQuantity = 1;
  final ScrollController _scrollController = ScrollController();
  int _currentProviderIndex = 0;
  int _currentDateIndex = 0;
  final Map<String, DineType> _dineTypes = {};
  final Map<String, int> _mealQuantities = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initPreOrderPage();
    });
  }

  void initPreOrderPage() async {
    final member = ref.read(orderState.notifier).currentMember;
    ref
        .read(orderState.notifier)
        .fetchRosterByMemberId(member?.id ?? "");
  }

  void onSelectDineType(String mealId, DineType? value, bool isAddedToCart) {
    setState(() {
      _dineTypes[mealId] = value!;
    });
  }

  void onQuantityIncreased(String mealId, bool isAddedToCart,bool cannotAddMore) {
    if (cannotAddMore) {
      showInfoDialog(
          context, "Quantity limit reached",
          "You have reached the maximum quantity limit"
      );
      return;
    }
    setState(() {
      _mealQuantities[mealId] = (_mealQuantities[mealId] ?? 1) + 1;
      _mealQuantity++;
      if (isAddedToCart) {
        ref.watch(orderState.notifier).updateSelectedActiveMeal(
            mealId, quantity: _mealQuantities[mealId]);
      }
    });
  }

  void onQuantityReduced(String mealId, bool isAddedToCart) {

    setState(() {
      if ((_mealQuantities[mealId] ?? 1) > 1) {
        _mealQuantities[mealId] = (_mealQuantities[mealId] ?? 1) - 1;
        if (isAddedToCart) {
          ref.watch(orderState.notifier).updateSelectedActiveMeal(
              mealId, quantity: _mealQuantities[mealId]);
        }
      // } else {
      //   _mealQuantities.remove(mealId);
      }
    });
  }

  void setCurrentProviderIndex(int index) {
    setState(() {
      _currentProviderIndex = index;
    });
  }

  void setCurrentDateIndex(int index) {
    setState(() {
      _currentDateIndex = index;
    });
  }

  void navigateToConfirm() async {
    final res = await context.push(AppRoute.preOrderConfirm.path);
    if (res != null && res == true) {
      final orderProvider = ref.read(orderState.notifier);
      final currentMember = ref.read(orderState.notifier).currentMember;
      setState(() {
        _mealQuantities.clear();
        _dineTypes.clear();
      });
    }
  }



  bool _hasOrderedMeal({
    required String mealId,
    required String mealPeriodId,
    required String rosterId,
    required String availableDate,
  }) {
    final orders = ref.read(orderState.notifier).orders;
    return orders.where((order) => order.mealId == mealId
        && order.periodId == mealPeriodId
        && order.mealRosterId == rosterId && order.availableDate == availableDate).isNotEmpty;
  }

  void _processResult(String? res, { Function()? onAlternateAction }) {
    if (res != null) {
      final isNotFound = res.contains("204");
      if (mounted) {
        showResultDialog(
          context,
          false,
          title: isNotFound ? 'Access Denied' : 'Error',
          message: isNotFound ? "No resource found" : res,
          onFurtherAction: res.contains("Please login again") ? () async {
            await ref.read(getStartedState.notifier).setGetStarted(false);
            await NetworkConfig().logout();
          } : null,
        );
      }
      return;
    } else {
      onAlternateAction?.call();
      return;
    }
  }

  void _addToCart({
    required String selectedMealId,
    required Meal meal,
    required MasterRosterServiceProvider? currentProvider,
    required MasterRosterDates providerDates,
    required MasterMealRoster roster,
    required MasterRosterPeriods periodRoster,
    required bool isAddedToCart,
    required bool cannotOrderMoreInPeriod,
  }) {
    final orderProvider = ref.read(orderState.notifier);
    final canteenConfig = ref.read(configurationState);


    if (isAddedToCart) {
      orderProvider.removeSelectedActiveMeal(selectedMealId);
      setState(() {});
      return;
    }

    // if (orderProvider.selectedMeals.length >= totalQuantityToOrder) {
    //   showInfoDialog(
    //       context, "Quantity limit reached",
    //       "You have reached the maximum selection quantity"
    //   );
    //   return;
    // }
    //

    if (cannotOrderMoreInPeriod) {
      showInfoDialog(
          context, "Quantity limit reached",
          "You have reached the maximum quantity limit for "
              "${periodRoster.period.name} period."
      );
      return;
    }

    orderProvider.addActiveMeal(
        meal: ActiveMeal(
          id: meal.id,
          name: meal.mealName,
          description: meal.description,
        ),
        selectedMealId: selectedMealId,
        quantity: _mealQuantities[selectedMealId] ?? 1,
        provider: currentProvider?.serviceProvider.id ?? "",
        periodId: periodRoster.period.id,
        date: providerDates.date,
        mealTypeName: periodRoster.period.name,
        location: canteenConfig.canteenSetting?.id ?? "",
        mealRoserId: roster.id
    );
    setState(() {});
  }

  Future<void> _submitOrder({
    required String selectedMealId,
    required Meal meal,
    required MasterRosterServiceProvider provider,
    required MasterRosterDates providerDates,
    required MasterRosterPeriods periodRoster,
    required bool hasOrderedAlready
  }) async {
    final canteenConfig = ref.read(configurationState);
    final orderProvider = ref.read(orderState.notifier);
    final selectedLocation = canteenConfig.canteenSetting;

    if (hasOrderedAlready) {
      showInfoDialog(
          context, "Order already placed",
          "You can only order one meal at this time."
      );
      return;
    }

    if (selectedLocation == null) {
      _processResult("No location selected");
      return;
    }
    final proceed = await showActionConfirmDialog(
        context: context, title: "Confirm Meal Order",
        content: "${meal.mealName} x 1"
    );

    if (proceed == null || !proceed) {
      return;
    }

    if (orderProvider.orders.isEmpty) {
      if (mounted) {
        showFullScreenLoadingDialog(context);
      }
      final res = await orderProvider.submitMemberOrder(
          meals: [meal],
          quantity: _mealQuantities[selectedMealId] ?? 1,
          availableDate: providerDates.date,
          locationId: selectedLocation.id,
          periodId: periodRoster.period.id
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
      _processResult(res);
      return;
    } else {
      showInfoDialog(
          context, "Order already placed",
          "You can only order one meal at this time."
      );
    }
  }

  Future<void> _printOrderQr({
    required String mealId,
    required String mealPeriodId,
    required String rosterId,
    required String availableDate,
  }) async {
    try {
      final orders =  ref.read(orderState.notifier).orders;
      final currentUser = ref.read(orderState.notifier).currentMember;
      final currentOrder = orders.firstWhereOrNull((order) => order.mealId == mealId
    && order.periodId == mealPeriodId
    && order.mealRosterId == rosterId && order.availableDate == availableDate);

      if (currentOrder == null) {
        return;
      }
      final newOrderData = OrderData(
        userName: currentUser?.fullName ?? "",
        serveDate: currentOrder.availableDate,
      );

      final qrCodeBytes = await QrCodeUtil.generateQrCode(currentOrder.orderId ?? "");

      await PrintHelper.showPrintPreview(
        qrCodeBytes: qrCodeBytes.$1,
        orderData: newOrderData,
        appName: 'Canteen Pro',
      );
    } catch (e) {
      _processResult(e.toString());
      debugPrint('Error printing order QR code: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final currentState = ref.watch(orderState);
    final getStartedProvider = ref.watch(getStartedState.notifier);
    final roster = currentState?.roster;
    final orderProvider = ref.watch(orderState.notifier);
    final canteenConfig = ref.watch(configurationState);

    final currentProvider = roster?.serviceProviders[_currentProviderIndex];
    final providerDates = currentProvider?.dates[_currentDateIndex];
    final currentMember = ref.watch(orderState.notifier).currentMember;
    final currentMemberCategory = ref.watch(orderState.notifier).currentMemberCategory;
    final screenWidth = ResponsiveLayout.getScreenWidth(context);
    final isCompact = screenWidth < 900;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: kToolbarHeight + 10,
          automaticallyImplyLeading: false,
          title: appBarTitleWidget(context: context,
              currentState: currentState,
              currentMember: currentMember,
              textTheme: textTheme
          ),
          centerTitle: false,
          actions: [
            appBarButton(
              onPressed: () async {
                await orderProvider.fetchRosterByMemberId(
                  currentMember?.id ?? "",
                );
              },
              icon: Icons.refresh,
              color: colorScheme.tertiary,
              title: 'Refresh',
            ),
            const SizedBox(width: 16),
            appBarButton(
              onPressed: () async {
                final proceed = await showActionConfirmDialog(
                    context: context, title: "Confirm Log Out",
                    content: "Are you sure you want to log out now?",
                  confirmButtonText: "Stay",
                  cancelButtonText: "Log Out"
                );

                if (proceed == null || proceed) {
                  return;
                }
                orderProvider.clearOrderState();
                if (!mounted) return;
                context.pop(true);
              },
              icon: Icons.logout,
              color: colorScheme.error,
              title: 'Logout',
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/doodle_bg.png',
                  fit: BoxFit.cover,
                  color: Colors.black.withAlpha(86),
                  opacity: const AlwaysStoppedAnimation(0.25),
                ),
              ),
              if (currentState == null ||
                  currentState.state == PreOrderScreenState.loading)
                 Center(child: Container(
                   height: 120,
                   width: 120,
                   decoration: BoxDecoration(
                     color: colorScheme.primary.withAlpha(230),
                     borderRadius: BorderRadius.circular(18),
                   ),
                   child: AppLoader(
                     size: 70,
                       color: colorScheme.onPrimary, backgroundColor: Colors.transparent
                   ),
                 ))
              else if (currentState.state == PreOrderScreenState.error ||
                  roster == null)
                Center(
                  child: Text(
                    currentState.errorMessage ?? 'No meal roster available.',
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          roster.serviceProviders.length > 1 ?
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SegmentedSwitch(
                              options: roster.serviceProviders
                                  .map((sp) => sp.serviceProvider.name)
                                  .toList(),
                              onChanged: (index, provider) async {
                                setCurrentDateIndex(0);
                                await Future.delayed(const Duration(milliseconds: 100));
                                setCurrentProviderIndex(index);
                              },
                              initialIndex: _currentProviderIndex,
                              thumbColor: colorScheme.primary,
                              selectedTextColor: Colors.white,
                            ),
                          ) : Container(
                            margin: const EdgeInsets.only(top: 8.0),
                            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 5),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(18),
                                bottomRight: Radius.circular(18),
                              ),
                            ),

                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.storefront_outlined,
                                  size: 24,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  currentProvider?.serviceProvider.name ?? "",
                                  style: textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.only(bottom: 200.0),
                              children: [
                                  ...?providerDates?.periods.map((periodRoster) {
                                    providerDates.periods.sort((a, b) => a.period.name.compareTo(b.period.name));

                                    return OrderMealTimeIndicator(
                                        groups: [
                                            OrderMealTimeGroup(
                                              title: periodRoster.period.name,
                                              orderStartTime: periodRoster.orderStarTime.normalizedTime,
                                              orderEndTime: periodRoster.orderEndTime.normalizedTime,
                                              meals: [
                                                ...sortedMealList(periodRoster.meals).map((meal) {
                                                  final selectedMealId = "${meal.id}${periodRoster.period.id}${providerDates.date}";
                                                  final isAddedToCart = orderProvider.isAddedToCart(selectedMealId);
                                                  final mandatoryPreOrder = currentMemberCategory?.mandatoryPreorder ?? false;
                                                  final totalQuantityToOrder = currentMemberCategory?.mealsPerServing ?? 0;
                                                  final canOrderMultiple = mandatoryPreOrder || totalQuantityToOrder > 1;
                                                  final cannotOrderMore = orderProvider.selectedMeals.length
                                                      >= totalQuantityToOrder && canOrderMultiple;
                                                  final mealsForCurrentDate = orderProvider.selectedMeals
                                                      .where((meal) => meal.availableDate == providerDates.date);
                                                  final mealsForCurrentDateIds = mealsForCurrentDate
                                                      .map((meal) => meal.id).toList();
                                                  final mealsForCurrentPeriod = mealsForCurrentDate
                                                      .where((meal) => meal.periodId == periodRoster.period.id);
                                                  final mealsForCurrentPeriodIds = mealsForCurrentPeriod
                                                      .map((meal) => meal.id).toList();

                                                  final hasOrderedMeal = orderProvider.orderMealIds.contains(selectedMealId);
                                                  final hasReachedMaxOrder = orderProvider.orderMealIds.length >= totalQuantityToOrder;


                                                  final cannotOrderMoreInPeriod = canOrderMultiple
                                                      && mealsForCurrentPeriod.length >= totalQuantityToOrder;


                                                  return OrderMealCard(
                                                  meal: ActiveMeal(
                                                    id: meal.id,
                                                    name: meal.mealName,
                                                    description: meal.description,
                                                  ),
                                                  quantity: _mealQuantities[selectedMealId] ?? 1,
                                                  onQuantityIncreased: () => onQuantityIncreased(selectedMealId, isAddedToCart, cannotOrderMore),
                                                  onQuantityReduced: () => onQuantityReduced(selectedMealId, isAddedToCart),
                                                  availableDate: providerDates.date.normalizedDate,
                                                  hasOrdered: _hasOrderedMeal(
                                                      mealId: meal.id,
                                                      mealPeriodId: periodRoster.period.id,
                                                      rosterId: roster.id,
                                                      availableDate: providerDates.date
                                                  ),
                                                  canOrderMultiple: canOrderMultiple,
                                                  isAddedToCart: orderProvider.isAddedToCart(selectedMealId),
                                                  onAddToCart: () => _addToCart(
                                                      selectedMealId: selectedMealId,
                                                      meal: meal,
                                                      currentProvider: currentProvider,
                                                      providerDates: providerDates,
                                                      roster: roster,
                                                      periodRoster: periodRoster,
                                                      isAddedToCart: isAddedToCart,
                                                      cannotOrderMoreInPeriod: cannotOrderMoreInPeriod,
                                                  ),
                                                  onSaveOrder: () async {
                                                    await _submitOrder(
                                                        selectedMealId: selectedMealId,
                                                        meal: meal,
                                                        provider: currentProvider!,
                                                        providerDates: providerDates,
                                                        periodRoster: periodRoster,
                                                      hasOrderedAlready: orderProvider.orderMealIds.isNotEmpty
                                                    );
                                                  },
                                                  onPrintOrder: () async {
                                                    await _printOrderQr(
                                                        mealId: meal.id,
                                                        mealPeriodId: periodRoster.period.id,
                                                        rosterId: roster.id,
                                                        availableDate: providerDates.date
                                                    );
                                                  },
                                                  mealType: periodRoster.period.name,
                                                  onSelectLocation: (_) {},
                                                  serveLocations: periodRoster.locations,
                                                  selectedDineType: _dineTypes[selectedMealId] ??
                                                      selectedDineType,
                                                  onSelectDineType: (type) {
                                                    onSelectDineType(
                                                        selectedMealId, type, isAddedToCart);
                                                  },
                                                  order: null,
                                                );}),
                                              ],
                                            ),
                                        ],
                                      );
                                    }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isCompact) ...[
                    OrderPageControls(
                      isCompact: false,
                      currentDate: providerDates?.date.normalizedDate,
                      onPreviousDate: () {
                        if (_currentDateIndex == 0) return;
                        setCurrentDateIndex(_currentDateIndex - 1);
                      },
                      previousDateDisabled: _currentDateIndex == 0,
                      onNextDate: () {
                        if (currentProvider == null) return;
                        if (_currentDateIndex == currentProvider.dates.length - 1) {
                          return;
                        }
                        setCurrentDateIndex(_currentDateIndex + 1);
                      },
                      onClearMeals: () {
                        orderProvider.clearSelectedMeals();
                        setState(() {});
                      },
                      onGoToConfirm: () async => navigateToConfirm(),
                      showConfirmControls: orderProvider.selectedMeals.isNotEmpty,
                      nextDateDisabled: currentProvider == null ||
                          _currentDateIndex == currentProvider.dates.length - 1,
                      showDateControls: currentProvider != null && currentProvider.dates.length > 1,
                    ),
                    ]
                  ],
                ),
                //      if (_scrollController.offset != _scrollController.initialScrollOffset)
                // Positioned(
                //   bottom: 100,
                //   right: 10,
                //   child: IconButton(
                //     onPressed: () {},
                //     icon: Icon(Icons.arrow_upward),
                //     style: IconButton.styleFrom(
                //       iconSize: 50,
                //       backgroundColor: Colors.black.withAlpha(120),
                //       foregroundColor: Colors.white,
                //       shape: CircleBorder(
                //         side: BorderSide(
                //           color: AppTheme.cardBorderDeep,
                //           width: 1.5,
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ],
              if (isCompact) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: OrderPageControls(
                    isCompact: isCompact,
                    currentDate: providerDates?.date.normalizedDate,
                    onPreviousDate: () {
                      if (_currentDateIndex == 0) return;
                      setCurrentDateIndex(_currentDateIndex - 1);
                    },
                    previousDateDisabled: _currentDateIndex == 0,
                    onNextDate: () {
                      if (currentProvider == null) return;
                      if (_currentDateIndex == currentProvider.dates.length - 1) {
                        return;
                      }
                      setCurrentDateIndex(_currentDateIndex + 1);
                    },
                    onClearMeals: () {
                      orderProvider.clearSelectedMeals();
                      setState(() {});
                    },
                    onGoToConfirm: () => navigateToConfirm(),
                    showConfirmControls: orderProvider.selectedMeals.isNotEmpty,
                    nextDateDisabled: currentProvider == null ||
                        _currentDateIndex == currentProvider.dates.length - 1,
                    showDateControls: currentProvider != null && currentProvider.dates.length > 1,
                  ),
                ),
              ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget appBarButton({
    required String title,
    required IconData icon,
    required VoidCallback? onPressed,
    Color? color,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          visualDensity: VisualDensity.compact,
          backgroundColor: color?.withAlpha(150),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        icon: Icon(icon, color: Colors.white),
        label: Text(title, style: textTheme.titleSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ))
    );
  }
}

Widget appBarTitleWidget({
  required BuildContext context,
  required PreOrderState? currentState,
  required Member? currentMember,
  required TextTheme textTheme,
  IconData? leadingIcon
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final screenWidth = ResponsiveLayout.getScreenWidth(context);

  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: CircleAvatar(
          backgroundColor: Colors.white.withAlpha(45),
          child: Icon(
            leadingIcon ?? LucideIcons.userCircle,
            color: Colors.white,
            size: 25,
          ),
        ),
      ),
      const SizedBox(width: 5),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 5),
        width: screenWidth * 0.4,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(45),
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(
          currentState?.state == PreOrderScreenState.loading
              ? 'Loading...'
              : currentMember?.fullName ?? '---',
          softWrap: false,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}

List<Meal> sortedMealList(List<Meal> mealList) {
  if (mealList.isEmpty) return mealList;
  mealList.sort((a, b) {
    final mealA = a.mealName.toLowerCase();
    final mealB = b.mealName.toLowerCase();
    return mealA.compareTo(mealB);
  });
  return mealList;
}

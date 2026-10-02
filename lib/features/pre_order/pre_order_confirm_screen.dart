import 'package:canteen_pro/features/pre_order/order_provider.dart';
import 'package:canteen_pro/features/pre_order/pre_order_screen.dart';
import 'package:canteen_pro/models/active_meal.dart';
import 'package:canteen_pro/models/canteen_setting.dart';
import 'package:canteen_pro/models/meal_roster.dart';
import 'package:canteen_pro/models/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../models/meal.dart';
import '../../network/repos/network_config.dart';
import '../../shared/widgets/ui_utils.dart';
import '../../utils/app_extensions.dart';
import '../landing/get_started_provider.dart';
import 'order_widgets.dart';

class PreOrderConfirmScreen extends ConsumerStatefulWidget {
  const PreOrderConfirmScreen({super.key});

  @override
  ConsumerState<PreOrderConfirmScreen> createState() =>
      _PreOrderConfirmScreenState();
}

class _PreOrderConfirmScreenState
    extends ConsumerState<PreOrderConfirmScreen> {
  bool _isSubmitting = false;

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


  Future<void> _submitSelectedMeals() async {
    final orderProvider = ref.read(orderState.notifier);

    final proceed = await showActionConfirmDialog(
        context: context, title: "Confirm Meals Order",
        content: "${orderProvider.selectedMeals.length} "
            "meal(s) will be submitted for processing. Do you want to proceed?",
    );

    if (proceed == null || !proceed) {
      return;
    }
      if (mounted) {
        showFullScreenLoadingDialog(context);
      }

      final result = await ref.read(orderState.notifier).submitSelectedMeals();
      if(result == null) {
        if (mounted) {
          Navigator.of(context).pop();

          final proceed = await showActionConfirmDialog(
            context: context, title: "Order placed Successfully",
            content: "How would you like to proceed?",
            cancelButtonText: "Log Out",
            confirmButtonText: "Order/Print"
          );

          if (proceed == null || !proceed) {
            if (!mounted) return;
            context.pop(true);
            context.pop(true);
            return;
          }
          if (!mounted) return;
          context.pop(true);
        }
        return;
      }
      _processResult(result);

  }

  // Future<void> _submitSelectedMeals() async {
  //   if (_isSubmitting) return;
  //   setState(() => _isSubmitting = true);
  //
  //   if (!mounted) return;
  //   final result = await ref.read(orderState.notifier).submitSelectedMeals();
  //   setState(() => _isSubmitting = false);
  //   if (result != null) {
  //     _processResult(result);
  //     return;
  //   }
  //
  //   showSnack(
  //     context: context,
  //     text: 'Your orders have been submitted successfully.',
  //   );
  //   context.pop();
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final orderProvider = ref.watch(orderState.notifier);
    final selectedMeals = orderProvider.selectedMeals;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final preOrder = ref.watch(orderState);
    final isWide = screenWidth >= 760;
    final quantityTotal = selectedMeals.fold<int>(0, (total, item) => total + item.quantity);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + 10,
        automaticallyImplyLeading: true,
        foregroundColor: colorScheme.onPrimary,
        title: Text("Confirm and Submit Order",
            style: textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        )),
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
            Positioned.fill(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: selectedMeals.isEmpty
                      ? _buildEmptyState(context)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                isWide ? 32 : 16,
                                24,
                                isWide ? 32 : 16,
                                16,
                              ),
                              child: _buildSummary(
                                context,
                                selectedMeals.length,
                                quantityTotal,
                              ),
                            ),
                            if (isWide)
                              const _ListHeading()
                            else
                              const SizedBox.shrink(),
                            Expanded(
                              child: ListView.separated(
                                padding: EdgeInsets.fromLTRB(
                                  isWide ? 32 : 16,
                                  0,
                                  isWide ? 32 : 16,
                                  24,
                                ),
                                itemCount: selectedMeals.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final selectedMeal = selectedMeals[index];
                                  final provider = _findProvider(
                                    orderProvider.providers,
                                    selectedMeal.provider,
                                  );
                                  final locations = _findLocations(
                                    orderProvider,
                                    selectedMeal,
                                  );
                                  return _SelectedMealCard(
                                    meal: selectedMeal,
                                    provider: provider,
                                    locations: locations,
                                    selectedLocation: _findLocation(
                                      orderProvider.canteenSettings,
                                      selectedMeal.locationId,
                                    ),
                                    wide: isWide,
                                    onLocationChanged: (location) {
                                      orderProvider.updateSelectedActiveMeal(
                                        selectedMeal.id,
                                        location: location?.id ?? '',
                                      );
                                      setState(() {});
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 100,
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 32 : 16,
            vertical: 12,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E8F0))),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : () => context.pop(),
                      icon: const Icon(Icons.close_rounded),
                      label: Text('Cancel', style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting || selectedMeals.isEmpty
                          ? null
                          : _submitSelectedMeals,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: Text(_isSubmitting ? 'Submitting...' : 'Submit',
                          style:textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      )),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.tertiary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(
    BuildContext context,
    int mealCount,
    int quantityTotal,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF1FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              color: Color(0xFF1C2864),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your selected meals',
                  style: textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF151D45),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$mealCount ${mealCount == 1 ? 'meal' : 'meals'} · $quantityTotal ${quantityTotal == 1 ? 'serving' : 'servings'}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF69718B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 52,
              color: Color(0xFF8A91A7),
            ),
            const SizedBox(height: 14),
            Text(
              'No meals selected yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF202848),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose meals first, then review them here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF69718B)),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to meals'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListHeading extends StatelessWidget {
  const _ListHeading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(32, 8, 32, 10),
      child: Row(
        children: [
          Expanded(flex: 5, child: _HeadingLabel('MEAL')),
          Expanded(flex: 3, child: _HeadingLabel('SERVICE PROVIDER')),
          Expanded(flex: 4, child: _HeadingLabel('LOCATION')),
          SizedBox(width: 76, child: _HeadingLabel('QTY', alignEnd: true)),
        ],
      ),
    );
  }
}

class _HeadingLabel extends StatelessWidget {
  const _HeadingLabel(this.label, {this.alignEnd = false});

  final String label;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: alignEnd ? TextAlign.end : TextAlign.start,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: const Color(0xFF798098),
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _SelectedMealCard extends StatelessWidget {
  const _SelectedMealCard({
    required this.meal,
    required this.provider,
    required this.locations,
    required this.selectedLocation,
    required this.wide,
    required this.onLocationChanged,
  });

  final SelectedActiveMeal meal;
  final ServiceProvider? provider;
  final List<CanteenSetting> locations;
  final CanteenSetting? selectedLocation;
  final bool wide;
  final ValueChanged<CanteenSetting?> onLocationChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(wide ? 16 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E8F0)),
      ),
      child: wide ? _buildWideLayout(context) : _buildCompactLayout(context),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: _MealDetails(meal: meal.meal, mealType: meal.mealType),
        ),
        Expanded(
          flex: 3,
          child: _ProviderDetails(provider: provider, providerId: meal.provider),
        ),
        SizedBox(width: 76, child: _Quantity(quantity: meal.quantity)),
      ],
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MealDetails(meal: meal.meal, mealType: meal.mealType),
            ),
            const SizedBox(width: 12),
            _Quantity(quantity: meal.quantity),
          ],
        ),
        const SizedBox(height: 8),
        _ProviderDetails(provider: provider, providerId: meal.provider),
        // const SizedBox(height: 12),
        // _LocationPicker(
        //   locations: locations,
        //   selectedLocation: selectedLocation,
        //   onChanged: onLocationChanged,
        // ),
      ],
    );
  }
}

class _MealDetails extends StatelessWidget {
  const _MealDetails({required this.meal, required this.mealType});

  final ActiveMeal meal;
  final String mealType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          meal.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF202848),
          ),
        ),
        if (meal.description?.isNotEmpty == true) ...[
          const SizedBox(height: 3),
          Text(
            meal.description!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF737B92),
            ),
          ),
        ],
        const SizedBox(height: 5),
        Text(
          mealType,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF5E6887),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ProviderDetails extends StatelessWidget {
  const _ProviderDetails({required this.provider, required this.providerId});

  final ServiceProvider? provider;
  final String providerId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.storefront_outlined,
          size: 18,
          color: Color(0xFF69718B),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            provider?.name ?? (providerId.isEmpty ? 'Provider unavailable' : providerId),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF3F4968),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationPicker extends StatelessWidget {
  const _LocationPicker({
    required this.locations,
    required this.selectedLocation,
    required this.onChanged,
  });

  final List<CanteenSetting> locations;
  final CanteenSetting? selectedLocation;
  final ValueChanged<CanteenSetting?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (locations.isEmpty) {
      return const Row(
        children: [
          Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF69718B)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'No serving locations available',
              style: TextStyle(color: Color(0xFF737B92)),
            ),
          ),
        ],
      );
    }

    final selectedId = locations.any(
      (location) => location.id == selectedLocation?.id,
    )
        ? selectedLocation!.id
        : null;

    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 18,
          color: Color(0xFF69718B),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: selectedId,
            isExpanded: true,
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              hintText: 'Choose location',
              border: OutlineInputBorder(),
            ),
            items: locations
                .map(
                  (location) => DropdownMenuItem(
                    value: location.id,
                    child: Text(location.name, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (locationId) {
              CanteenSetting? location;
              for (final item in locations) {
                if (item.id == locationId) {
                  location = item;
                  break;
                }
              }
              onChanged(location);
            },
          ),
        ),
      ],
    );
  }
}

class _Quantity extends StatelessWidget {
  const _Quantity({required this.quantity});

  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'QTY',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFF798098),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          constraints: const BoxConstraints(minWidth: 38),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF1FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF1C2864),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

ServiceProvider? _findProvider(List<ServiceProvider> providers, String id) {
  for (final provider in providers) {
    if (provider.id == id) return provider;
  }
  return null;
}

CanteenSetting? _findLocation(List<CanteenSetting> locations, String id) {
  if (id.isEmpty) return null;
  for (final location in locations) {
    if (location.id == id) return location;
  }
  return null;
}

List<CanteenSetting> _findLocations(
  OrderProvider orderProvider,
  SelectedActiveMeal selectedMeal,
) {
  final roster = orderProvider.masterMealRoster;
  if (roster == null) return orderProvider.canteenSettings;

  for (final provider in roster.serviceProviders) {
    if (provider.serviceProvider.id != selectedMeal.provider) continue;
    for (final date in provider.dates) {
      if (_dateKey(date.date) != _dateKey(selectedMeal.availableDate)) continue;
      for (final period in date.periods) {
        if (period.period.id == selectedMeal.periodId) {
          return period.locations;
        }
      }
    }
  }
  return orderProvider.canteenSettings;
}

String _dateKey(String date) =>
    date.length >= 10 ? date.substring(0, 10) : date;

import 'package:canteen_pro/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:newmidx_biometric/newmidx_biometric.dart';

import '../../models/member.dart';
import '../../repositories/user_repository.dart';

const appIconPath = 'assets/images/canteen_logo.png';
const appIconDarkPath = 'assets/images/canteen_logo.png';

void showSnack({
  required String text,
  required BuildContext context,
  bool isError = false,
  bool isLong = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: isError
              ? Colors.white
              : Theme.of(context).colorScheme.onTertiary,
        ),
        textAlign: TextAlign.center,
      ),
      backgroundColor: isError
          ? Theme.of(context).colorScheme.error
          : Theme.of(context).colorScheme.tertiary,
      duration: Duration(seconds: isLong ? 5 : 3),
    ),
  );
}

void showCustomSnack({
  required String text,
  required BuildContext context,
  bool isError = false,
  bool isLong = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: isError
              ? Colors.white
              : Theme.of(context).colorScheme.onTertiary,
        ),
        textAlign: TextAlign.center,
      ),
      backgroundColor: isError
          ? Theme.of(context).colorScheme.error
          : Theme.of(context).colorScheme.tertiary,
      duration: Duration(seconds: isLong ? 5 : 3),
    ),
  );
}

void showInfoDialog(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(width: 5),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Ok'),
          ),
        ],
      );
    },
  );
}

void showBioMetricDialog(
  BuildContext context, {
  required Function onCancelled,
  bool isPalm = false,
  bool isFinger = false,
  bool isNfc = false,
  String? palmToUpdate,
  Stream<dynamic>? hintStream,
  Stream<dynamic>? enrollProgressStream,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return PopScope(
        canPop: false,
        child: StatefulBuilder(
          builder: (context, putState) {
            return AlertDialog(
              title: const Text("Scanning...", textAlign: TextAlign.center),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPalm) ...[
                    if (enrollProgressStream != null)
                      StreamBuilder<dynamic>(
                        stream: enrollProgressStream,
                        builder: (context, snapshot) {
                          final progress = snapshot.data;

                          if (progress == null) {
                            return Column(
                              children: [
                                const SizedBox(height: 16),
                                Text(
                                  "Place ${palmToUpdate ?? 'Left'} palm over the sensor",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          }

                          if (progress is! EnrollProgressEvent) {
                            return const SizedBox.shrink();
                          }
                          final event = progress;
                          final progressText =
                              "${getCurrentHand(event.capturedHands, event.hand)}\nStatus: ${event.message}";

                          return Column(
                            children: [
                              const SizedBox(height: 16),
                              Text(
                                progressText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
                  ],
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 90,
                          height: 90,
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                            strokeWidth: 4.0,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          backgroundColor: colorScheme.primary.withAlpha(20),
                          radius: 44,
                          child: Icon(
                            isPalm
                                ? LucideIcons.hand
                                : isFinger
                                ? LucideIcons.fingerprint
                                : LucideIcons.idCardLanyard,
                            color: colorScheme.primary,
                            size: 54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isPalm
                        ? "Place your palm above the sensor"
                        : isFinger
                        ? "Place your finger on the sensor"
                        : "Hold your NFC card near the reader",
                    textAlign: TextAlign.center,
                  ),
                  if (hintStream != null)
                    StreamBuilder<dynamic>(
                      stream: hintStream,
                      builder: (context, snapshot) {
                        final hint = snapshot.data;
                        if (hint == null) {
                          return const SizedBox.shrink();
                        }
                        if (hint is PalmHintEvent) {
                          final message = hint.message;
                          if (message == null || message.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            children: [
                              const SizedBox(height: 14),
                              Text(
                                message.replaceAll("_", " "),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: colorScheme.tertiary),
                              ),
                            ],
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    onCancelled();
                    await Future.delayed(const Duration(milliseconds: 500));
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

String getCurrentHand(Set<PalmHand> hands, PalmHand? currentEventHand) {
  if (currentEventHand == null) return 'Scanning...';
  if (hands.isEmpty) {
    return 'Enrolling ${getHand(currentEventHand)}.';
  }
  if (hands.contains(PalmHand.left)) {
    return 'Enrolling Right Hand.';
  }
  if (hands.contains(PalmHand.right)) {
    return 'Enrolling Left Hand.';
  }
  if (hands.length == 2) {
    return 'Enrollment Complete.';
  }
  return 'Scanning...';
}

String getHand(PalmHand? hand) {
  if (hand == null) return 'Unknown';
  switch (hand) {
    case PalmHand.left:
      return 'Left Hand';
    case PalmHand.right:
      return 'Right Hand';
  }
}

void _append(String line, List<String> log, Function setState) {
  setState(() {
    log.insert(0, line);
    if (log.length > 80) {
      log.removeLast();
    }
  });
}

void showResultDialog(
  BuildContext context,
  bool isSuccessful, {
  String? title,
  String? message,
  bool isEnrollment = false,
  bool useIsSuccessful = true,
  bool useControls = true,
  Function? onFurtherAction,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;
  final successMessage = isEnrollment
      ? "User enrolled Successfully."
      : "Authentication Successful.";
  final failureMessage = isEnrollment
      ? "User enrollment failed."
      : "Authentication failed.";
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          isSuccessful ? title ?? "Success" : title ?? "Failure",
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(
            color: isSuccessful ? Colors.green : colorScheme.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor: isSuccessful
                  ? Colors.green.withAlpha(20)
                  : colorScheme.error.withAlpha(20),
              radius: 44,
              child: Icon(
                isSuccessful ? LucideIcons.checkCircle : LucideIcons.xCircle,
                color: isSuccessful ? Colors.green : colorScheme.error,
                size: 54,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              isSuccessful ? successMessage : message ?? failureMessage,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: useControls
            ? [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (onFurtherAction != null) {
                      onFurtherAction();
                    }
                    if (isSuccessful && useIsSuccessful) {
                      Navigator.pop(context);
                      if (onFurtherAction != null) {
                        onFurtherAction();
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccessful
                        ? colorScheme.primary
                        : colorScheme.error,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    "OK",
                    style: textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                ),
              ]
            : null,
      );
    },
  );
}

Future<Member?> showAdminVerificationDialog(BuildContext context) async {
  final formKey = GlobalKey<FormState>();
  final adminIdController = TextEditingController();
  var isLoading = false;
  String? errorMessage;

  final result = await showDialog<Member>(
    context: context,
    builder: (dialogContext) {
      final colorScheme = Theme.of(dialogContext).colorScheme;
      return StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          Future<void> verifyAdmin() async {
            if (isLoading || formKey.currentState?.validate() != true) return;
            setDialogState(() {
              isLoading = true;
              errorMessage = null;
            });
            try {
              final member = await UserRepository().fetchUsersByStaffId(
                adminIdController.text.trim(),
              );
              if (!dialogContext.mounted) return;
              if (member.role == 1) {
                Navigator.of(dialogContext).pop(member);
              } else {
                setDialogState(() {
                  errorMessage =
                      'This member is not authorized for admin mode.';
                });
              }
            } on Exception {
              if (dialogContext.mounted) {
                setDialogState(() {
                  errorMessage = 'Unable to verify this ID. Please try again.';
                });
              }
            } finally {
              if (dialogContext.mounted) {
                setDialogState(() => isLoading = false);
              }
            }
          }

          return AlertDialog(
            title: Text(
              'Admin mode',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primary.withAlpha(30),
                    radius: 44,
                    child: Icon(
                      LucideIcons.shieldUser,
                      size: 46,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Enter your staff ID to continue'),
                  const SizedBox(height: 12),
                  Form(
                    key: formKey,
                    child: TextFormField(
                      controller: adminIdController,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => verifyAdmin(),
                      decoration: const InputDecoration(
                        labelText: 'Staff ID',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Please enter your staff ID'
                          : null,
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading
                    ? null
                    : () => { Navigator.of(dialogContext).pop() },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: isLoading ? null : verifyAdmin,
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Verify'),
              ),
            ],
          );
        },
      );
    },
  );
  adminIdController.dispose();
  return result;
}

Future<void> showLoadingDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) {
      return PopScope(
        canPop: false,
        child: SizedBox(
          child: AlertDialog(
            constraints: BoxConstraints(
              maxWidth: 100,
              minWidth: 100,
              maxHeight: 100,
              minHeight: 100,
            ),
            content: Center(
              child: SizedBox(
                height: 30,
                width: 30,
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showFullScreenLoadingDialog(
  BuildContext context, {
  String? loadText,
}) async {
  showDialog(
    context: context,
    builder: (context) {
      return PopScope(
        canPop: false,
        child: SizedBox(
          child: Dialog.fullscreen(
            backgroundColor: Colors.black.withAlpha(130),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loadText ?? "Loading...",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class AppLoader extends StatelessWidget {
  final Color color;
  final Color? backgroundColor;
  final double size;
  const AppLoader({super.key, this.color = Colors.white, this.backgroundColor, this.size = 90});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              color: color,
              strokeWidth: 4.0,
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: CircleAvatar(
            backgroundColor: backgroundColor ?? colorScheme.primary.withAlpha(20),
            radius: 44,
            child: Image.asset(
              appIconDarkPath,
              color: color,
              width: size > 36 ? size - 36 : 36,
              height: size > 36 ? size - 36 : 36,
            )
          ),
        ),
      ],
    );
  }
}


typedef ItemLabelBuilder<T> = String Function(T item);
typedef ItemRefresher<T> = Future<List<T>> Function();

/// A generic bottom sheet that shows a list of [T] items with a title,
/// a refresh button and a confirm button in the header.
///
/// Note: selection relies on `==` / `hashCode`, so make sure [T] implements
/// them properly (or use primitives / enums / immutable value classes).
class SelectionBottomSheet<T> extends StatefulWidget {
  const SelectionBottomSheet({
    super.key,
    required this.title,
    required this.items,
    required this.itemLabel,
    this.onRefresh,
    this.initialSelected = const [],
    this.multiSelect = false,
    this.itemBuilder,
    this.emptyText = 'No items found',
  });

  final String title;
  final List<T> items;

  /// Used for the default list tile title.
  final ItemLabelBuilder<T> itemLabel;

  /// Called when the refresh button is tapped. Return the new list of items.
  /// If null, the refresh button is hidden.
  final ItemRefresher<T>? onRefresh;

  final List<T> initialSelected;
  final bool multiSelect;

  /// Optional custom row builder. Receives whether the item is selected.
  final Widget Function(BuildContext context, T item, bool selected)?
  itemBuilder;

  final String emptyText;

  /// Shows the sheet and returns the confirmed selection,
  /// or null if dismissed without confirming.
  static Future<List<T>?> show<T>(
      BuildContext context, {
        required String title,
        required List<T> items,
        required ItemLabelBuilder<T> itemLabel,
        ItemRefresher<T>? onRefresh,
        List<T> initialSelected = const [],
        bool multiSelect = false,
        Widget Function(BuildContext context, T item, bool selected)? itemBuilder,
      }) {
    return showModalBottomSheet<List<T>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => SelectionBottomSheet<T>(
        title: title,
        items: items,
        itemLabel: itemLabel,
        onRefresh: onRefresh,
        initialSelected: initialSelected,
        multiSelect: multiSelect,
        itemBuilder: itemBuilder,
      ),
    );
  }

  @override
  State<SelectionBottomSheet<T>> createState() =>
      _SelectionBottomSheetState<T>();
}

class _SelectionBottomSheetState<T> extends State<SelectionBottomSheet<T>> {
  late List<T> _items;
  late Set<T> _selected;
  bool _loading = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _items = List<T>.of(widget.items);
    _selected = widget.initialSelected.toSet();
  }

  Future<void> _refresh() async {
    final refresher = widget.onRefresh;
    if (refresher == null || _loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final newItems = await refresher();
      if (!mounted) return;
      setState(() {
        _items = newItems;
        // Drop selections that no longer exist in the refreshed list.
        _selected = _selected.where(newItems.contains).toSet();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggle(T item) {
    setState(() {
      if (widget.multiSelect) {
        _selected.contains(item) ? _selected.remove(item) : _selected.add(item);
      } else {
        _selected = {item};
      }
    });
  }

  void _confirm() {
    // Preserve the on-screen order of items.
    final result = _items.where(_selected.contains).toList();
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final maxHeight = MediaQuery.of(context).size.height * 0.6;

    return Padding(
      // Keeps content above the keyboard if one is shown.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(theme),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10.0),
            child: Divider(height: 1, thickness: 0.5, color: AppTheme.cardBorderDeep),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Refresh failed. Tap refresh to try again.',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          if (widget.onRefresh != null)
            SizedBox(
              width: 48,
              height: 48,
              child: _loading
                  ? const Padding(
                padding: EdgeInsets.all(14),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refresh,
              ),
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge,
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: Text('Confirm', style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white)
            ),
            style: ElevatedButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
            onPressed: _selected.isEmpty || _loading ? null : _confirm,
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    if (_items.isEmpty && !_loading) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(child: Text(widget.emptyText)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final selected = _selected.contains(item);

        return InkWell(
          onTap: _loading ? null : () => _toggle(item),
          child: widget.itemBuilder?.call(context, item, selected) ??
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: selected ? colors.tertiary
                      : colors.primary.withAlpha(60) ,
                  child: Text(
                    widget.itemLabel(item).substring(0, 1),
                    style: textTheme.titleMedium?.copyWith(
                      color: selected ? Colors.white : colors.primary,
                    ),
                  ),
                ),
                title: Text(widget.itemLabel(item), style: textTheme.titleMedium?.copyWith(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                )),
                selected: selected,
                trailing: selected ? Icon(Icons.check_circle, color: colors.tertiary,) : null,
              ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Usage example
// ---------------------------------------------------------------------------
//
// final result = await SelectionBottomSheet.show<String>(
//   context,
//   title: 'Select city',
//   items: ['Accra', 'Kumasi', 'Tamale'],
//   itemLabel: (city) => city,
//   initialSelected: ['Accra'],
//   multiSelect: false,
//   onRefresh: () async {
//     await Future.delayed(const Duration(seconds: 1));
//     return ['Accra', 'Kumasi', 'Tamale', 'Takoradi'];
//   },
// );
//
// if (result != null && result.isNotEmpty) {
//   print('Selected: ${result.first}');
// }


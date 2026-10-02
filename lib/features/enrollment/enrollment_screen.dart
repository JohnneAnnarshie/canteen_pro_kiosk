import 'dart:developer';

import 'package:canteen_pro/features/enrollment/user_provider.dart';
import 'package:canteen_pro/models/member.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:newmidx_biometric/newmidx_biometric.dart';

import '../../core/theme/app_theme.dart';
import '../../models/employee_biodata.dart';
import '../../network/repos/network_config.dart';
import '../../services/finger_face_service/finger_face_plugin.dart';
import '../../services/palm_vein_plugin/palm_vein_service.dart';
import '../../shared/widgets/floating_app_bar.dart';
import '../../shared/widgets/ui_utils.dart';
import '../../utils/cancel_token.dart';
import '../../utils/responsive_layout.dart';
import '../landing/get_started_provider.dart';

class EnrollmentScreen extends ConsumerStatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  ConsumerState<EnrollmentScreen> createState() => _UserEnrollmentScreenState();
}

class _UserEnrollmentScreenState extends ConsumerState<EnrollmentScreen> {
  final TextEditingController _searchController = TextEditingController();
  CancelToken? _cancelToken;
  final _palmVeinService = PalmVeinService();
  final _fingerFaceService = FingerFaceService();
  late final MembersProvider _employeesProvider;
  bool _isLoading = false;
  bool _isFetching = false;
  bool _isFetchingBioData = false;
  bool _showAddBioDataForm = false;
  String? _selectedBioDataType;
  String? _selectedBioDataLabel;
  List<String> _currentHint = [];


  @override
  void dispose() {
    _searchController.dispose();
    _cancelToken?.cancel();
    _palmVeinService.closeDevice();
    Future.microtask(() {
      _employeesProvider.reset();
    });
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _employeesProvider = ref.read(userProvider.notifier);
    Future.microtask(() async {
      if (!mounted) return;
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 1));
      ref.read(userProvider.notifier).reset();
      if (!mounted) return;
      setState(() => _isLoading = false);
    });
  }

  void _startListening() {
    _palmVeinService.onHint.listen((hint) {
      if (hint is PalmHintEvent) {
        setState(() {
          //_currentHint = hint.message ?? "";
        });
      }
    });

    _palmVeinService.onVerifyResult.listen((result) {});

    _palmVeinService.onCaptureProgress.listen((progress) {});
  }



  Future<void> _refresh(BuildContext context) async {}

  Future<void> _capturePalm(
      BuildContext context,
      String employeeId,
      String biodataType,
      MembersProvider provider,
      {
        String? biodataLabel,
        bool isUpdate = false,
        String? palmFeature,
      })
  async {
    _cancelToken?.cancel();
    _cancelToken = CancelToken();
    final token = _cancelToken!;

    try {
      if (!mounted) return;
      await _palmVeinService.initialize();
      if (!_palmVeinService.isInitialized) {
        log('PalmVeinService not initialized. Call initialize() first.');
        return;
      }
      _startListening();

      final Set<PalmHand> hands = biodataLabel == null ? {} :
      biodataLabel.contains('RIGHT') ?
      {PalmHand.right} :
      {PalmHand.left};

      final Set<PalmHand> bothHands = {
        PalmHand.left,
        PalmHand.right,
      };

      final res = await _palmVeinService
          .enroll(
          employeeId,
          hands: isUpdate ? hands : bothHands,
          isUpdate: isUpdate,
          palmFeature: palmFeature,
      );
      token.throwIfCancelled();
      if (res.keys.first) {
        final List<LabeledPalmTemplate> palmFeatures = [];

        if (res.values.first == null) return;

        final receivedFeatures = res.values.first as List<LabeledPalmTemplate>;

        palmFeatures.addAll(receivedFeatures);

        Navigator.pop(mounted ? context : context);
        showLoadingDialog(mounted ? context : context);
        final result = await provider.postMemberFingerData(
          palmData: palmFeatures,
          isUpdate: isUpdate,
        );

        Navigator.pop(mounted ? context : context);

        if (result != null) {
          showResultDialog(mounted ? context : context,
            false,
            message: result,
            isEnrollment: true,
          );
          return;
        }
        showResultDialog(mounted ? context : context,
            true,
            isEnrollment: true,
            onFurtherAction: () {
              provider.setEmployeeBioDataList(null);
              provider.setMember(null);
            }
        );
      } else {
        final errorMessage = res.values.first as String;
        Navigator.pop(mounted ? context : context);
        showResultDialog(mounted ? context : context, false, message: errorMessage);
        return;
      }


      // } else {
      //   Navigator.pop(mounted ? context : context);
      //   return;
      // }
    } on CancelledException {
      await _palmVeinService.closeDevice();
      log('Operation was cancelled');
      return;
    }
  }

  Future<void> _captureFinger(
      BuildContext context,
      String employeeId,
      MembersProvider provider,
      {
        bool isUpdate = false
      }) async {
    _cancelToken?.cancel();
    _cancelToken = CancelToken();
    final token = _cancelToken!;

    try {
      if (!mounted) return;
      await _fingerFaceService.init(face: false);
      if (!_fingerFaceService.isFingerprintInitialized) {
        log('FingerFaceService not initialized. Call initialize() first.');
        return;
      }

      final res = await _fingerFaceService.enrollFingerprint(userId: employeeId,
          onError: (ex) {
            Navigator.pop(mounted ? context : context);
            showResultDialog(mounted ? context : context, false, message: ex.message);
          });
      token.throwIfCancelled();

      if (res != null) {

        // Navigator.pop(mounted ? context : context);
        // showLoadingDialog(mounted ? context : context);
        // final result = await provider.postEmployeeFingerData(
        //   existingBioId,
        //   palmData: palmFeatures,
        //   isUpdate: isUpdate,
        // );

        Navigator.pop(mounted ? context : context);

        showResultDialog(mounted ? context : context,
            true,
            isEnrollment: true,
            onFurtherAction: () {
              provider.setEmployeeBioDataList(null);
              provider.setMember(null);
            }
        );
      } else {
        final errorMessage = "Error enrolling finger";
        Navigator.pop(mounted ? context : context);
        showResultDialog(mounted ? context : context, false, message: errorMessage);
        return;
      }

    } on CancelledException {
      await _palmVeinService.closeDevice();
      log('Operation was cancelled');
      return;
    }
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(mounted ? context : context).pop();
                    await Future.microtask(() async {
                      await ref.read(getStartedState.notifier).setGetStarted(false);
                      // await ref.read(tripStateProvider.notifier).setGlobalSettings(null);
                      // await ref.read(tripStateProvider.notifier).setCurrentDriver(null);
                      // await ref.read(tripStateProvider.notifier).setCurrentTrip(null);
                    });
                    await NetworkConfig().logout();
                  },
                  child: const Text('Logout'),
                ),
              ]
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    final employees = ref.watch(userProvider);
    final userProviderService = ref.read(userProvider.notifier);
    return Scaffold(
        body: SafeArea(child: _isLoading ?
        const Center(child: CircularProgressIndicator()) :
        Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            FloatingAppbar(
              titleBackgroundColor: colorScheme.surfaceContainer,
              titleForegroundColor: colorScheme.onSurface,
              title: 'User Enrollment',
              leading: Icon(LucideIcons.userCircle, color: colorScheme.primary),
              actions: [
                if (ResponsiveLayout.isTablet(context)) ...[
                  TextButton.icon(
                      onPressed: ()
                      {
                        if (!_fingerFaceService.isFingerprintInitialized) {
                           _fingerFaceService.init();
                        } else {
                          setState(() {
                            _currentHint = _fingerFaceService.logLines;
                          });
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainer,
                        side: BorderSide(
                            color: isDarkMode ? colorScheme.onSurface.withAlpha(120)
                                :  AppTheme.surfaceVariantLight
                        ),
                      ),
                      icon: Icon(LucideIcons.zap, color: colorScheme.onSurface),
                      label: Text('Initialize FP module')
                  ),
                  const SizedBox(width: 8.0),
                  TextButton.icon(
                      onPressed: () async {
                        await _palmVeinService.clearAllData();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainer,
                        side: BorderSide(
                            color: isDarkMode ? colorScheme.onSurface.withAlpha(120)
                                :  AppTheme.surfaceVariantLight
                        ),
                      ),
                      icon: Icon(LucideIcons.trash, color: colorScheme.onSurface),
                      label: Text('Clear Bio Data')
                  ),
                  const SizedBox(width: 8.0),
                  TextButton.icon(
                      onPressed: () async {
                        showLogoutDialog(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                      ),
                      icon: Icon(LucideIcons.power),
                      label: Text('Log Out', style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onError
                      ))
                  ),
                ] else ...[
                  IconButton(
                    onPressed: () async {
                      await _palmVeinService.clearAllData();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: colorScheme.surfaceContainer,
                      side: BorderSide(
                          color: isDarkMode ? colorScheme.onSurface.withAlpha(120)
                              :  AppTheme.surfaceVariantLight
                      ),
                    ),
                    icon: Icon(LucideIcons.trash, color: colorScheme.onSurface),
                  ),
                  IconButton(
                    onPressed: () async {
                      showLogoutDialog(context);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                    ),
                    icon: Icon(LucideIcons.power),

                  )
                ],
              ],
            ),
            _buildPageControls(userProviderService),
            _isFetching ? LinearProgressIndicator(
              color: colorScheme.primary,
              backgroundColor: colorScheme.primary.withAlpha(100),
            ) :
            const SizedBox.shrink(),
            employees.isEmpty ? _searchController.text.isNotEmpty ?
            Expanded(child: Center(
                child: Text("No employees found",
                    style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface.withAlpha(100))
                )
            )
            )
            //     :  Expanded(child: ListView(
            //   padding: const EdgeInsets.all(16.0),
            //   children: [
            //     ..._currentHint.map((e) => Text(e, style: textTheme.bodyMedium?.copyWith(
            //         color: colorScheme.onSurface.withAlpha(100))))
            //   ]
            // ))
                : Expanded(child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.search,
                      color: colorScheme.onSurface.withAlpha(100),
                      size: 50,
                    ),
                    const SizedBox(height: 8),
                    Text(
                        "Search employees to enroll",
                        style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface.withAlpha(100))
                    ),
                  ],
                )
            )
           ) :
            Expanded(
              child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: employees.length,
                  separatorBuilder: (context, index) {
                    return const Divider(
                      height: 0.2,
                      thickness: 0.4,
                      indent: 60.0,
                      color: Colors.grey,
                    );
                  },
                  itemBuilder: (context, index) {
                    final employee = employees[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primary.withAlpha(20),
                        child: Icon(LucideIcons.user, color: colorScheme.primary, size: 24),
                      ),
                      title: Text(employee.fullName,
                          style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold
                          )),
                      subtitle: Text(employee.staffId),
                      onTap: _isFetching ? null : () async {
                        setState(() => _isFetching = true);
                        await userProviderService.setMember(employee);
                        await Future.microtask(() async {
                          await _employeesProvider.parseStaffSecurity(employee);
                          await showEmployeeBioData(mounted ? context : context, employee, userProviderService)
                              .whenComplete(() {
                            _showAddBioDataForm = false;
                            _selectedBioDataType = null;
                            _selectedBioDataLabel = null;
                            setState(() {});
                          });
                        });
                        setState(() => _isFetching = false);
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (employee.faceRecognitionReference != null) ...[
                            buildEnrolledIndicator(
                                LucideIcons.scanFace,
                                Colors.purple
                            ),
                            SizedBox(width: 8.0),
                          ],
                          if (employee.fingerprintReference != null) ...[
                            buildEnrolledIndicator(
                              LucideIcons.fingerprint,
                              colorScheme.secondary,
                            ),
                            SizedBox(width: 8.0),
                          ],
                          // if (userProviderService.isAnyPalmEnrolled(employee.id)) ...[
                          //   buildEnrolledIndicator(
                          //     LucideIcons.hand,
                          //     colorScheme.primary,
                          //   ),
                          //   SizedBox(width: 8.0),
                          // ],
                        ],
                      ),
                    );
                  }),
            ),
          ],
        ),
        ));
  }

  Future<void> showEmployeeBioData(BuildContext context, Member employee, MembersProvider provider) async {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        useSafeArea: true,
        builder: (context) {
          final currentEmployeeBioDataList = provider.currentEmployeeBioDataList;
          return StatefulBuilder(
              builder: (context, putState) {
                return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                        child: Text(employee.fullName, style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface),
                        ),),
                      Expanded(
                          child: ListView(
                            padding: const EdgeInsets.all(16.0),
                            children: [
                              if (_showAddBioDataForm) ...
                              buildAddBioDataForm(
                                GlobalKey(),
                                context,
                                provider,
                                employee: employee,
                                onTypeSelected: (value) {
                                  putState(() => _selectedBioDataType = value);
                                },
                                onLabelSelected: (value) {
                                  putState(() => _selectedBioDataLabel = value);
                                },
                                onBackPressed: () => putState(() => _showAddBioDataForm = false),
                              )
                              else ...[
                                GridView(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: ResponsiveLayout.isTablet(context) ? 3 : 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 1,
                                  ),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: currentEmployeeBioDataList
                                      .map((bioData) {
                                    final displayBiodataLabel = bioData.biodataLabel.replaceAll("_", " ");
                                    final displayBiodataType = bioData.biodataType
                                        .replaceAll("_", " ")
                                        .replaceAll("FEATURE", "");

                                    return employeeBioDataCard(
                                      context, () async {
                                        showBioMetricDialog(
                                            context,
                                            isPalm: false,
                                            isFinger: true,
                                            palmToUpdate: null,
                                            onCancelled: () async {
                                              await _palmVeinService.closeDevice();
                                              _cancelToken?.cancel();
                                            },
                                            hintStream: _palmVeinService.onHint,
                                            enrollProgressStream: _palmVeinService.onCaptureProgress
                                        );

                                      if (bioData.biodataType == BioDataType.palm.code) {
                                        if (bioData.palmBioData != null) {
                                          await _capturePalm(
                                          context,
                                          employee.id,
                                          bioData.biodataType,
                                          biodataLabel: bioData.biodataLabel,
                                          provider,
                                          isUpdate: true,
                                          palmFeature: bioData.palmBioData?.palmFeature,
                                        );
                                        }
                                      } else
                                       if (bioData.biodataType == BioDataType.finger.code) {
                                        await _captureFinger(
                                            context,
                                            employee.id,
                                            provider,
                                            isUpdate: true
                                        );
                                      } else {
                                        /// enroll face
                                      }
                                    },
                                      isLeft: false,
                                      isUpdate: true,
                                      "$displayBiodataLabel\n($displayBiodataType)",
                                      getIconByBioDataType(bioData.biodataType),
                                    );
                                  }).toList(),
                                ),
                                if (currentEmployeeBioDataList.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Divider(
                                    height: 0.2,
                                    thickness: 0.4,
                                    indent: 20.0,
                                    endIndent: 20.0,
                                    color: Colors.grey.withAlpha(120),
                                  ),
                                  const SizedBox(height: 16),
                                ] else ...[
                                  Text(
                                    'No biodata found',
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: employeeBioDataCard(
                                          context,
                                              () { putState(() => _showAddBioDataForm = true); },
                                          "Add Bio Data",
                                          LucideIcons.plus,
                                        ),
                                      )
                                    ]
                                ),
                              ]
                              // const SizedBox(height: 16),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     employeeBioDataCard(
                              //       context,
                              //         () async {
                              //         showFingerDialog(context);
                              //         await _captureFingerPrint(
                              //           context,
                              //           employee.id,
                              //           BioDataType.fingerPrint.code,
                              //           BioDataLabel.leftIndex.code,
                              //           provider
                              //         );
                              //         },
                              //         "Left Index",
                              //         LucideIcons.fingerprint,
                              //     ),
                              //     employeeBioDataCard(
                              //       context,
                              //         () async {
                              //         showFingerDialog(context);
                              //         await _captureFingerPrint(
                              //           context,
                              //           employee.id,
                              //           BioDataType.fingerPrint.code,
                              //           BioDataLabel.rightIndex.code,
                              //           provider
                              //         );
                              //         },
                              //         "Right Index",
                              //         LucideIcons.fingerprint,
                              //     )
                              //   ]
                              // )
                            ],
                          ))
                    ]
                );
              }
          );
        }
    );
  }

  List<Widget> buildAddBioDataForm(
      GlobalKey key,
      BuildContext context,
      MembersProvider provider,
      {
        required Member employee,
        required Function(String?) onTypeSelected,
        required Function(String?) onLabelSelected,
        required Function onBackPressed
      }) {

    final filteredBioDataLabels = BioDataLabel.values.where((element) =>
    !provider.currentEmployeeBioDataList.map((e) => e.biodataLabel).contains(element.code)
        && !element.code.contains("HAND")).toList();

    return <Widget>[
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () {
            setState(() => _selectedBioDataType = null);
            setState(() => _selectedBioDataLabel = null);
            onBackPressed();
          },
          icon: const Icon(LucideIcons.arrowLeft),
          label: const Text("Back"),
        ),
      ),
      const SizedBox(height: 16),
      DropdownMenuFormField(
        onSelected: onTypeSelected,
        width: double.infinity,
        menuStyle: MenuStyle(
            maximumSize: WidgetStatePropertyAll(Size(600, 900))
        ),
        label: Text("Select Biodata Type"),
        hintText: "Select Biodata Type",
        dropdownMenuEntries: BioDataType.values.map((e) =>
            DropdownMenuEntry(
              value: e.code,
              label: e.name.replaceAll("_", " ").toUpperCase(),
              enabled: e == BioDataType.palm ? employee.faceRecognitionReference != null
                  : e == BioDataType.finger ? employee.fingerprintReference != null
                  : employee.faceRecognitionReference != null,
            )).toList(),
      ),
      const SizedBox(height: 16),
      if (_selectedBioDataType == BioDataType.finger.code) ...[
        DropdownMenuFormField(
          onSelected: onLabelSelected,
          width: double.infinity,
          menuStyle: MenuStyle(
              maximumSize: WidgetStatePropertyAll(Size(600, 900))
          ),
          label: Text("Select Biodata Label"),
          hintText: "Select Biodata Label",
          dropdownMenuEntries: filteredBioDataLabels.map((e) =>
              DropdownMenuEntry(value: e.code, label: e.code.replaceAll("_", " ").toUpperCase())).toList(),
        ),
        const SizedBox(height: 16),
      ],
      if (_selectedBioDataType != null) ...[
        Row(
          children: [
            Expanded(
              child: employeeBioDataCard(
                context,
                    () async {
                  if (_selectedBioDataType != BioDataType.face.code) {
                    showBioMetricDialog(
                        context,
                        isPalm: _selectedBioDataType == BioDataType.palm.code,
                        isFinger: _selectedBioDataType == BioDataType.finger.code,
                        onCancelled: () async {
                          await _palmVeinService.closeDevice();
                          _cancelToken?.cancel();
                        },
                        hintStream: _palmVeinService.onHint,
                        enrollProgressStream: _palmVeinService.onCaptureProgress
                    );
                  }
                  if (_selectedBioDataType == BioDataType.palm.code) {
                    await _capturePalm(
                        context,
                        employee.id,
                        _selectedBioDataType!,
                        provider,
                        isUpdate: false
                    );
                  } else if (_selectedBioDataType == BioDataType.finger.code) {
                    await _captureFinger(
                        context,
                        employee.id,
                        provider,
                        isUpdate: false
                    );
                  } else {
                    /// enroll face
                  }
                },
                "Enroll",
                getIconByBioDataType(_selectedBioDataType ?? ""),
              ),
            ),
          ],
        )
      ]
    ];
  }

  Widget employeeBioDataCard(
      BuildContext context,
      VoidCallback onTap,
      String label,
      IconData icon, { bool isUpdate = false , isLeft = false }
      ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
        onTap: onTap,
        child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 26.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                          backgroundColor: colorScheme.primary.withAlpha(20),
                          radius: ResponsiveLayout.isTablet(context) ? 44 : 34,
                          child: Transform.flip(
                            flipX: isLeft,
                            child: Icon(icon, color: colorScheme.primary,
                                size: ResponsiveLayout.isMobile(context) ? 34 : 54),
                          )
                      ),
                      if (isUpdate) ...[
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text('Update', style: textTheme.bodySmall?.copyWith(color: Colors.white)),
                          ),
                        )
                      ]
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(label,
                      textAlign: TextAlign.center,
                      style: ResponsiveLayout.isTablet(context) ? textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary
                      ) : textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary
                      )
                  ),
                ],
              ),
            )
        )
    );
  }

  IconData getIconByBioDataType(String bioDataType) {
    if (bioDataType == BioDataType.finger.code) {
      return LucideIcons.fingerprint;
    } else if (bioDataType == BioDataType.palm.code) {
      return LucideIcons.hand;
    } else if (bioDataType == BioDataType.face.code) {
      return LucideIcons.scanFace;
    } else {
      return LucideIcons.idCardLanyard;
    }
  }

  Widget buildEnrolledIndicator(IconData icon, Color color) {
    return CircleAvatar(
      backgroundColor: color.withAlpha(20),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }


  Widget _buildPageControls(MembersProvider provider) {
    final isTablet = ResponsiveLayout.isTablet(context);
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 5.0),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(80),
                width: 0.5,
              )
          )
      ),
      child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 8.0,
          children: [
            SizedBox(
              width: isTablet ? 280 : double.infinity,
              child: TextFormField(
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(LucideIcons.search),
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (e) async {
                  setState(() => _isFetching = true);
                  final res = await provider.queryMembers(filter: _searchController.text);
                  setState(() => _isFetching = false);
                  if (res != null) {
                    showSnack(text: res, context: mounted ? context : context, isError: true);
                  }
                },
                textInputAction: TextInputAction.search,
              ),
            ),
            if (isTablet) ...[
              const SizedBox(width: 8.0),
              SizedBox(
                width: isTablet ? 130 : 120,
                height: 56,
                child: ElevatedButton.icon(
                    onPressed: () async {
                      setState(() => _isFetching = true);
                      final res = await provider.queryMembers(filter: _searchController.text.trim());
                      setState(() => _isFetching = false);
                      if (res != null) {
                        showSnack(text: res, context: mounted ? context : context, isError: true);
                      }
                    },
                    icon: const Icon(
                      LucideIcons.search,
                      color: Colors.white,
                    ),
                    label: Text(
                      "Search",
                      style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: Colors.white
                      ),
                    )
                ),
              ),
              const SizedBox(width: 18.0),
            ],
            Text.rich(
              TextSpan(
                text: "Page ${provider.currentPage} of ${provider.totalPages}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(width: 18.0),
            TextButton.icon(
              onPressed: () async {
                if (provider.currentPage > 1) {
                  setState(() => _isFetching = true);
                  final res = await provider.queryMembers(page: provider.currentPage - 1,
                      filter: _searchController.text.trim());
                  setState(() => _isFetching = false);
                  if (res != null) {
                    showSnack(text: res, context: mounted ? context : context, isError: true);
                  }
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(20),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(LucideIcons.arrowLeft),
              label: const Text("Previous"),
            ),
            const SizedBox(width: 8.0),
            TextButton.icon(
              onPressed: () async {
                if (provider.currentPage < provider.totalPages) {
                  setState(() => _isFetching = true);
                  final res = await provider.queryMembers(page: provider.currentPage + 1,
                      filter: _searchController.text.trim());
                  setState(() => _isFetching = false);
                  if (res != null) {
                    showSnack(text: res, context: mounted ? context : context, isError: true);
                  }
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(20),
                visualDensity: VisualDensity.compact,
              ),
              label: const Text("Next"),
              icon: const Icon(LucideIcons.arrowRight),
              iconAlignment: IconAlignment.end,
            ),
          ]
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/user_controller.dart';
import '../../../core/enums/gender_type.dart';
import '../../../core/enums/profile_type.dart';
import '../../../core/enums/user_language_type.dart';
import '../../../shared/widgets/custom_section_card.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/auth_client.dart';
import '../../../core/enums/user_presence_status.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserController _userController = Get.find<UserController>();
  final _personalDetailsFormKey = GlobalKey<FormState>();

  // Personal Details Controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _nickNameController;
  late TextEditingController _mobileController;
  late TextEditingController _dobController;
  GenderType? _selectedGender;
  DateTime? _selectedDob;

  // Profile Type
  // Edit State
  bool _isEditingPersonalDetails = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final user = _userController.currentUser.value;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _nickNameController = TextEditingController(text: user?.nickName ?? '');
    _mobileController = TextEditingController(text: user?.mobile ?? '');
    _selectedGender = user?.gender;
    _selectedDob = user?.dob;
    _dobController = TextEditingController(
      text:
          user?.dob != null ? DateFormat('yyyy-MM-dd').format(user!.dob!) : '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _nickNameController.dispose();
    _mobileController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _savePersonalDetails() async {
    if (_personalDetailsFormKey.currentState!.validate()) {
      final updates = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'nickName': _nickNameController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'gender': _selectedGender?.value,
        'dob': _selectedDob?.toIso8601String(),
      };
      updates.removeWhere((key, value) => value == null);

      await _userController.updateUserDetails(updates);
      setState(() {
        _isEditingPersonalDetails = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile'
            .tr), // Using 'profile' translation key if available, else 'Profile'
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
            child: Obx(() {
              // Reactive rebuild when user data changes
              final user = _userController.currentUser.value;
              // We might need to sync controllers if external update happens, but for now init is once.
              // Actually, if save happens, user updates.

              return Column(
                children: [
                  // Profile Avatar Section
                  CustomSectionCard(
                    title: 'profile_photo'.tr,
                    isExpanded: true,
                    content: Center(
                      child: UserAvatar(
                        profileImageUrl: user?.profileImageMediaId != null
                            ? ApiEndpoints.makeProfileImageUrl(
                                user!.profileImageMediaId!,
                              )
                            : null,
                        authToken: Get.find<AuthClient>().accessToken.value,
                        initials: user?.initials ?? '?',
                        radius: 60,
                        backgroundColor: Colors.deepPurpleAccent,
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold),
                        status: UserPresenceStatus.available,
                        allowUpload: true,
                        userId: user?.id,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Personal Details Section

                  CustomSectionCard(
                    title: 'personal_info'.tr,
                    isExpanded: true, // Default expanded
                    headerAction: _isEditingPersonalDetails
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check,
                                    color: Colors.green),
                                onPressed: _savePersonalDetails,
                                tooltip: 'Save',
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _isEditingPersonalDetails = false;
                                    _initializeControllers(); // Reset to current user values
                                  });
                                },
                                tooltip: 'Cancel',
                              ),
                            ],
                          )
                        : IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              setState(() {
                                _isEditingPersonalDetails = true;
                              });
                            },
                            tooltip: 'Edit',
                          ),
                    content: _isEditingPersonalDetails
                        ? _buildPersonalDetailsEditForm()
                        : _buildPersonalDetailsView(user),
                  ),
                  const SizedBox(height: 16),

                  // Profile Type Section
                  CustomSectionCard(
                    title: 'profile_type'.tr,
                    content: _buildProfileTypeSelector(user?.profileType),
                  ),
                  const SizedBox(height: 16),

                  // App Language Section
                  CustomSectionCard(
                    title: 'app_language'.tr, // 'App Language'
                    content: _buildLanguageSelector(user?.userLanguage),
                  ),
                  const SizedBox(height: 16),

                  // Privacy Settings Section
                  CustomSectionCard(
                    title: 'privacy_settings'.tr,
                    content: const Text('Privacy settings coming soon...'),
                  ),
                  const SizedBox(height: 16),

                  // Notification Settings Section
                  CustomSectionCard(
                    title: 'notification_settings'.tr,
                    content: const Text('Notification settings coming soon...'),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // -- Personal Details Widgets --

  Widget _buildPersonalDetailsView(dynamic user) {
    // Typed as dynamic to avoid import issues but really UserModel
    return Column(
      children: [
        _buildViewRow('name_label'.tr,
            '${user?.firstName ?? ''} ${user?.lastName ?? ''}'),
        _buildViewRow('nickname'.tr, user?.nickName ?? ''),
        _buildViewRow('mobile_label'.tr, user?.mobile ?? ''),
        _buildViewRow('gender'.tr, user?.gender?.localizedName ?? 'N/A'),
        _buildViewRow(
            'date_of_birth'.tr,
            user?.dob != null
                ? DateFormat('yyyy-MM-dd').format(user!.dob!)
                : 'N/A'),
      ],
    );
  }

  Widget _buildViewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsEditForm() {
    return Form(
      key: _personalDetailsFormKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                      labelText: 'first_name'.tr,
                      border: const OutlineInputBorder()),
                  validator: (v) => v!.isEmpty
                      ? 'field_required'.tr
                      : null, // using 'remote_required' or similar
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                      labelText: 'last_name'.tr,
                      border: const OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'field_required'.tr : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nickNameController,
            decoration: InputDecoration(
                labelText: 'nickname'.tr,
                border: const OutlineInputBorder()), // Translate key later
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _mobileController,
            decoration: InputDecoration(
                labelText: 'mobile_number'.tr,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.phone)),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<GenderType>(
            value: _selectedGender,
            decoration: InputDecoration(
                labelText: 'gender'.tr, border: const OutlineInputBorder()),
            items: GenderType.values
                .map((type) => DropdownMenuItem(
                    value: type, child: Text(type.localizedName)))
                .toList(),
            onChanged: (val) => setState(() => _selectedGender = val),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _dobController,
            readOnly: true,
            onTap: () => _selectDate(context),
            decoration: InputDecoration(
                labelText: 'date_of_birth'.tr,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.calendar_today)),
          ),
        ],
      ),
    );
  }

  // -- Profile Type Widgets --

  Widget _buildProfileTypeSelector(ProfileType? currentType) {
    return DropdownButtonFormField<ProfileType>(
      value: currentType ?? ProfileType.public,
      decoration: InputDecoration(
        labelText: 'profile_visibility'.tr,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.lock_outline),
      ),
      items: ProfileType.values
          .map((type) => DropdownMenuItem(value: type, child: Text(type.value)))
          .toList(),
      onChanged: (val) {
        if (val != null && val != currentType) {
          _userController.updateUserDetails({'profileType': val.value});
        }
      },
    );
  }

  // -- Language Widgets --

  Widget _buildLanguageSelector(UserLanguageType? currentLanguage) {
    return DropdownButtonFormField<UserLanguageType>(
      value: currentLanguage ?? UserLanguageType.english,
      decoration: const InputDecoration(
        labelText: 'Language',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.language),
      ),
      items: UserLanguageType.values
          .map((type) => DropdownMenuItem(
              value: type, child: Text('${type.nativeName} (${type.value})')))
          .toList(),
      onChanged: (val) {
        if (val != null) {
          _userController.updateUserLanguage(val);
        }
      },
    );
  }
}

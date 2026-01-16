import 'package:get/get.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_view.dart';
import '../modules/auth/sign_in/sign_in_binding.dart';
import '../modules/auth/sign_in/sign_in_view.dart';
import '../modules/auth/sign_up/sign_up_binding.dart';
import '../modules/auth/sign_up/sign_up_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/chat/chat_binding.dart';
import '../modules/chat/chat_view.dart';
import '../modules/contacts/contacts_binding.dart';
import '../modules/contacts/contacts_view.dart';
import '../modules/group/create_group/create_group_binding.dart';
import '../modules/group/create_group/create_group_view.dart';
import '../modules/calls/calls_binding.dart';
import '../modules/calls/calls_view.dart';
import '../modules/settings/settings_binding.dart';
import '../modules/settings/settings_view.dart';
import '../modules/profile/profile_binding.dart';
import '../modules/profile/profile_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    // Onboarding removed - navigating directly to Sign In
    GetPage(
      name: AppRoutes.signIn,
      page: () => const SignInView(),
      binding: SignInBinding(),
    ),
    GetPage(
      name: AppRoutes.signUp,
      page: () => const SignUpView(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.contacts,
      page: () => const ContactsView(),
      binding: ContactsBinding(),
    ),
    GetPage(
      name: AppRoutes.createGroup,
      page: () => const CreateGroupView(),
      binding: CreateGroupBinding(),
    ),
    GetPage(
      name: AppRoutes.calls,
      page: () => const CallsView(),
      binding: CallsBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
  ];
}

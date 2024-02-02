import 'package:adopt_animal/features/auth/presentation/pages/signIn_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/app_theme.dart';
import '../../../../core/const/page_const.dart';
import '../cubit/profile_cubit.dart';
import 'package:flutter/cupertino.dart';
import '/injection.dart' as di;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext _) {
    return BlocProvider(
      create: (_) => di.sl<ProfileCubit>(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        builder: (profileContext, credentialState) {
          if (credentialState.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.35,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment(0.5, 1),
                        colors: <Color>[
                          roseFog,
                          rockBlue,
                        ],
                        tileMode: TileMode.mirror,
                      ),
                      color: rockBlue,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: careysPink.withOpacity(0.5),
                          width: 5.0, // Adjust the border width as needed
                        ),
                      ),
                    ),
                    child: const Center(
                        child: Text(
                      "Embrace compassion. Welcome a new family member through adoption.",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontFamily: "DancingScript"),
                      textAlign: TextAlign.center,
                    )),
                  ),
                  // Menu...
                  Container(
                    padding: const EdgeInsets.only(top: 50),
                    //   color: Colors.white,
                    child: Column(
                      children: [
                        for (var item in menuClubItems)
                          MenuRow(
                            iconAsset: item.iconAsset,
                            text: item.title,
                            onTap: () async {
                              item.title == "Logout"
                                  ? showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        title: const Text(
                                          'Logout',
                                          textAlign: TextAlign.center,
                                        ),
                                        content: const Text(
                                          'Are you sure you want to logout ?',
                                          textAlign: TextAlign.center,
                                        ),
                                        actions: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 8),
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15)),
                                              color: careysPink,
                                            ),
                                            child: TextButton(
                                              onPressed: () => Navigator.pop(
                                                  context, 'Cancel'),
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 8),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(15)),
                                                color: Colors.transparent,
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.grey)),
                                            child: TextButton(
                                              onPressed: () {
                                               BlocProvider.of<ProfileCubit>(profileContext).loggedOut();
                                               Navigator.pushReplacementNamed(context, PageConst.loginPage);
                                              },
                                              child: const Text(
                                                'Yes',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                      return item.route;
                                    }));
                            },
                            color: item.color,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: MediaQuery.of(context).size.width * 0.5,
                left: MediaQuery.of(context).size.width *
                    0.3, // Centered horizontally
                child: Container(
                  // width: 150,
                  // height: 150,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: careysPink.withOpacity(0.5),
                      width: 5.0, // Adjust the border width as needed
                    ),
                  ),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: SvgPicture.asset(
                      'assets/user.svg',
                      width: 15,
                      height: 15,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        listener: (context, credentialState) {
          if (credentialState.successLogout) {
            print("dggdgdfgdfgdfgdfg");
            //

          }
        },
      ),
    );
  }

  final List<MenuItem> menuClubItems = [
    MenuItem("Settings", 'assets/settings.svg', Text(""), careysPink),
    MenuItem("Password", 'assets/password.svg', Text(""), roseFog),
    MenuItem("Contact Us", 'assets/contact_us.svg', Text(""), rockBlue),
    MenuItem("Logout", 'assets/logout.svg', Text(""), bermudaGray),
  ];
}

class MenuItem {
  final String title;
  final String iconAsset; // Asset path for the icon
  final Widget route;
  final Color color;

  // Route to navigate to when the menu item is selected

  MenuItem(this.title, this.iconAsset, this.route, this.color);
}

class MenuRow extends StatelessWidget {
  final String iconAsset;
  final String text;
  final Color color;
  final void Function() onTap;

  MenuRow({
    required this.iconAsset,
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          children: [
            // Icon and Text...
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  child: SvgPicture.asset(
                    iconAsset,
                    width: 25,
                    height: 25,
                    color: color,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontFamily: "Exo2",
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Icon...
            SvgPicture.asset(
              'assets/right-arrow.svg',
              width: 15,
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}

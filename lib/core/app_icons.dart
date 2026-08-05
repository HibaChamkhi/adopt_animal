import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Asset paths for the SVG icons in assets/icons/.
class AppIcons {
  static const _b = 'assets/icons/';
  static const add = '${_b}add.svg';
  static const addPhoto = '${_b}add_a_photo.svg';
  static const arrowBack = '${_b}arrow_back.svg';
  static const call = '${_b}call.svg';
  static const chat = '${_b}chat_bubble.svg';
  static const check = '${_b}check.svg';
  static const chevronRight = '${_b}chevron_right.svg';
  static const close = '${_b}close.svg';
  static const creditCard = '${_b}credit_card.svg';
  static const delete = '${_b}delete.svg';
  static const edit = '${_b}edit.svg';
  static const event = '${_b}event.svg';
  static const expandMore = '${_b}expand_more.svg';
  static const favorite = '${_b}favorite.svg';
  static const home = '${_b}home.svg';
  static const hourglass = '${_b}hourglass_top.svg';
  static const shipping = '${_b}local_shipping.svg';
  static const location = '${_b}location_on.svg';
  static const mail = '${_b}mail.svg';
  static const notifications = '${_b}notifications.svg';
  static const payments = '${_b}payments.svg';
  static const person = '${_b}person.svg';
  static const pets = '${_b}pets.svg';
  static const remove = '${_b}remove.svg';
  static const replay = '${_b}replay.svg';
  static const schedule = '${_b}schedule.svg';
  static const search = '${_b}search.svg';
  static const send = '${_b}send.svg';
  static const cart = '${_b}shopping_cart.svg';
  static const star = '${_b}star.svg';
  static const stethoscope = '${_b}stethoscope.svg';
  static const storefront = '${_b}storefront.svg';
  static const tune = '${_b}tune.svg';
  static const verified = '${_b}verified.svg';
  static const visibility = '${_b}visibility.svg';
}

/// Renders an SVG icon with an optional color/size override.
class AppIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Color? color;

  const AppIcon(this.asset, {super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter:
          color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
    );
  }
}

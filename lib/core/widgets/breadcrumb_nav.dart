import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BreadcrumbNav extends StatelessWidget {
  final List<String> pathNames;

  const BreadcrumbNav({Key? key, required this.pathNames}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (pathNames.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.transparent,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: pathNames.length,
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(
            Icons.chevron_left_rounded, // Chevron left because RTL
            color: Colors.grey.shade400,
            size: 20,
          ),
        ),
        itemBuilder: (context, index) {
          final isLast = index == pathNames.length - 1;
          return Center(
            child: Text(
              pathNames[index],
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
                color: isLast
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade500,
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colour tokens of the Claim Check design system. Found items use the
/// orange tag, lost reports use the blue ticket, and every status colour is
/// paired with a word.
@immutable
class DeskColors extends ThemeExtension<DeskColors> {
  const DeskColors({
    required this.paper,
    required this.surface,
    required this.surface2,
    required this.line,
    required this.lineStrong,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.inkOn,
    required this.tag,
    required this.tagOn,
    required this.tagInk,
    required this.tag50,
    required this.ticket,
    required this.ticketOn,
    required this.ticket50,
    required this.ok,
    required this.ok50,
    required this.warn,
    required this.warn50,
    required this.bad,
    required this.bad50,
    required this.switchOff,
  });

  final Color paper, surface, surface2, line, lineStrong;
  final Color ink, ink2, ink3, inkOn;
  final Color tag, tagOn, tagInk, tag50;
  final Color ticket, ticketOn, ticket50;
  final Color ok, ok50, warn, warn50, bad, bad50;
  final Color switchOff;

  static const light = DeskColors(
    paper: Color(0xFFF2F1ED),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFE9E8E3),
    line: Color(0xFFD8D6CF),
    lineStrong: Color(0xFFBDBAB1),
    ink: Color(0xFF16181B),
    ink2: Color(0xFF454950),
    ink3: Color(0xFF5E636B),
    inkOn: Color(0xFFFFFFFF),
    tag: Color(0xFFF0A13E),
    tagOn: Color(0xFF16181B),
    tagInk: Color(0xFF8A4405),
    tag50: Color(0xFFFCEBD3),
    ticket: Color(0xFF2346B8),
    ticketOn: Color(0xFFFFFFFF),
    ticket50: Color(0xFFE5EAFA),
    ok: Color(0xFF1B6E44),
    ok50: Color(0xFFDEF0E5),
    warn: Color(0xFF835400),
    warn50: Color(0xFFFAEDCF),
    bad: Color(0xFFAD2A21),
    bad50: Color(0xFFFAE1DE),
    switchOff: Color(0xFFC9C7BF),
  );

  static const dark = DeskColors(
    paper: Color(0xFF121315),
    surface: Color(0xFF1B1D20),
    surface2: Color(0xFF26292D),
    line: Color(0xFF383C42),
    lineStrong: Color(0xFF4A4E55),
    ink: Color(0xFFEDEDEA),
    ink2: Color(0xFFBDC0C5),
    ink3: Color(0xFF9A9EA5),
    inkOn: Color(0xFF16181B),
    tag: Color(0xFFF0A13E),
    tagOn: Color(0xFF16181B),
    tagInk: Color(0xFFF6B865),
    tag50: Color(0xFF3A2B16),
    ticket: Color(0xFF8EA6FF),
    ticketOn: Color(0xFF0E1631),
    ticket50: Color(0xFF1F2747),
    ok: Color(0xFF6BCB93),
    ok50: Color(0xFF17301F),
    warn: Color(0xFFE9B44F),
    warn50: Color(0xFF33280F),
    bad: Color(0xFFFF8F85),
    bad50: Color(0xFF3B1A18),
    switchOff: Color(0xFF4A4E55),
  );

  static DeskColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<DeskColors>() ??
        (theme.brightness == Brightness.dark ? dark : light);
  }

  @override
  DeskColors copyWith() => this;

  @override
  DeskColors lerp(ThemeExtension<DeskColors>? other, double t) {
    if (other is! DeskColors) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return DeskColors(
      paper: mix(paper, other.paper),
      surface: mix(surface, other.surface),
      surface2: mix(surface2, other.surface2),
      line: mix(line, other.line),
      lineStrong: mix(lineStrong, other.lineStrong),
      ink: mix(ink, other.ink),
      ink2: mix(ink2, other.ink2),
      ink3: mix(ink3, other.ink3),
      inkOn: mix(inkOn, other.inkOn),
      tag: mix(tag, other.tag),
      tagOn: mix(tagOn, other.tagOn),
      tagInk: mix(tagInk, other.tagInk),
      tag50: mix(tag50, other.tag50),
      ticket: mix(ticket, other.ticket),
      ticketOn: mix(ticketOn, other.ticketOn),
      ticket50: mix(ticket50, other.ticket50),
      ok: mix(ok, other.ok),
      ok50: mix(ok50, other.ok50),
      warn: mix(warn, other.warn),
      warn50: mix(warn50, other.warn50),
      bad: mix(bad, other.bad),
      bad50: mix(bad50, other.bad50),
      switchOff: mix(switchOff, other.switchOff),
    );
  }
}

/// Typefaces of the design system: Bricolage Grotesque for display and
/// headings, Instrument Sans for reading and controls, and JetBrains Mono for
/// every reference code and score.
@immutable
class DeskType extends ThemeExtension<DeskType> {
  const DeskType({
    required this.display,
    required this.heading,
    required this.body,
    required this.strong,
    required this.mono,
  });

  /// Bricolage Grotesque 800.
  final TextStyle display;

  /// Bricolage Grotesque 700.
  final TextStyle heading;

  /// Instrument Sans 400.
  final TextStyle body;

  /// Instrument Sans 600.
  final TextStyle strong;

  /// JetBrains Mono 700.
  final TextStyle mono;

  /// Used when no desk theme is installed, for example in widget tests.
  static const fallback = DeskType(
    display: TextStyle(fontWeight: FontWeight.w800),
    heading: TextStyle(fontWeight: FontWeight.w700),
    body: TextStyle(fontWeight: FontWeight.w400),
    strong: TextStyle(fontWeight: FontWeight.w600),
    mono: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700),
  );

  static DeskType of(BuildContext context) =>
      Theme.of(context).extension<DeskType>() ?? fallback;

  TextStyle displayAt(double size) => display.copyWith(
    fontSize: size,
    height: 1.02,
    letterSpacing: -.02 * size,
  );

  TextStyle headingAt(double size, {double height = 1.18}) => heading.copyWith(
    fontSize: size,
    height: height,
    letterSpacing: -.02 * size,
  );

  TextStyle codeAt(double size) =>
      mono.copyWith(fontSize: size, letterSpacing: .06 * size, height: 1);

  TextStyle get label => strong.copyWith(
    fontSize: 11.5,
    letterSpacing: .92,
    height: 1.25,
  );

  TextStyle get small => body.copyWith(fontSize: 12.5, height: 1.44);

  @override
  DeskType copyWith() => this;

  @override
  DeskType lerp(ThemeExtension<DeskType>? other, double t) =>
      other is DeskType && t >= .5 ? other : this;
}

extension DeskContext on BuildContext {
  DeskColors get desk => DeskColors.of(this);
  DeskType get type => DeskType.of(this);
}

/// The app theme. Tests pass [DeskType.fallback] as [fonts], because the
/// brand fonts are fetched over the network.
ThemeData buildDeskTheme(Brightness brightness, {DeskType? fonts}) {
  final c = brightness == Brightness.dark ? DeskColors.dark : DeskColors.light;
  final type =
      fonts ??
      DeskType(
        display: GoogleFonts.bricolageGrotesque(fontWeight: FontWeight.w800),
        heading: GoogleFonts.bricolageGrotesque(fontWeight: FontWeight.w700),
        body: GoogleFonts.instrumentSans(fontWeight: FontWeight.w400),
        strong: GoogleFonts.instrumentSans(fontWeight: FontWeight.w600),
        mono: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700),
      );
  final scheme = ColorScheme(
    brightness: brightness,
    primary: c.ink,
    onPrimary: c.inkOn,
    primaryContainer: c.tag50,
    onPrimaryContainer: c.tagInk,
    secondary: c.tag,
    onSecondary: c.tagOn,
    secondaryContainer: c.tag50,
    onSecondaryContainer: c.tagInk,
    tertiary: c.ticket,
    onTertiary: c.ticketOn,
    tertiaryContainer: c.ticket50,
    onTertiaryContainer: c.ticket,
    error: c.bad,
    onError: c.inkOn,
    errorContainer: c.bad50,
    onErrorContainer: c.bad,
    surface: c.surface,
    onSurface: c.ink,
    onSurfaceVariant: c.ink2,
    surfaceDim: c.surface2,
    surfaceBright: c.surface,
    surfaceContainerLowest: c.surface,
    surfaceContainerLow: c.surface,
    surfaceContainer: c.surface,
    surfaceContainerHigh: c.surface,
    surfaceContainerHighest: c.surface2,
    outline: c.line,
    outlineVariant: c.line,
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
    inverseSurface: c.ink,
    onInverseSurface: c.inkOn,
    inversePrimary: c.tag,
    surfaceTint: const Color(0x00000000),
  );
  TextStyle sans(
    double size,
    FontWeight weight, {
    double? height,
    Color? color,
  }) => (weight == FontWeight.w600 ? type.strong : type.body).copyWith(
    fontSize: size,
    height: height == null ? null : height / size,
    color: color ?? c.ink,
  );
  TextStyle head(double size, FontWeight weight, double height) =>
      (weight == FontWeight.w800 ? type.display : type.heading).copyWith(
        fontSize: size,
        height: height / size,
        letterSpacing: -.02 * size,
        color: c.ink,
      );
  final text = TextTheme(
    displayLarge: head(46, FontWeight.w800, 46),
    displayMedium: head(40, FontWeight.w800, 41),
    displaySmall: head(34, FontWeight.w800, 35),
    headlineLarge: head(32, FontWeight.w800, 34),
    headlineMedium: head(30, FontWeight.w700, 33),
    headlineSmall: head(24, FontWeight.w700, 28),
    titleLarge: head(19, FontWeight.w700, 24),
    titleMedium: sans(16, FontWeight.w600, height: 22),
    titleSmall: sans(14, FontWeight.w600, height: 20),
    bodyLarge: sans(16, FontWeight.w400, height: 24),
    bodyMedium: sans(15, FontWeight.w400, height: 22),
    bodySmall: sans(12.5, FontWeight.w400, height: 18, color: c.ink3),
    labelLarge: sans(15, FontWeight.w600),
    labelMedium: sans(13, FontWeight.w600),
    labelSmall: sans(11.5, FontWeight.w600),
  );
  final controlShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  );
  OutlineInputBorder field(Color colour, [double width = 1.5]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colour, width: width),
      );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    textTheme: text,
    extensions: [c, type],
    scaffoldBackgroundColor: c.paper,
    canvasColor: c.paper,
    dividerColor: c.line,
    splashFactory: InkSparkle.splashFactory,
    visualDensity: VisualDensity.standard,
    appBarTheme: AppBarTheme(
      backgroundColor: c.paper,
      foregroundColor: c.ink,
      surfaceTintColor: const Color(0x00000000),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 4,
      titleTextStyle: head(17, FontWeight.w700, 22),
    ),
    cardTheme: CardThemeData(
      color: c.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: c.line),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: c.ink,
        foregroundColor: c.inkOn,
        disabledBackgroundColor: c.surface2,
        disabledForegroundColor: c.ink3,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        shape: controlShape,
        textStyle: sans(15, FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: c.surface,
        foregroundColor: c.ink,
        disabledForegroundColor: c.ink3,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        side: BorderSide(color: c.line, width: 1.5),
        shape: controlShape,
        textStyle: sans(15, FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: c.ink,
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: sans(14.5, FontWeight.w600),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: c.ink,
        minimumSize: const Size(44, 44),
        shape: controlShape,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: c.tag,
      foregroundColor: c.tagOn,
      elevation: 6,
      highlightElevation: 8,
      extendedTextStyle: sans(15, FontWeight.w600, color: c.tagOn),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: sans(15, FontWeight.w400, color: c.ink3),
      labelStyle: sans(15, FontWeight.w400, color: c.ink2),
      floatingLabelStyle: sans(14, FontWeight.w600, color: c.ink),
      helperStyle: sans(12.5, FontWeight.w400, color: c.ink3),
      errorStyle: sans(12.5, FontWeight.w600, color: c.bad),
      prefixIconColor: c.ink3,
      suffixIconColor: c.ink3,
      border: field(c.line),
      enabledBorder: field(c.line),
      disabledBorder: field(c.line.withValues(alpha: .6)),
      focusedBorder: field(c.ink, 2),
      errorBorder: field(c.bad),
      focusedErrorBorder: field(c.bad, 2),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: c.surface,
      selectedColor: c.ink,
      disabledColor: c.surface2,
      checkmarkColor: c.inkOn,
      showCheckmark: false,
      labelStyle: sans(13.5, FontWeight.w600, color: c.ink2),
      secondaryLabelStyle: sans(13.5, FontWeight.w600, color: c.inkOn),
      side: BorderSide(color: c.line, width: 1.5),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      color: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? c.ink
            : states.contains(WidgetState.disabled)
            ? c.surface2
            : c.surface,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: const Color(0x00000000),
      indicatorColor: c.tag50,
      elevation: 0,
      height: 76,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => sans(
          12,
          FontWeight.w600,
          color: states.contains(WidgetState.selected) ? c.ink : c.ink3,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 22,
          color: states.contains(WidgetState.selected) ? c.ink : c.ink3,
        ),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: const Color(0x00000000),
      modalBackgroundColor: c.surface,
      showDragHandle: true,
      dragHandleColor: c.lineStrong,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: const BoxConstraints(maxWidth: 640),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: const Color(0x00000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: head(21, FontWeight.w700, 26),
      contentTextStyle: sans(15, FontWeight.w400, height: 22, color: c.ink2),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: c.ink,
      contentTextStyle: sans(14.5, FontWeight.w400, color: c.inkOn),
      actionTextColor: c.tag,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: c.surface,
      surfaceTintColor: const Color(0x00000000),
      elevation: 6,
      textStyle: sans(15, FontWeight.w400),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: c.line),
      ),
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(c.surface),
        surfaceTintColor: const WidgetStatePropertyAll(Color(0x00000000)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: c.line),
          ),
        ),
      ),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: sans(15, FontWeight.w400),
    ),
    dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
    listTileTheme: ListTileThemeData(
      iconColor: c.ink2,
      textColor: c.ink,
      titleTextStyle: sans(15, FontWeight.w600),
      subtitleTextStyle: sans(13, FontWeight.w400, color: c.ink3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(Color(0xFFFFFFFF)),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? c.ok : c.switchOff,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Color(0x00000000)),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? c.ink : c.surface,
      ),
      checkColor: WidgetStatePropertyAll(c.inkOn),
      side: BorderSide(color: c.ink3, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    radioTheme: RadioThemeData(fillColor: WidgetStatePropertyAll(c.ink)),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: c.ink,
      linearTrackColor: c.surface2,
      circularTrackColor: const Color(0x00000000),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: c.ink,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: sans(12.5, FontWeight.w600, color: c.inkOn),
    ),
    badgeTheme: BadgeThemeData(
      backgroundColor: c.bad,
      textColor: const Color(0xFFFFFFFF),
      textStyle: sans(11, FontWeight.w600, color: const Color(0xFFFFFFFF)),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      shape: const Border(),
      collapsedShape: const Border(),
      iconColor: c.ink,
      collapsedIconColor: c.ink,
      textColor: c.ink,
      collapsedTextColor: c.ink,
      tilePadding: EdgeInsets.zero,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: c.ink,
      selectionColor: c.tag.withValues(alpha: .35),
      selectionHandleColor: c.tag,
    ),
    bannerTheme: MaterialBannerThemeData(
      backgroundColor: c.warn50,
      contentTextStyle: sans(14, FontWeight.w400),
    ),
  );
}

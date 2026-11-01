import 'package:material_ui/material_ui.dart';

import '../../design/tokens.dart';

/// Ilova illyustratsiyalari (assets/images/illus, docs/ILLUSTRATIONS.md):
/// bezak uchun — matn, raqam, brend yo'q; apparat rasmlari aniq model emas.
enum LgArt {
  secPreanalytics('sec_preanalytics'),
  secInstruments('sec_instruments'),
  secQc('sec_qc'),
  secCalculators('sec_calculators'),
  secMicroscopy('sec_microscopy'),
  secLearn('sec_learn'),
  proStudent('pro_student'),
  proTeacher('pro_teacher'),
  proSpecialist('pro_specialist'),
  proPremium('pro_premium'),
  instBiochem('inst_biochem_analyzer'),
  instHematology('inst_hematology_analyzer'),
  instCoagulometer('inst_coagulometer'),
  instElisa('inst_elisa_reader'),
  instPcr('inst_pcr_cycler'),
  instCentrifuge('inst_centrifuge'),
  instOsmometer('inst_osmometer'),
  instHplc('inst_hplc'),
  instGcms('inst_gcms'),
  instMicroscope('inst_microscope');

  const LgArt(this.file);

  final String file;

  String get asset => 'assets/images/illus/$file.webp';

  /// Apparat sxemasi kaliti -> umumiy (brendsiz) muqova illyustratsiyasi.
  /// Sxema (raqamli qismlari bilan) o'z joyida qoladi; muqova faqat ustida.
  static LgArt? forSchematicKey(String key) => switch (key) {
    'chemistry' => instBiochem,
    'hematology3' || 'hematology5' => instHematology,
    'coag_analyzer' => instCoagulometer,
    'elisa_reader' => instElisa,
    'real_time_pcr' => instPcr,
    'osmometer' => instOsmometer,
    'mass_spec_gc' => instGcms,
    _ => null,
  };

  /// `assets/instruments/schematic/<key>_480.png` -> kalit.
  static LgArt? forSchematicAsset(String asset) {
    final m = RegExp(r'/([a-z0-9_]+?)_(?:480|1200)\.png$').firstMatch(asset);
    return m == null ? null : forSchematicKey(m.group(1)!);
  }
}

/// Illyustratsiya: yumaloq burchakli krem fon ustida (tungi rejimda ham
/// shu krem karta — rasm foni bilan bir xil). Bezak: ekran o'quvchi o'qimaydi.
/// Rasm yuklanmasa — hech narsa ko'rsatilmaydi (joy egallamaydi).
class LgArtImage extends StatelessWidget {
  const LgArtImage(
    this.art, {
    super.key,
    required this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.padding = const EdgeInsets.only(bottom: 12),
  });

  /// Bo'lim sarlavhasi: keng, past banner (rasmning o'ng yarmi — buyumlar).
  const LgArtImage.banner(this.art, {super.key})
    : height = 128,
      fit = BoxFit.cover,
      alignment = Alignment.centerRight,
      padding = const EdgeInsets.only(bottom: 12);

  static const background = Color(0xFFF3F3EC);

  final LgArt art;
  final double height;
  final BoxFit fit;
  final Alignment alignment;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Padding(
        padding: padding,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(LgRadius.card),
          child: ColoredBox(
            color: background,
            child: SizedBox(
              height: height,
              width: double.infinity,
              child: Image.asset(
                art.asset,
                fit: fit,
                alignment: alignment,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

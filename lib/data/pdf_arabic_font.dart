import 'dart:convert';
import 'package:pdf_text_shaper/pdf_text_shaper.dart';
import 'noto_naskh_arabic_font.dart';

ShapedFont loadArabicPdfFont() => ShapedFont.fromBytes(
  base64Decode(notoNaskhArabicBase64),
  name: 'Noto Naskh Arabic',
);

ShapedText arabicPdfText(
  String value,
  ShapedFont font, {
  double size = 11,
  bool bold = false,
}) => ShapedText(
  value,
  style: ShapedTextStyle(
    font: font,
    fontSize: size,
    direction: AnyPdfTextDirection.rightToLeft,
    align: AnyPdfTextAlign.end,
  ),
);

import 'dart:typed_data';
import 'dart:ui';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:printing/printing.dart';

class RegistrationPdfGenerator {
  static Future<void> generateAndPrintPdf({
    required String nom,
    required String prenom,
    required String tel,
    required String email,
    required String cni,
    required String dateNaiss,
    required String lieuNaiss,
    required String nationalite,
    required String categorie,
    Uint8List? cniBytes,
    Uint8List? photoBytes,
    Uint8List? certificatBytes,
  }) async {
    final PdfDocument document = PdfDocument();
    
    // Format A4
    document.pageSettings.size = PdfPageSize.a4;
    document.pageSettings.margins.all = 40;
    
    final PdfPage page = document.pages.add();
    final double width = page.getClientSize().width; // ~515
    final double height = page.getClientSize().height; // ~762

    // Fonts
    final PdfFont fontTitle = PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold);
    final PdfFont fontSubTitle = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.italic);
    final PdfFont fontHeaderTop = PdfStandardFont(PdfFontFamily.helvetica, 7, style: PdfFontStyle.bold);
    final PdfFont fontHeaderTopItalic = PdfStandardFont(PdfFontFamily.helvetica, 7, style: PdfFontStyle.italic);
    final PdfFont fontSection = PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold);
    final PdfFont fontLabel = PdfStandardFont(PdfFontFamily.helvetica, 7, style: PdfFontStyle.bold);
    final PdfFont fontValue = PdfStandardFont(PdfFontFamily.helvetica, 11);
    final PdfFont fontFooter = PdfStandardFont(PdfFontFamily.helvetica, 6);
    final PdfFont fontBox = PdfStandardFont(PdfFontFamily.helvetica, 7, style: PdfFontStyle.bold);

    final PdfColor colorLightGrey = PdfColor(220, 220, 220);
    final PdfColor colorDarkGrey = PdfColor(100, 100, 100);
    final PdfPen linePen = PdfPen(colorLightGrey, width: 1);

    int y = 0;

    // --- HEADER ---
    page.graphics.drawString('RÉPUBLIQUE DU CAMEROUN', fontHeaderTop, bounds: Rect.fromLTWH(0, y.toDouble(), 200, 10), format: PdfStringFormat(alignment: PdfTextAlignment.center));
    page.graphics.drawString('Paix - Travail - Patrie', fontHeaderTopItalic, bounds: Rect.fromLTWH(0, y + 10.0, 200, 10), format: PdfStringFormat(alignment: PdfTextAlignment.center));
    page.graphics.drawString('MINISTÈRE DES TRANSPORTS', fontHeaderTop, bounds: Rect.fromLTWH(0, y + 25.0, 200, 10), format: PdfStringFormat(alignment: PdfTextAlignment.center));

    page.graphics.drawString('REPUBLIC OF CAMEROON', fontHeaderTop, bounds: Rect.fromLTWH(width - 200, y.toDouble(), 200, 10), format: PdfStringFormat(alignment: PdfTextAlignment.center));
    page.graphics.drawString('Peace - Work - Fatherland', fontHeaderTopItalic, bounds: Rect.fromLTWH(width - 200, y + 10.0, 200, 10), format: PdfStringFormat(alignment: PdfTextAlignment.center));
    page.graphics.drawString('MINISTRY OF TRANSPORT', fontHeaderTop, bounds: Rect.fromLTWH(width - 200, y + 25.0, 200, 10), format: PdfStringFormat(alignment: PdfTextAlignment.center));

    // Cadre Réservé Center
    page.graphics.drawRectangle(pen: PdfPen(PdfColor(0, 0, 0), width: 1), bounds: Rect.fromLTWH((width / 2) - 40, y + 25.0, 80, 25));
    page.graphics.drawString('CADRE RÉSERVÉ', fontHeaderTop, bounds: Rect.fromLTWH((width / 2) - 40, y + 28.0, 80, 10), format: PdfStringFormat(alignment: PdfTextAlignment.center));
    page.graphics.drawString('N° .................', fontHeaderTop, bounds: Rect.fromLTWH((width / 2) - 40, y + 38.0, 80, 10), format: PdfStringFormat(alignment: PdfTextAlignment.center));

    y += 80;

    // --- MAIN TITLE ---
    page.graphics.drawString('FORMULAIRE DE DEMANDE DE PERMIS DE CONDUIRE', fontTitle, bounds: Rect.fromLTWH(0, y.toDouble(), width, 20), format: PdfStringFormat(alignment: PdfTextAlignment.center));
    y += 20;
    page.graphics.drawString('Driving License Application Form', fontSubTitle, bounds: Rect.fromLTWH(0, y.toDouble(), width, 15), format: PdfStringFormat(alignment: PdfTextAlignment.center), brush: PdfSolidBrush(colorDarkGrey));
    y += 25;
    page.graphics.drawLine(PdfPen(PdfColor(50, 50, 50), width: 2), Offset((width / 2) - 25, y.toDouble()), Offset((width / 2) + 25, y.toDouble()));
    
    y += 40;

    // --- SECTION I ---
    page.graphics.drawString('I. INFORMATIONS DU DEMANDEUR', fontSection, bounds: Rect.fromLTWH(0, y.toDouble(), width, 15));
    page.graphics.drawString(' / APPLICANT INFO', fontSection, bounds: Rect.fromLTWH(185, y.toDouble(), width, 15), brush: PdfSolidBrush(colorLightGrey));
    y += 20;
    page.graphics.drawLine(linePen, Offset(0, y.toDouble()), Offset(width, y.toDouble()));
    y += 15;

    void drawField(String label, String value, double x, double fieldWidth, {bool isBottomLine = true}) {
      page.graphics.drawString(label, fontLabel, bounds: Rect.fromLTWH(x, y.toDouble(), fieldWidth, 10), brush: PdfSolidBrush(colorDarkGrey));
      page.graphics.drawString(value.isEmpty ? ' ' : value, fontValue, bounds: Rect.fromLTWH(x, y + 12.0, fieldWidth, 15), brush: PdfSolidBrush(value.isEmpty ? colorLightGrey : PdfColor(0,0,0)));
      if (isBottomLine) {
        page.graphics.drawLine(linePen, Offset(x, y + 30.0), Offset(x + fieldWidth, y + 30.0));
      }
    }

    // Row 1
    drawField('NOM DE FAMILLE / SURNAME', nom.toUpperCase(), 0, (width / 2) - 10);
    drawField('PRÉNOM(S) / GIVEN NAMES', prenom, (width / 2) + 10, (width / 2) - 10);
    y += 45;

    // Row 2
    drawField('DATE DE NAISSANCE / DOB', dateNaiss, 0, (width / 3) - 10);
    drawField('LIEU DE NAISSANCE / PLACE OF BIRTH', lieuNaiss, (width / 3), (width / 3) - 10);
    drawField('NATIONALITÉ / NATIONALITY', nationalite, (2 * width / 3), (width / 3));
    y += 45;

    // Row 3
    drawField('NUMÉRO DE CNI / NATIONAL ID NUMBER', cni, 0, (width / 2) - 10);
    
    // Catégorie Checkboxes
    double catX = (width / 2) + 10;
    page.graphics.drawString('CATÉGORIE DEMANDÉE / CATEGORY', fontLabel, bounds: Rect.fromLTWH(catX, y.toDouble(), (width / 2) - 10, 10), brush: PdfSolidBrush(colorDarkGrey));
    double cbX = catX;
    final categories = ['A', 'B', 'C', 'D', 'E'];
    for (String cat in categories) {
      bool isChecked = categorie.toUpperCase() == cat;
      page.graphics.drawRectangle(pen: PdfPen(PdfColor(150,150,150), width: 1), bounds: Rect.fromLTWH(cbX, y + 12.0, 12, 12));
      if (isChecked) {
        page.graphics.drawString('X', fontValue, bounds: Rect.fromLTWH(cbX + 2, y + 11.0, 10, 10));
      }
      page.graphics.drawString(cat, fontValue, bounds: Rect.fromLTWH(cbX + 18, y + 12.0, 15, 15));
      cbX += 40;
    }
    y += 45;

    // Row 4
    drawField('TÉLÉPHONE / PHONE', tel, 0, (width / 2) - 10);
    drawField('ADRESSE E-MAIL / EMAIL', email, (width / 2) + 10, (width / 2) - 10);
    y += 60;

    // --- SECTION II ---
    page.graphics.drawString('II. PIÈCES JOINTES', fontSection, bounds: Rect.fromLTWH(0, y.toDouble(), width, 15));
    page.graphics.drawString(' / ENCLOSED DOCUMENTS', fontSection, bounds: Rect.fromLTWH(115, y.toDouble(), width, 15), brush: PdfSolidBrush(colorLightGrey));
    y += 20;
    
    // Box for enclosed documents
    double boxHeight = 140;
    page.graphics.drawRectangle(pen: linePen, bounds: Rect.fromLTWH(0, y.toDouble(), width, boxHeight));
    
    void drawDocItem(int num, String title, String enTitle, bool isValid, double itemY) {
      page.graphics.drawString('$num. $title', fontValue, bounds: Rect.fromLTWH(15, itemY, 300, 15));
      page.graphics.drawString(' / $enTitle', fontValue, bounds: Rect.fromLTWH(15 + fontValue.measureString('$num. $title').width, itemY, 150, 15), brush: PdfSolidBrush(colorLightGrey));
      
      if (isValid) {
        page.graphics.drawRectangle(brush: PdfSolidBrush(PdfColor(0,0,0)), bounds: Rect.fromLTWH(width - 70, itemY, 55, 16));
        page.graphics.drawString('VALIDÉ', fontBox, bounds: Rect.fromLTWH(width - 68, itemY + 4, 55, 16), brush: PdfSolidBrush(PdfColor(255,255,255)), format: PdfStringFormat(alignment: PdfTextAlignment.center));
      } else {
        page.graphics.drawRectangle(pen: PdfPen(colorLightGrey, width: 1), bounds: Rect.fromLTWH(width - 80, itemY, 65, 16));
        page.graphics.drawString('MANQUANT', fontBox, bounds: Rect.fromLTWH(width - 78, itemY + 4, 65, 16), brush: PdfSolidBrush(colorDarkGrey), format: PdfStringFormat(alignment: PdfTextAlignment.center));
      }
      
      page.graphics.drawLine(PdfPen(PdfColor(245, 245, 245), width: 1), Offset(0, itemY + 25), Offset(width, itemY + 25));
    }

    drawDocItem(1, 'Copie certifiée conforme de la CNI', 'Certified ID Copy', cniBytes != null, y + 15.0);
    drawDocItem(2, 'Certificat médical d\'aptitude', 'Medical Certificate', certificatBytes != null, y + 50.0);
    drawDocItem(3, 'Deux (02) photos d\'identité 4x4', 'Passport Photos', photoBytes != null, y + 85.0);
    drawDocItem(4, 'Quittance des droits de timbre', 'Stamp Duty Receipt', true, y + 120.0); // Assuming valid by default

    y += 180;

    // --- SECTION III : SIGNATURES ---
    page.graphics.drawString('SIGNATURE DU DEMANDEUR', fontSection, bounds: Rect.fromLTWH(0, y.toDouble(), (width / 2), 15));
    page.graphics.drawString('AUTHENTIFICATION OFFICIELLE', fontSection, bounds: Rect.fromLTWH(width - 200, y.toDouble(), 200, 15), format: PdfStringFormat(alignment: PdfTextAlignment.center));
    
    y += 15;
    page.graphics.drawLine(PdfPen(PdfColor(100, 100, 100), width: 1.5), Offset(0, y.toDouble()), Offset((width / 2) - 20, y.toDouble()));
    
    y += 30;
    page.graphics.drawString('Fait à ___________________ , le ___________________', fontValue, bounds: Rect.fromLTWH(0, y.toDouble(), (width / 2), 15), brush: PdfSolidBrush(colorDarkGrey));
    
    // Stamp box
    page.graphics.drawRectangle(
      pen: PdfPen(colorLightGrey, width: 1, dashStyle: PdfDashStyle.dash), 
      bounds: Rect.fromLTWH(width - 170, y - 20.0, 140, 90)
    );
    page.graphics.drawString('EMPLACEMENT SCEAU\nHUMIDE & TIMBRE FISCAL', fontHeaderTop, bounds: Rect.fromLTWH(width - 170, y + 15.0, 140, 30), brush: PdfSolidBrush(colorLightGrey), format: PdfStringFormat(alignment: PdfTextAlignment.center));

    // --- FOOTER ---
    double footerY = height - 30;
    page.graphics.drawString('Note : Toute fausse déclaration expose le demandeur aux sanctions prévues par le Code Pénal Camerounais. Les informations recueillies font l\'objet d\'un traitement informatique sécurisé par le Ministère des Transports pour la gestion du fichier national des permis de conduire.', fontFooter, bounds: Rect.fromLTWH(0, footerY, width, 30), brush: PdfSolidBrush(colorDarkGrey));
    
    page.graphics.drawString('MINTRANSPORT-CAMEROUN-FORM-2024-R', fontFooter, bounds: Rect.fromLTWH(0, footerY + 20, width, 10), brush: PdfSolidBrush(colorLightGrey));

    // Save and print
    final List<int> pdfBytes = document.saveSync();
    document.dispose();

    await Printing.layoutPdf(
      onLayout: (format) async => Uint8List.fromList(pdfBytes),
      name: 'Formulaire_Permis_${nom.replaceAll(' ', '_')}.pdf',
    );
  }
}

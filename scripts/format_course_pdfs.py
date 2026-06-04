from __future__ import annotations

import re
from pathlib import Path

from pypdf import PdfReader
from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    PageBreak,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
)


ROOT = Path(__file__).resolve().parents[1]
COURSE_DIR = ROOT / "assets" / "cours"

COURSES = [
    ("chapitre1.pdf", "chapitre1_formatted.pdf", "Signalisation routiere"),
    ("chapitre2.pdf", "chapitre2_formatted.pdf", "Regles de circulation"),
    ("chapitre3.pdf", "chapitre3_formatted.pdf", "Priorites et intersections"),
    ("chapitre4.pdf", "chapitre4_formatted.pdf", "Vitesse et distances"),
    ("chapitre5.pdf", "chapitre5_formatted.pdf", "Arret et stationnement"),
    ("chapitre6.pdf", "chapitre6_formatted.pdf", "Conduite de nuit et meteo"),
    ("chapitre7.pdf", "chapitre7_formatted.pdf", "Usagers vulnerables"),
    ("chapitre 8.pdf", "chapitre8_formatted.pdf", "Securite du conducteur"),
    ("chapitre 9.pdf", "chapitre9_formatted.pdf", "Vehicule et entretien"),
    ("chapitre 10.pdf", "chapitre10_formatted.pdf", "Autoroute et voies rapides"),
    ("chapitre11.pdf", "chapitre11_formatted.pdf", "Revision generale"),
]


def register_font() -> tuple[str, str]:
    font_dir = Path("C:/Windows/Fonts")
    regular = font_dir / "arial.ttf"
    bold = font_dir / "arialbd.ttf"
    if regular.exists() and bold.exists():
        pdfmetrics.registerFont(TTFont("CourseRegular", str(regular)))
        pdfmetrics.registerFont(TTFont("CourseBold", str(bold)))
        return "CourseRegular", "CourseBold"
    return "Helvetica", "Helvetica-Bold"


FONT, FONT_BOLD = register_font()


def clean_text(text: str) -> str:
    text = re.sub(r"[\U00010000-\U0010ffff]", "", text)
    text = text.replace("\u202f", " ").replace("\xa0", " ")
    text = text.replace("’", "'").replace("–", "-").replace("—", "-")
    text = re.sub(r"[ \t]+", " ", text)
    return text


def extract_blocks(path: Path) -> list[str]:
    reader = PdfReader(str(path))
    blocks: list[str] = []

    for page_index, page in enumerate(reader.pages):
        text = clean_text(page.extract_text() or "")
        lines = [line.strip() for line in text.splitlines()]
        lines = [line for line in lines if line]

        paragraph: list[str] = []
        for line in lines:
            is_heading = looks_like_heading(line)
            is_list = looks_like_list_item(line)

            if is_heading or is_list:
                if paragraph:
                    blocks.append(" ".join(paragraph))
                    paragraph = []
                blocks.append(line)
                continue

            paragraph.append(line)

        if paragraph:
            blocks.append(" ".join(paragraph))

        if page_index < len(reader.pages) - 1:
            blocks.append("__PAGE_BREAK__")

    return normalize_blocks(blocks)


def normalize_blocks(blocks: list[str]) -> list[str]:
    normalized: list[str] = []
    for block in blocks:
        block = re.sub(r"\s+", " ", block).strip()
        block = block.replace(" o ", " - ")
        block = re.sub(r"^o\s+", "- ", block)
        if block:
            normalized.append(block)
    return normalized


def looks_like_heading(line: str) -> bool:
    if len(line) > 95:
        return False
    if re.match(r"^(THEME|THÈME|COURS|CHAPITRE)\b", line, re.I):
        return True
    if re.match(r"^\d+(\.\d+)*\s+[A-ZÀ-Ÿ]", line):
        return True
    if re.match(r"^[A-Z]\.\s+", line):
        return True
    letters = re.sub(r"[^A-Za-zÀ-ÿ]", "", line)
    return len(letters) > 4 and letters.upper() == letters


def looks_like_list_item(line: str) -> bool:
    return bool(re.match(r"^(\d+[\).]|[-•])\s+", line))


def make_styles():
    styles = getSampleStyleSheet()
    return {
        "title": ParagraphStyle(
            "CourseTitle",
            parent=styles["Title"],
            fontName=FONT_BOLD,
            fontSize=22,
            leading=27,
            alignment=TA_CENTER,
            textColor=colors.HexColor("#0F172A"),
            spaceAfter=12,
        ),
        "heading": ParagraphStyle(
            "CourseHeading",
            parent=styles["Heading2"],
            fontName=FONT_BOLD,
            fontSize=13,
            leading=17,
            textColor=colors.HexColor("#1D4ED8"),
            spaceBefore=8,
            spaceAfter=6,
            alignment=TA_LEFT,
        ),
        "body": ParagraphStyle(
            "CourseBody",
            parent=styles["BodyText"],
            fontName=FONT,
            fontSize=10.5,
            leading=15.5,
            alignment=TA_JUSTIFY,
            textColor=colors.HexColor("#1E293B"),
            spaceAfter=7,
        ),
        "list": ParagraphStyle(
            "CourseList",
            parent=styles["BodyText"],
            fontName=FONT,
            fontSize=10.5,
            leading=15.5,
            leftIndent=10,
            firstLineIndent=-8,
            alignment=TA_JUSTIFY,
            textColor=colors.HexColor("#1E293B"),
            spaceAfter=6,
        ),
    }


def paragraph_for(block: str, styles: dict[str, ParagraphStyle]):
    safe = block.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    if block == "__PAGE_BREAK__":
        return PageBreak()
    if looks_like_heading(block):
        return Paragraph(safe, styles["heading"])
    if looks_like_list_item(block):
        return Paragraph(safe, styles["list"])
    return Paragraph(safe, styles["body"])


def draw_page(canvas, doc):
    canvas.saveState()
    width, _ = A4
    canvas.setFillColor(colors.HexColor("#E2E8F0"))
    canvas.rect(18 * mm, 282 * mm, width - 36 * mm, 0.6, stroke=0, fill=1)
    canvas.setFont(FONT, 8)
    canvas.setFillColor(colors.HexColor("#64748B"))
    canvas.drawRightString(width - 18 * mm, 10 * mm, f"Page {doc.page}")
    canvas.restoreState()


def build_pdf(source: Path, target: Path, title: str) -> None:
    styles = make_styles()
    doc = SimpleDocTemplate(
        str(target),
        pagesize=A4,
        rightMargin=18 * mm,
        leftMargin=18 * mm,
        topMargin=20 * mm,
        bottomMargin=18 * mm,
        title=title,
    )
    story = [Paragraph(title, styles["title"]), Spacer(1, 6)]
    for block in extract_blocks(source):
        story.append(paragraph_for(block, styles))
    doc.build(story, onFirstPage=draw_page, onLaterPages=draw_page)


def main() -> None:
    for source_name, target_name, title in COURSES:
        source = COURSE_DIR / source_name
        target = COURSE_DIR / target_name
        if not source.exists():
            print(f"Missing: {source}")
            continue
        build_pdf(source, target, title)
        print(f"Created {target.relative_to(ROOT)}")


if __name__ == "__main__":
    main()

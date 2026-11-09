/// Minimal CSV reader (RFC-4180 style): quoted fields, doubled quotes, commas
/// and line breaks inside quotes. Handles a UTF-8 BOM and ; or , separators.
List<List<String>> parseCsv(String input) {
  var text = input;
  if (text.startsWith('﻿')) text = text.substring(1);
  if (text.trim().isEmpty) return [];

  // Excel in some regions saves with ';'. Decide from the first line.
  final firstLine = text.split(RegExp(r'\r?\n')).first;
  final sep = (';'.allMatches(firstLine).length > ','.allMatches(firstLine).length) ? ';' : ',';

  final rows = <List<String>>[];
  var row = <String>[];
  final field = StringBuffer();
  var inQuotes = false;

  void endField() {
    row.add(field.toString());
    field.clear();
  }

  void endRow() {
    endField();
    if (row.any((c) => c.trim().isNotEmpty)) rows.add(row);
    row = <String>[];
  }

  for (var i = 0; i < text.length; i++) {
    final ch = text[i];
    if (inQuotes) {
      if (ch == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        field.write(ch);
      }
    } else if (ch == '"') {
      inQuotes = true;
    } else if (ch == sep) {
      endField();
    } else if (ch == '\n') {
      endRow();
    } else if (ch == '\r') {
      // swallow; the \n (if any) ends the row
      if (i + 1 >= text.length || text[i + 1] != '\n') endRow();
    } else {
      field.write(ch);
    }
  }
  if (field.isNotEmpty || row.isNotEmpty) endRow();
  return rows;
}

import 'csv_parse.dart';

/// One product row read from a CSV file, already converted to storage units.
class ImportItem {
  const ImportItem({
    required this.line,
    required this.name,
    required this.barcode,
    required this.hsn,
    required this.gstRateBp,
    required this.pricePaise,
    required this.costPaise,
    required this.openingStockMilli,
    required this.reorderLevel,
  });
  final int line; // 1-based line number in the file (header = 1)
  final String name;
  final String? barcode;
  final String hsn;
  final int gstRateBp;
  final int pricePaise;
  final int costPaise;
  final int openingStockMilli;
  final int reorderLevel;
}

class ImportProblem {
  const ImportProblem(this.line, this.message);
  final int line;
  final String message;
}

class ItemsImportParse {
  const ItemsImportParse(this.items, this.problems);
  final List<ImportItem> items;
  final List<ImportProblem> problems;
}

const String kItemsCsvTemplate =
    'name,barcode,hsn,gst_percent,price,cost,stock,reorder_level\n'
    'Basmati Rice 5kg,8901234567890,1006,5,420,380,20,5\n'
    'Sunflower Oil 1L,,1512,5,155,140,30,10\n';

const _aliases = <String, List<String>>{
  'name': ['name', 'item', 'item name', 'product', 'product name'],
  'barcode': ['barcode', 'bar code', 'ean', 'code'],
  'hsn': ['hsn', 'hsn code', 'sac'],
  'gst': ['gst_percent', 'gst', 'gst %', 'gst%', 'tax', 'tax %', 'gst rate'],
  'price': ['price', 'selling price', 'sale price', 'rate', 'mrp'],
  'cost': ['cost', 'cost price', 'purchase price', 'buy price'],
  'stock': ['stock', 'qty', 'quantity', 'opening stock'],
  'reorder': ['reorder_level', 'reorder', 'reorder level', 'min stock'],
};

const _allowedGst = <int>{0, 25, 300, 500, 1200, 1800, 2800};

/// "1,234.50", "₹ 99", " 18% " -> number, or null when it is not a number.
double? _num(String raw) {
  final cleaned = raw.replaceAll(RegExp(r'[₹%\s,]'), '').replaceAll('Rs.', '').replaceAll('Rs', '');
  if (cleaned.isEmpty) return null;
  return double.tryParse(cleaned);
}

ItemsImportParse parseItemsCsv(String csvText) {
  final rows = parseCsv(csvText);
  if (rows.isEmpty) {
    return const ItemsImportParse([], [ImportProblem(1, 'File khaali hai')]);
  }

  final header = rows.first.map((h) => h.trim().toLowerCase()).toList();
  int? col(String key) {
    for (var i = 0; i < header.length; i++) {
      if (_aliases[key]!.contains(header[i])) return i;
    }
    return null;
  }

  final cName = col('name');
  final cPrice = col('price');
  if (cName == null || cPrice == null) {
    return const ItemsImportParse([], [
      ImportProblem(1, 'Pehli line mein "name" aur "price" column zaroori hain (sample CSV dekho)'),
    ]);
  }
  final cBarcode = col('barcode');
  final cHsn = col('hsn');
  final cGst = col('gst');
  final cCost = col('cost');
  final cStock = col('stock');
  final cReorder = col('reorder');

  String cell(List<String> r, int? i) => (i == null || i >= r.length) ? '' : r[i].trim();

  final items = <ImportItem>[];
  final problems = <ImportProblem>[];
  final seenBarcodes = <String>{};

  for (var i = 1; i < rows.length; i++) {
    final r = rows[i];
    final line = i + 1;
    final name = cell(r, cName);
    if (name.isEmpty) {
      problems.add(ImportProblem(line, 'Naam khaali'));
      continue;
    }
    final price = _num(cell(r, cPrice));
    if (price == null || price < 0) {
      problems.add(ImportProblem(line, '"$name": price galat ya khaali'));
      continue;
    }
    final cost = cCost == null || cell(r, cCost).isEmpty ? 0.0 : _num(cell(r, cCost));
    if (cost == null || cost < 0) {
      problems.add(ImportProblem(line, '"$name": cost galat'));
      continue;
    }
    final gstPct = cGst == null || cell(r, cGst).isEmpty ? 0.0 : _num(cell(r, cGst));
    if (gstPct == null) {
      problems.add(ImportProblem(line, '"$name": GST % galat'));
      continue;
    }
    final gstBp = (gstPct * 100).round();
    if (!_allowedGst.contains(gstBp)) {
      problems.add(ImportProblem(line, '"$name": GST ${gstPct.toString()}% allowed nahi (0, 0.25, 3, 5, 12, 18, 28)'));
      continue;
    }
    final stock = cStock == null || cell(r, cStock).isEmpty ? 0.0 : _num(cell(r, cStock));
    if (stock == null || stock < 0) {
      problems.add(ImportProblem(line, '"$name": stock galat'));
      continue;
    }
    final reorder = cReorder == null || cell(r, cReorder).isEmpty ? 10.0 : _num(cell(r, cReorder));
    if (reorder == null || reorder < 0) {
      problems.add(ImportProblem(line, '"$name": reorder level galat'));
      continue;
    }
    final barcode = cell(r, cBarcode);
    if (barcode.isNotEmpty && !seenBarcodes.add(barcode)) {
      problems.add(ImportProblem(line, '"$name": barcode $barcode file mein dobara aaya'));
      continue;
    }

    items.add(ImportItem(
      line: line,
      name: name,
      barcode: barcode.isEmpty ? null : barcode,
      hsn: cell(r, cHsn),
      gstRateBp: gstBp,
      pricePaise: (price * 100).round(),
      costPaise: (cost * 100).round(),
      openingStockMilli: (stock * 1000).round(),
      reorderLevel: (reorder * 1000).round(),
    ));
  }
  return ItemsImportParse(items, problems);
}

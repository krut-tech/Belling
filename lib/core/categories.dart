/// Item categories are free text the shop owner chooses. A sub-category is
/// written "Parent > Child" (for example "Books > Copies").
const String kCategorySeparator = ' > ';

class CategoryPath {
  final String parent; // '' = no category
  final String? child;
  const CategoryPath(this.parent, this.child);
}

CategoryPath splitCategory(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return const CategoryPath('', null);
  final i = t.indexOf('>');
  if (i < 0) return CategoryPath(t, null);
  final parent = t.substring(0, i).trim();
  final child = t.substring(i + 1).trim();
  return CategoryPath(parent, child.isEmpty ? null : child);
}

String joinCategory(String parent, [String? child]) {
  final p = parent.trim();
  final c = child?.trim() ?? '';
  if (p.isEmpty) return '';
  return c.isEmpty ? p : '$p$kCategorySeparator$c';
}

/// Normalises what the user typed ("books>copies" -> "books > copies").
String normalizeCategory(String raw) {
  final p = splitCategory(raw);
  return joinCategory(p.parent, p.child);
}

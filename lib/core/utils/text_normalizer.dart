const _accentsFrom = 'àâäáãåçéèêëíìîïñóòôöõúùûüýÿ';
const _accentsTo = 'aaaaaaceeeeiiiinooooouuuuyy';

/// Minuscules et sans accents, comme le champ Firestore `nameLower`
/// (même règle que `normalizeForSearch` du service de données de DJOBO).
String normalizeForSearch(String input) {
  final s = input.toLowerCase().replaceAll('œ', 'oe').replaceAll('æ', 'ae');
  final buf = StringBuffer();
  for (final ch in s.split('')) {
    final i = _accentsFrom.indexOf(ch);
    buf.write(i >= 0 ? _accentsTo[i] : ch);
  }
  return buf.toString().trim();
}

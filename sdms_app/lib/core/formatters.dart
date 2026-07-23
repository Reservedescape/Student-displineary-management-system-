String formatDate(String? isoString) {
  if (isoString == null) return '';
  try {
    final date = DateTime.parse(isoString).toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[date.month - 1];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final ampm = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day} $month ${date.year}, $hour:$minute $ampm';
  } catch (e) {
    return '';
  }
}
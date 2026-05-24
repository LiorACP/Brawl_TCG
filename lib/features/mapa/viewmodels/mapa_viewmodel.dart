import 'package:url_launcher/url_launcher.dart';

class MapaViewModel {
  // Launches Google Maps with the appropriate query.
  // Returns true if launched, false if it failed.
  Future<bool> launchMaps(String city, String activeFilter) async {
    final cityLabel = city.trim().isEmpty ? 'mi ubicación' : city.trim();
    const gameNames = {
      'MTG': 'Magic the Gathering',
      'Pokémon': 'Pokemon TCG',
      'YuGiOh': 'Yu-Gi-Oh',
    };
    final gameName = gameNames[activeFilter];
    final query = gameName != null
        ? 'tiendas $gameName en $cityLabel'
        : activeFilter == '< 5 km'
            ? 'tiendas TCG cerca de $cityLabel'
            : 'tiendas TCG en $cityLabel';
    final uri = Uri.parse(
        'https://www.google.com/maps/search/${Uri.encodeComponent(query)}');
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

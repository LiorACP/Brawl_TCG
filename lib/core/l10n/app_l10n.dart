import '../state/app_prefs_notifier.dart';

/// Acceso estático a traducciones. Lee el idioma del AppPrefsNotifier.
/// Uso: L10n.t('Configuración')  →  'Settings' (en inglés)
class L10n {
  static String get _lang => AppPrefsNotifier.instance.idioma;

  /// Devuelve la traducción del texto o el propio texto si no hay entrada.
  static String t(String esText) {
    if (_lang != 'en') return esText;
    return _en[esText] ?? esText;
  }

  /// Traducción con sustitución de variables: L10n.fmt('Hola {name}', {'name': 'Ana'})
  static String fmt(String esText, Map<String, String> args) {
    String result = t(esText);
    args.forEach((k, v) => result = result.replaceAll('{$k}', v));
    return result;
  }

  // ─── Diccionario inglés ────────────────────────────────────────────────────

  static const Map<String, String> _en = {
    // ── Navegación ────────────────────────────────────────────────────────────
    'Eventos': 'Events',
    'Mapa': 'Map',
    'Reglas': 'Rules',
    'Perfil': 'Profile',
    'Tienda': 'Store',

    // ── Config principal ──────────────────────────────────────────────────────
    'Configuración': 'Settings',
    'Editar': 'Edit',
    'desde {year}': 'since {year}',

    // Cuenta
    'Cuenta': 'Account',
    'Datos personales': 'Personal data',
    '2FA desactivado': '2FA disabled',
    'Contraseña y seguridad': 'Password & security',
    'Mis juegos favoritos': 'My favorite games',
    '{n} seleccionados': '{n} selected',

    // Notificaciones
    'Notificaciones': 'Notifications',
    'Torneos próximos': 'Upcoming tournaments',
    'Push · 2h antes': 'Push · 2h before',
    'Nuevos eventos cerca': 'New events nearby',
    'Radio 10 km': '10 km radius',
    'Resultados y emparejamiento': 'Results & matchmaking',
    'En tiempo real': 'Real time',
    'Promociones de tiendas': 'Store promotions',
    'Semanal': 'Weekly',
    'Notificaciones por ciudad': 'Notifications by city',
    'Eventos en {city}': 'Events in {city}',

    // Preferencias
    'Preferencias': 'Preferences',
    'Idioma': 'Language',
    'Español (España)': 'Spanish (Spain)',
    'English (UK)': 'English (UK)',
    'Apariencia': 'Appearance',
    'Oscuro': 'Dark',
    'Claro': 'Light',
    'Unidades': 'Units',

    // Legal
    'Legal': 'Legal',
    'Política de privacidad': 'Privacy policy',
    'Términos y condiciones': 'Terms & conditions',
    'Cerrar sesión': 'Sign out',

    // ── Pantalla Apariencia ───────────────────────────────────────────────────
    'TEMA DE LA APLICACIÓN': 'APP THEME',
    'El modo claro está disponible pero la experiencia está optimizada para el modo oscuro.':
        'Light mode is available but the experience is optimised for dark mode.',

    // ── Pantalla Idioma ───────────────────────────────────────────────────────
    'SELECCIONA UN IDIOMA': 'SELECT A LANGUAGE',
    'Español': 'Spanish',
    'España': 'Spain',
    'English': 'English',
    'United Kingdom': 'United Kingdom',

    // ── Pantalla Unidades ─────────────────────────────────────────────────────
    'Distancia': 'Distance',
    '📍 Kilómetros': '📍 Kilometres',
    '📍 Millas': '📍 Miles',
    'Formato de hora': 'Time format',
    '🕐 24 horas': '🕐 24 hours',
    '🕐 12 horas (AM/PM)': '🕐 12 hours (AM/PM)',
    'Guardar cambios': 'Save changes',

    // ── Pantalla Notificaciones ───────────────────────────────────────────────
    'CENTRO': 'HUB',
    '{n} sin leer': '{n} unread',
    'Todas': 'All',
    'Resultados': 'Results',
    'Social': 'Social',
    'Sistema': 'System',
    'Hoy': 'Today',
    'Ayer': 'Yesterday',
    'Sin notificaciones de este tipo': 'No notifications of this type',
    'No hay notificaciones recientes en esta categoría':
        'No recent notifications in this category',
    'Todo al día': 'All caught up',
    'No tienes notificaciones en las últimas 48h':
        'No notifications in the last 48 hours',

    // ── Pantalla Datos Personales ─────────────────────────────────────────────
    'Datos Personales': 'Personal Data',
    'Nombre': 'Name',
    'Email': 'Email',
    'Teléfono': 'Phone',
    'Guardar': 'Save',
    'Cancelar': 'Cancel',

    // ── Pantalla Contraseña ───────────────────────────────────────────────────
    'Contraseña y Seguridad': 'Password & Security',
    'Cambiar contraseña': 'Change password',
    'Activar 2FA': 'Enable 2FA',

    // ── Pantalla Juegos Favoritos ─────────────────────────────────────────────
    'Juegos Favoritos': 'Favourite Games',

    // ── Tags ──────────────────────────────────────────────────────────────────
    'Organizador': 'Organiser',

    // ── Botones comunes ───────────────────────────────────────────────────────
    'Volver': 'Back',
    'Guardar preferencias': 'Save preferences',
    'Eliminar': 'Delete',
    'Aceptar': 'Accept',
    'Rechazar': 'Reject',
    'Confirmar': 'Confirm',
    'Siguiente': 'Next',
    'Finalizar': 'Finish',
    'Publicar': 'Publish',
    'Generar': 'Generate',
    'Desapuntar': 'Leave',

    // ── Pantalla Eventos cliente ───────────────────────────────────────────────
    'Mis eventos': 'My events',
    'Apuntados': 'Registered',
    'Participados': 'Participated',
    'MESA': 'TABLE',
    'Ver →': 'View →',
    'No tienes torneos próximos': 'No upcoming tournaments',
    'Usa el botón ＋ para inscribirte con un código':
        'Use the ＋ button to join with a code',
    'Próximos ({n})': 'Upcoming ({n})',
    'Aquí aparecerán tus próximas inscripciones aceptadas.':
        'Your upcoming accepted registrations will appear here.',
    'Aún no has participado': 'No tournaments yet',
    'Tus resultados de torneos aparecerán aquí':
        'Your tournament results will appear here',
    'Jugados': 'Played',
    'Podios': 'Podiums',
    'Títulos': 'Titles',
    'JUGADOR': 'PLAYER',
    'HOLA, {name}': 'HI, {name}',

    // ── Pantalla Eventos org ──────────────────────────────────────────────────
    'ORGANIZADOR': 'ORGANISER',
    'Ver inscripciones pendientes': 'View pending registrations',
    'Ver participantes': 'View participants',
    'Editar torneo': 'Edit tournament',
    'Eliminar torneo': 'Delete tournament',
    'Eliminar borrador': 'Delete draft',
    'En curso': 'Live',
    'Borradores': 'Drafts',
    'Finalizados': 'Finished',
    'Inscritos': 'Registered',
    'Este mes': 'This month',
    'Sin torneos activos': 'No active tournaments',
    'Crea tu primer torneo con el botón ＋ Crear':
        'Create your first tournament with the ＋ Create button',
    'Sin borradores': 'No drafts',
    'Los torneos guardados sin publicar aparecerán aquí':
        'Saved unpublished tournaments will appear here',
    'Sin torneos finalizados': 'No finished tournaments',
    'Aquí verás el historial de torneos completados':
        'Completed tournament history will appear here',
    'Finalizar torneo': 'Finish tournament',
    'Esta acción no se puede deshacer.': 'This action cannot be undone.',
    'Error al finalizar: {e}': 'Error finishing: {e}',
    'Error al iniciar: {e}': 'Error starting: {e}',
    'EN VIVO · RONDA {r} / {t}': 'LIVE · ROUND {r} / {t}',
    'Ronda {r} en juego': 'Round {r} in progress',
    '＋ Crear': '＋ Create',
    'Torneos': 'Tournaments',
    'Borrador': 'Draft',
    'Finalizado': 'Finished',
    'Sin enfrentamientos en esta ronda.': 'No matches in this round.',
    'Sin puntuaciones aún': 'No scores yet',
    'Todos terminaron': 'All finished',

    // ── Pantalla Reglas ───────────────────────────────────────────────────────
    'BIBLIOTECA': 'LIBRARY',
    'Juegos & Reglas': 'Games & Rules',
    'Juegos soportados': 'Supported games',
    'Recursos rápidos': 'Quick resources',
    'Glosario': 'Glossary',
    'Árbitro FAQ': 'Judge FAQ',
    'Eventos oficiales': 'Official events',
    'NUEVO': 'NEW',
    'Reglas v.{v}': 'Rules v.{v}',

    // ── Pantalla Tienda ───────────────────────────────────────────────────────
    'TIENDA': 'STORE',
    'Mi tienda': 'My store',
    'Administración': 'Management',
    'Horarios': 'Opening hours',
    'Productos vendidos': 'Products sold',
    'Capacidad': 'Capacity',
    'Redes sociales': 'Social media',
    'Nombre de tu tienda': 'Your store name',
    'Dirección': 'Address',
    'Año de apertura': 'Opening year',
    'TEXTO DEL ANUNCIO': 'ANNOUNCEMENT TEXT',
    'Publicar anuncio': 'Publish announcement',
    'BOTE DE PREMIOS': 'PRIZE POOL',

    // ── Pantalla Mapa ─────────────────────────────────────────────────────────
    'No se pudo abrir Google Maps': 'Could not open Google Maps',
    'Buscar tienda': 'Find store',
    'Ciudad...': 'City...',

    // ── Pantalla Código (cliente) ─────────────────────────────────────────────
    'Unirme a un torneo': 'Join a tournament',
    'código del torneo': 'tournament code',
    'Otro código': 'Another code',
    'Inscribirme': 'Register',
    'Inscribirme ✓': 'Registered ✓',
    'Enlace de tu mazo': 'Your deck link',
    'Ya estás inscrito en este torneo':
        'You are already registered in this tournament',
    'Error al inscribirse: {e}': 'Error registering: {e}',
    'Código de torneo no encontrado': 'Tournament code not found',
    'CÓDIGO DE INSCRIPCIÓN': 'REGISTRATION CODE',

    // ── Crear torneo ──────────────────────────────────────────────────────────
    'NUEVO TORNEO': 'NEW TOURNAMENT',
    'NOMBRE DEL TORNEO': 'TOURNAMENT NAME',
    'FECHA': 'DATE',
    'HORA': 'TIME',
    'PLAZAS': 'SPOTS',
    'INSCRIPCIÓN': 'ENTRY FEE',
    'TORNEO': 'TOURNAMENT',
    'Paso 1 de 4 · Información': 'Step 1 of 4 · Info',
    'Paso 2 de 4 · Formato': 'Step 2 of 4 · Format',
    'Paso 3 de 4 · Premios': 'Step 3 of 4 · Prizes',
    'Paso 4 de 4 · Publicar': 'Step 4 of 4 · Publish',
    'Siguiente · Formato →': 'Next · Format →',
    'Siguiente · Premios →': 'Next · Prizes →',
    'Siguiente · Publicar →': 'Next · Publish →',
    'Introduce al menos el nombre del torneo':
        'Enter at least the tournament name',
    'Introduce el nombre del torneo': 'Enter the tournament name',
    'Selecciona la fecha del torneo': 'Select the tournament date',
    'Selecciona la hora del torneo': 'Select the tournament time',
    'Error al guardar el evento': 'Error saving event',
    'Error al guardar el formato': 'Error saving format',
    'Error al guardar los premios': 'Error saving prizes',
    'Error al publicar el torneo': 'Error publishing tournament',
    'Rellena todos los campos': 'Fill in all fields',

    // ── Inscripciones ─────────────────────────────────────────────────────────
    'Ranking': 'Ranking',
    'VS': 'VS',
    'Torneo cancelado': 'Tournament cancelled',

    // ── Perfil / Auth ─────────────────────────────────────────────────────────
    'Actualizar contraseña': 'Update password',
    'Contraseña actual': 'Current password',
    'Nueva contraseña': 'New password',
    'Confirmar contraseña': 'Confirm password',
    'Contraseña actualizada': 'Password updated',
    'Nombre completo': 'Full name',
    'La contraseña debe tener al menos 6 caracteres':
        'Password must be at least 6 characters',
    'Las contraseñas no coinciden': 'Passwords do not match',
    'Error al guardar el perfil en la base de datos':
        'Error saving profile to database',
    'Error al guardar los cambios.': 'Error saving changes.',
    'Introduce tu email': 'Enter your email',
    'Email registrado': 'Email registered',
    'Error con Google: {e}': 'Error with Google: {e}',
    'Error: {e}': 'Error: {e}',
    'Cuenta creada. Revisa tu correo para verificar la cuenta antes de iniciar sesión.':
        'Account created. Check your email to verify your account before signing in.',
    'Error al guardar el perfil.': 'Error saving profile.',
    'Error al unirse: {e}': 'Error joining: {e}',

    // ── Premios / Anuncios ────────────────────────────────────────────────────
    'Guardar ({{n}} juegos)': 'Save ({{n}} games)',

    // ── Comunes ───────────────────────────────────────────────────────────────
    'Atrás': 'Back',
    '· en vivo': '· live',
  };
}

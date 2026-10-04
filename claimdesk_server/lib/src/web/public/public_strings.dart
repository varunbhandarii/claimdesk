import 'public_lang.dart';

/// Text for the public pages and the poster, in English and Spanish.
///
/// Both maps have the same keys; templates read them as `{{t.key}}`.
/// Placeholders in braces are filled in code with [PublicStrings.fill].
/// Venue data (name, desk hours, pickup instructions, zones) is shown as the
/// venue entered it.
class PublicStrings {
  static Map<String, String> of(PublicLang lang) =>
      lang == PublicLang.es ? es : en;

  /// [text] with each `{name}` replaced by its value.
  static String fill(String text, Map<String, Object> values) {
    var result = text;
    values.forEach(
      (name, value) => result = result.replaceAll('{$name}', '$value'),
    );
    return result;
  }

  static const en = <String, String>{
    // Header and footer.
    'skipToContent': 'Skip to content',
    'deskEyebrow': 'Lost & found desk',
    'languageNav': 'Language',
    'switchLabel': 'Español',
    'footerPrivacy':
        'Your report is shared only with this venue’s desk staff. Your email is used only to contact you about it, and contact details never appear on ticket pages.',
    'poweredBy': 'Powered by ClaimDesk on Serverpod',
    // Venue page.
    'deskInformation': 'Desk information',
    'lostSomething': 'Lost something?',
    'venueLede':
        'Tell the desk what you lost. You get a private ticket link to follow it. No account needed.',
    'reportLostItem': 'Report a lost item',
    'takesTwoMinutes': 'Takes about two minutes.',
    'deskHours': 'Desk hours',
    'pickingUp': 'Picking up an item',
    'foundSomething': 'Found something?',
    'handItIn': 'Hand it to the desk so it can get home.',
    'recentlyHandedIn': 'Recently handed in',
    'lastFourteenDays': 'Last 14 days',
    'valuablesNever':
        'Wallets, cards, IDs and other valuables are never listed here. Ask at the desk.',
    'seeYours': 'See yours? Report it so the desk can check.',
    'defaultHours': 'Ask the front desk for opening hours.',
    'defaultPickup': 'Bring your reference code to the front desk.',
    // Lost form.
    'back': 'Back',
    'formLede':
        'Three short parts. Describe it in your own words. Afterwards you get a private ticket link for updates.',
    'checkFields': 'Check these fields',
    'partWhat': 'What did you lose?',
    'kindOfItem': 'Kind of item',
    'notSure': 'Not sure',
    'colours': 'Colours',
    'coloursHint': 'Choose up to three, or leave blank.',
    'brand': 'Brand or model',
    'optional60': 'Optional; up to 60 characters.',
    'describeIt': 'Describe it',
    'describeHint':
        'What would someone notice first? 20–400 characters and at least three words.',
    'partWhere': 'Where and when',
    'whereWere': 'Where were you?',
    'morePrecisely': 'More precisely',
    'optional120': 'Optional; up to 120 characters.',
    'dayLost': 'Day you lost it',
    'dayHint': 'In the venue’s timezone, within the last 90 days.',
    'unsureDay': 'I’m not sure of the day',
    'partProof': 'Proof and contact',
    'ownerDetails': 'Details only you would know',
    'ownerDetailsHint':
        'Optional, strongly encouraged: a scratch, what is inside, a sticker or lock-screen photo. Up to 300 characters. Only desk staff see this.',
    'yourEmail': 'Your email',
    'emailHint':
        'Required. The desk may use it to contact you about a match. No email is sent automatically; check your ticket for updates.',
    'yourName': 'Your name',
    'optional80': 'Optional; up to 80 characters.',
    'consent': 'The desk may contact me about this report.',
    'honeypot': 'Leave this field empty',
    'sendReport': 'Send my report',
    'submitNote': 'No account. No spam. One private ticket link.',
    // Form errors.
    'errMax': 'Use at most {max} characters.',
    'errDescribe':
        'Describe your item in at least 20 characters and three words.',
    'errCategory': 'Choose a category from the list.',
    'errColours': 'Choose at most three colours.',
    'errZone': 'Choose a zone at this venue.',
    'errEmail': 'Enter a valid email address.',
    'errConsent': 'Allow the desk to contact you about this report.',
    'errDateMissing': 'Choose a date, or select not sure of the day.',
    'errDateRange':
        'Choose a real date within the last 90 days, not in the future.',
    'errUnreadable': 'The form could not be read. Please try again.',
    'errAnswerLength': 'Use 10 to 300 characters for this answer.',
    'errNoAnswers': 'The desk is not asking for answers right now.',
    // Ticket page.
    'reportProgress': 'Report progress',
    'yourAnswer': 'Your answer',
    'itemReadyAlt': 'Item ready for pickup',
    'duplicateNotice': 'You already filed this; here is your ticket.',
    'claimTicket': 'Your claim ticket',
    'quoteCode': 'Quote this code at the desk.',
    'stepOf': 'Step {n} of {count}',
    'returnedStamp': 'RETURNED',
    'backWithYou': 'Back with you. Thank you.',
    'returnReceipt': 'Return receipt',
    'receiptReturned': 'Returned',
    'receiptWhere': 'Where',
    'receiptId': 'ID seen',
    'receiptReference': 'Reference',
    'ticketClosed': 'This ticket is closed. It stays here as your receipt.',
    'mayHaveItem': 'The desk may have your item.',
    'answersReceived': 'Answers received. Desk staff will review them.',
    'changeAnswers': 'Change answers',
    'answerIntro':
        'Answer two questions so staff can check it’s yours. Only desk staff see your answers.',
    'website': 'Website',
    'sendAnswers': 'Send answers',
    'or': 'or',
    'comeWithId': 'Come to the desk with photo ID and quote',
    'comeWithIdEnd': '.',
    'itemReady': 'Your item is ready.',
    'holdingForYou': 'This is the item the desk is holding for you.',
    'bringId': 'Bring photo ID',
    'answersQuote': 'Answers received. Quote',
    'answersQuoteEnd': 'at the desk.',
    'stillMissing': 'Still missing it? A new report starts a fresh search.',
    'fileNewReport': 'File a new report',
    'lostElse': 'Lost something else?',
    'reportAnother': 'Report another item',
    'keepPrivate': 'Keep this link private.',
    'keepPrivateDetail':
        'Bookmark it and reload for updates. The page never shows your name, email or proof.',
    'filedLine': 'Filed {filed} · last updated {updated}',
    'venueInformation': 'Venue information',
    // Ticket states.
    'statusReceived': 'Received',
    'statusSearching': 'Searching',
    'statusPossibleMatch': 'Possible match',
    'statusReadyForPickup': 'Ready for pickup',
    'statusReturned': 'Returned',
    'statusClosed': 'Closed',
    'sentenceReceived':
        'We have your report. The desk checks new items against it; come back here for updates.',
    'sentenceSearching':
        'We are checking every item handed in against your report, and we keep checking as new items arrive.',
    'sentencePossibleMatch':
        'The desk may have your item. Come to the desk with photo ID, and answer the two questions below to help staff verify ownership.',
    'sentenceReadyForPickup': 'Your item is ready. Bring photo ID to the desk.',
    'sentenceReturned': 'Returned. Thank you. Last updated {date}.',
    'sentenceClosed':
        'This report was closed on {date} without a match. File a new report if you still miss the item.',
    // ID types on the receipt.
    'idDriversLicence': 'Driver’s licence',
    'idPassport': 'Passport',
    'idStudent': 'Student ID',
    'idOtherGovernment': 'Other government ID',
    'idNone': 'None',
    // Error pages.
    'notFoundTitle': 'No ticket or venue here',
    'notFoundBody':
        'Check the link or scan the venue’s QR poster again. If you need help, ask the desk.',
    'rateTitle': 'Please try again shortly',
    'rateBody':
        'You have made several requests. Wait {seconds} seconds before trying again. If you need immediate help, ask the desk.',
    'unavailableTitle': 'We could not complete that request',
    'unavailableBody':
        'Please try again shortly. If you need help, ask the desk.',
    // Poster.
    'posterScan': 'Scan to report it.',
    'posterLink': 'No account needed. You get a private ticket link.',
    'posterOrType': 'Or type',
    'posterFound': 'Found something? Hand it to the desk.',
    'posterQrAlt': 'QR code that opens this venue’s lost-and-found page',
  };

  static const es = <String, String>{
    // Header and footer.
    'skipToContent': 'Saltar al contenido',
    'deskEyebrow': 'Objetos perdidos',
    'languageNav': 'Idioma',
    'switchLabel': 'English',
    'footerPrivacy':
        'Su reporte solo lo ve el personal del mostrador de este lugar. Su correo se usa solo para comunicarse con usted sobre el reporte, y sus datos de contacto nunca aparecen en la página del comprobante.',
    'poweredBy': 'Con tecnología de ClaimDesk sobre Serverpod',
    // Venue page.
    'deskInformation': 'Información del mostrador',
    'lostSomething': '¿Perdió algo?',
    'venueLede':
        'Cuéntele al mostrador qué perdió. Recibirá un enlace privado para seguir su reporte. No necesita crear una cuenta.',
    'reportLostItem': 'Reportar un objeto perdido',
    'takesTwoMinutes': 'Toma unos dos minutos.',
    'deskHours': 'Horario del mostrador',
    'pickingUp': 'Para recoger un objeto',
    'foundSomething': '¿Encontró algo?',
    'handItIn': 'Entréguelo en el mostrador para que vuelva a su dueño.',
    'recentlyHandedIn': 'Entregados recientemente',
    'lastFourteenDays': 'Últimos 14 días',
    'valuablesNever':
        'Las billeteras, tarjetas, identificaciones y otros objetos de valor nunca aparecen aquí. Pregunte en el mostrador.',
    'seeYours': '¿Ve el suyo? Repórtelo para que el mostrador lo verifique.',
    'defaultHours': 'Pregunte el horario en el mostrador.',
    'defaultPickup': 'Traiga su código de referencia al mostrador.',
    // Lost form.
    'back': 'Volver',
    'formLede':
        'Tres partes cortas. Descríbalo con sus propias palabras. Al final recibirá un enlace privado para ver novedades.',
    'checkFields': 'Revise estos campos',
    'partWhat': '¿Qué perdió?',
    'kindOfItem': 'Tipo de objeto',
    'notSure': 'No lo sé',
    'colours': 'Colores',
    'coloursHint': 'Elija hasta tres, o déjelo en blanco.',
    'brand': 'Marca o modelo',
    'optional60': 'Opcional; hasta 60 caracteres.',
    'describeIt': 'Descríbalo',
    'describeHint':
        '¿Qué notaría alguien primero? De 20 a 400 caracteres y al menos tres palabras.',
    'partWhere': 'Dónde y cuándo',
    'whereWere': '¿Dónde estaba?',
    'morePrecisely': 'Más exactamente',
    'optional120': 'Opcional; hasta 120 caracteres.',
    'dayLost': 'Día en que lo perdió',
    'dayHint': 'En la zona horaria del lugar, dentro de los últimos 90 días.',
    'unsureDay': 'No sé el día exacto',
    'partProof': 'Prueba y contacto',
    'ownerDetails': 'Detalles que solo usted conoce',
    'ownerDetailsHint':
        'Opcional, pero muy recomendable: un rayón, lo que hay adentro, una calcomanía o la foto de la pantalla de bloqueo. Hasta 300 caracteres. Solo el personal del mostrador lo ve.',
    'yourEmail': 'Su correo electrónico',
    'emailHint':
        'Obligatorio. El mostrador puede usarlo para avisarle de una coincidencia. No se envían correos automáticos; revise su comprobante para ver novedades.',
    'yourName': 'Su nombre',
    'optional80': 'Opcional; hasta 80 caracteres.',
    'consent': 'El mostrador puede comunicarse conmigo sobre este reporte.',
    'honeypot': 'Deje este campo vacío',
    'sendReport': 'Enviar mi reporte',
    'submitNote': 'Sin cuenta. Sin spam. Un solo enlace privado.',
    // Form errors.
    'errMax': 'Use como máximo {max} caracteres.',
    'errDescribe':
        'Describa su objeto con al menos 20 caracteres y tres palabras.',
    'errCategory': 'Elija un tipo de objeto de la lista.',
    'errColours': 'Elija como máximo tres colores.',
    'errZone': 'Elija una zona de este lugar.',
    'errEmail': 'Escriba un correo electrónico válido.',
    'errConsent':
        'Permita que el mostrador se comunique con usted sobre este reporte.',
    'errDateMissing': 'Elija una fecha, o marque “No sé el día exacto”.',
    'errDateRange':
        'Elija una fecha real de los últimos 90 días, que no sea futura.',
    'errUnreadable': 'No pudimos leer el formulario. Vuelva a intentarlo.',
    'errAnswerLength': 'Use de 10 a 300 caracteres en esta respuesta.',
    'errNoAnswers': 'El mostrador no está pidiendo respuestas en este momento.',
    // Ticket page.
    'reportProgress': 'Progreso del reporte',
    'yourAnswer': 'Su respuesta',
    'itemReadyAlt': 'Objeto listo para recoger',
    'duplicateNotice':
        'Ya había enviado este reporte; aquí está su comprobante.',
    'claimTicket': 'Su comprobante',
    'quoteCode': 'Diga este código en el mostrador.',
    'stepOf': 'Paso {n} de {count}',
    'returnedStamp': 'DEVUELTO',
    'backWithYou': 'De vuelta con usted. Gracias.',
    'returnReceipt': 'Recibo de devolución',
    'receiptReturned': 'Devuelto',
    'receiptWhere': 'Dónde',
    'receiptId': 'Identificación revisada',
    'receiptReference': 'Referencia',
    'ticketClosed': 'Este comprobante está cerrado. Queda aquí como su recibo.',
    'mayHaveItem': 'Es posible que el mostrador tenga su objeto.',
    'answersReceived':
        'Respuestas recibidas. El personal del mostrador las revisará.',
    'changeAnswers': 'Cambiar respuestas',
    'answerIntro':
        'Responda dos preguntas para que el personal confirme que es suyo. Solo el personal del mostrador ve sus respuestas.',
    'website': 'Sitio web',
    'sendAnswers': 'Enviar respuestas',
    'or': 'o',
    'comeWithId':
        'Venga al mostrador con una identificación con foto y diga el código',
    'comeWithIdEnd': '.',
    'itemReady': 'Su objeto está listo.',
    'holdingForYou': 'Este es el objeto que el mostrador le está guardando.',
    'bringId': 'Traiga una identificación con foto',
    'answersQuote': 'Respuestas recibidas. Diga el código',
    'answersQuoteEnd': 'en el mostrador.',
    'stillMissing':
        '¿Todavía le falta? Un nuevo reporte inicia una búsqueda nueva.',
    'fileNewReport': 'Hacer un nuevo reporte',
    'lostElse': '¿Perdió otra cosa?',
    'reportAnother': 'Reportar otro objeto',
    'keepPrivate': 'Mantenga este enlace en privado.',
    'keepPrivateDetail':
        'Guárdelo en favoritos y recargue la página para ver novedades. La página nunca muestra su nombre, su correo ni sus pruebas.',
    'filedLine': 'Enviado el {filed} · actualizado el {updated}',
    'venueInformation': 'Información del lugar',
    // Ticket states.
    'statusReceived': 'Recibido',
    'statusSearching': 'Buscando',
    'statusPossibleMatch': 'Posible coincidencia',
    'statusReadyForPickup': 'Listo para recoger',
    'statusReturned': 'Devuelto',
    'statusClosed': 'Cerrado',
    'sentenceReceived':
        'Recibimos su reporte. El mostrador compara con él cada objeto nuevo; vuelva aquí para ver novedades.',
    'sentenceSearching':
        'Estamos comparando con su reporte cada objeto entregado, y seguiremos haciéndolo a medida que lleguen objetos nuevos.',
    'sentencePossibleMatch':
        'Es posible que el mostrador tenga su objeto. Venga al mostrador con una identificación con foto y responda las dos preguntas de abajo para ayudar al personal a confirmar que es suyo.',
    'sentenceReadyForPickup':
        'Su objeto está listo. Traiga una identificación con foto al mostrador.',
    'sentenceReturned': 'Devuelto. Gracias. Última actualización: {date}.',
    'sentenceClosed':
        'Este reporte se cerró el {date} sin una coincidencia. Haga un nuevo reporte si todavía le falta el objeto.',
    // ID types on the receipt.
    'idDriversLicence': 'Licencia de conducir',
    'idPassport': 'Pasaporte',
    'idStudent': 'Credencial de estudiante',
    'idOtherGovernment': 'Otra identificación oficial',
    'idNone': 'Ninguna',
    // Error pages.
    'notFoundTitle': 'Aquí no hay ningún comprobante ni lugar',
    'notFoundBody':
        'Revise el enlace o vuelva a escanear el código QR del cartel del lugar. Si necesita ayuda, pregunte en el mostrador.',
    'rateTitle': 'Vuelva a intentarlo en un momento',
    'rateBody':
        'Hizo varias solicitudes seguidas. Espere {seconds} segundos antes de volver a intentarlo. Si necesita ayuda de inmediato, pregunte en el mostrador.',
    'unavailableTitle': 'No pudimos completar la solicitud',
    'unavailableBody':
        'Vuelva a intentarlo en un momento. Si necesita ayuda, pregunte en el mostrador.',
    // Poster.
    'posterScan': 'Escanee para reportarlo.',
    'posterLink': 'No necesita cuenta. Recibirá un enlace privado.',
    'posterOrType': 'O escriba',
    'posterFound': '¿Encontró algo? Entréguelo en el mostrador.',
    'posterQrAlt':
        'Código QR que abre la página de objetos perdidos de este lugar',
  };

  /// Spanish names for the category groups in the form, keyed by the English
  /// group label (`Taxonomy.groups` stays English: matching depends on it).
  static const groupsEs = <String, String>{
    'Umbrellas & rain gear': 'Paraguas e impermeables',
    'Bags': 'Bolsas y mochilas',
    'Wallets, cards & money': 'Billeteras, tarjetas y dinero',
    'Keys & access': 'Llaves y tarjetas de acceso',
    'Phones & tablets': 'Teléfonos y tabletas',
    'Computers & accessories': 'Computadoras y accesorios',
    'Audio': 'Audio',
    'Wearables & small electronics':
        'Relojes inteligentes y electrónica pequeña',
    'Jewelry & watches': 'Joyas y relojes',
    'Eyewear': 'Lentes y anteojos de sol',
    'Clothing': 'Ropa',
    'Footwear': 'Calzado',
    'Bottles & food containers': 'Botellas y recipientes de comida',
    'Toys, gifts & miscellaneous': 'Juguetes, regalos y otros',
    'Books, stationery & school supplies':
        'Libros, papelería y útiles escolares',
    'ID & documents': 'Identificaciones y documentos',
    'Sports, bikes & mobility': 'Deportes, bicicletas y movilidad',
    'Health & personal care': 'Salud y cuidado personal',
  };

  /// Spanish swatch labels, keyed by colour.
  static const swatchesEs = <String, String>{
    'black': 'Negro',
    'white': 'Blanco',
    'grey': 'Gris',
    'silver': 'Plateado',
    'gold': 'Dorado',
    'red': 'Rojo',
    'orange': 'Naranja',
    'yellow': 'Amarillo',
    'green': 'Verde',
    'blue': 'Azul',
    'navy': 'Azul marino',
    'purple': 'Morado',
    'pink': 'Rosa',
    'brown': 'Café',
    'beige': 'Beige',
    'multicolour': 'Multicolor',
    'transparent': 'Transparente',
  };

  /// Spanish verification questions, keyed by the canonical English text the
  /// server stores with each answer, so staff read one question either way.
  static const questionsEs = <String, String>{
    'Where exactly were you when you last had it, and roughly what time?':
        '¿Dónde estaba exactamente la última vez que lo tuvo, y más o menos a qué hora?',
    'Describe one detail that is not visible from the outside or that only the owner would know.':
        'Describa un detalle que no se vea desde afuera o que solo el dueño conozca.',
    'What is the handle made of, and is anything written or attached on it?':
        '¿De qué material es el mango, y tiene algo escrito o colgado?',
    'What is inside the main compartment, and are there tags, keyrings or badges on the zips?':
        '¿Qué hay en el compartimento principal, y tiene etiquetas, llaveros o insignias en los cierres?',
    'Name one card, note or item inside without giving any numbers.':
        'Nombre una tarjeta, nota u objeto que haya adentro, sin dar ningún número.',
    'How many keys are on it, and what else is on the ring?':
        '¿Cuántas llaves tiene, y qué más hay en el llavero?',
    'What is on the lock screen or case, and is there a sticker, crack or engraving?':
        '¿Qué se ve en la pantalla de bloqueo o en la funda, y tiene alguna calcomanía, grieta o grabado?',
    'Describe the case or cable: colour, any marks, and what was with it.':
        'Describa el estuche o el cable: color, marcas, y qué había con él.',
    'Whose name is on it, and what else was with it? (Answer with your name only; no numbers.)':
        '¿A nombre de quién está, y qué más había con él? (Responda solo con su nombre; sin números.)',
    'What size is it, and what was in the pockets or written on the label?':
        '¿De qué talla es, y qué había en los bolsillos o qué dice la etiqueta?',
    'What is on the bottle: stickers, dents, scratches, a name?':
        '¿Qué tiene la botella: calcomanías, abolladuras, rayones, un nombre?',
  };

  /// The category group label in [lang].
  static String group(String label, PublicLang lang) =>
      lang == PublicLang.es ? groupsEs[label] ?? label : label;

  /// A verification question in [lang]; an unknown stored question is shown
  /// as it was saved.
  static String question(String canonical, PublicLang lang) =>
      lang == PublicLang.es ? questionsEs[canonical] ?? canonical : canonical;
}

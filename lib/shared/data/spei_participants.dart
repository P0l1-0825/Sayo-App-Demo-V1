/// Catálogo completo de participantes SPEI (Banxico CEP-SCL, actualizado 2025)
/// La clave corresponde a los primeros 3 dígitos de la CLABE interbancaria.
class SpeiParticipant {
  final String clave;
  final String shortName;
  final String fullName;
  final bool isBank; // true = banco, false = otro participante (SOFIPO, CB, fintech, etc.)

  const SpeiParticipant({
    required this.clave,
    required this.shortName,
    required this.fullName,
    this.isBank = false,
  });
}

class SpeiCatalog {
  SpeiCatalog._();

  static const List<SpeiParticipant> all = [
    // ── Banca Múltiple ──
    SpeiParticipant(clave: '002', shortName: 'BANAMEX', fullName: 'Banco Nacional de México', isBank: true),
    SpeiParticipant(clave: '012', shortName: 'BBVA MEXICO', fullName: 'BBVA México', isBank: true),
    SpeiParticipant(clave: '014', shortName: 'SANTANDER', fullName: 'Banco Santander México', isBank: true),
    SpeiParticipant(clave: '021', shortName: 'HSBC', fullName: 'HSBC México', isBank: true),
    SpeiParticipant(clave: '030', shortName: 'BAJIO', fullName: 'Banco del Bajío', isBank: true),
    SpeiParticipant(clave: '036', shortName: 'INBURSA', fullName: 'Banco Inbursa', isBank: true),
    SpeiParticipant(clave: '042', shortName: 'MIFEL', fullName: 'Banca Mifel', isBank: true),
    SpeiParticipant(clave: '044', shortName: 'SCOTIABANK', fullName: 'Scotiabank Inverlat', isBank: true),
    SpeiParticipant(clave: '058', shortName: 'BANREGIO', fullName: 'Banco Regional de Monterrey', isBank: true),
    SpeiParticipant(clave: '059', shortName: 'INVEX', fullName: 'Banco Invex', isBank: true),
    SpeiParticipant(clave: '060', shortName: 'BANSI', fullName: 'Bansi', isBank: true),
    SpeiParticipant(clave: '062', shortName: 'AFIRME', fullName: 'Banca Afirme', isBank: true),
    SpeiParticipant(clave: '072', shortName: 'BANORTE', fullName: 'Banco Mercantil del Norte', isBank: true),
    SpeiParticipant(clave: '106', shortName: 'BANK OF AMERICA', fullName: 'Bank of America México', isBank: true),
    SpeiParticipant(clave: '108', shortName: 'MUFG', fullName: 'MUFG Bank México', isBank: true),
    SpeiParticipant(clave: '110', shortName: 'JP MORGAN', fullName: 'JP Morgan México', isBank: true),
    SpeiParticipant(clave: '112', shortName: 'BMONEX', fullName: 'Banco Monex', isBank: true),
    SpeiParticipant(clave: '113', shortName: 'VE POR MAS', fullName: 'Banco Ve Por Más', isBank: true),
    SpeiParticipant(clave: '124', shortName: 'CITI MEXICO', fullName: 'Banco Citibanamex (Citi)', isBank: true),
    SpeiParticipant(clave: '127', shortName: 'AZTECA', fullName: 'Banco Azteca', isBank: true),
    SpeiParticipant(clave: '128', shortName: 'KAPITAL', fullName: 'Banco Autofin México (Kapital)', isBank: true),
    SpeiParticipant(clave: '129', shortName: 'BARCLAYS', fullName: 'Barclays Bank México', isBank: true),
    SpeiParticipant(clave: '130', shortName: 'COMPARTAMOS', fullName: 'Banco Compartamos', isBank: true),
    SpeiParticipant(clave: '132', shortName: 'MULTIVA BANCO', fullName: 'Banco Multiva', isBank: true),
    SpeiParticipant(clave: '133', shortName: 'ACTINVER', fullName: 'Banco Actinver', isBank: true),
    SpeiParticipant(clave: '136', shortName: 'INTERCAM BANCO', fullName: 'Intercam Banco', isBank: true),
    SpeiParticipant(clave: '137', shortName: 'BANCOPPEL', fullName: 'BanCoppel', isBank: true),
    SpeiParticipant(clave: '138', shortName: 'ABC CAPITAL', fullName: 'ABC Capital', isBank: true),
    SpeiParticipant(clave: '140', shortName: 'CONSUBANCO', fullName: 'Consubanco', isBank: true),
    SpeiParticipant(clave: '141', shortName: 'VOLKSWAGEN', fullName: 'Volkswagen Bank', isBank: true),
    SpeiParticipant(clave: '143', shortName: 'CIBANCO', fullName: 'CIBanco', isBank: true),
    SpeiParticipant(clave: '145', shortName: 'BBASE', fullName: 'Banco Base', isBank: true),
    SpeiParticipant(clave: '147', shortName: 'BANKAOOL', fullName: 'Bankaool', isBank: true),
    SpeiParticipant(clave: '148', shortName: 'PAGATODO', fullName: 'Pagatodo', isBank: true),
    SpeiParticipant(clave: '150', shortName: 'INMOBILIARIO', fullName: 'Banco Inmobiliario Mexicano', isBank: true),
    SpeiParticipant(clave: '151', shortName: 'DONDE', fullName: 'Banco Donde', isBank: true),
    SpeiParticipant(clave: '152', shortName: 'BANCREA', fullName: 'Bancrea', isBank: true),
    SpeiParticipant(clave: '154', shortName: 'BANCO COVALTO', fullName: 'Banco Covalto', isBank: true),
    SpeiParticipant(clave: '155', shortName: 'ICBC', fullName: 'Industrial and Commercial Bank of China', isBank: true),
    SpeiParticipant(clave: '156', shortName: 'SABADELL', fullName: 'Banco Sabadell', isBank: true),
    SpeiParticipant(clave: '157', shortName: 'SHINHAN', fullName: 'Shinhan Bank México', isBank: true),
    SpeiParticipant(clave: '158', shortName: 'MIZUHO BANK', fullName: 'Mizuho Bank México', isBank: true),
    SpeiParticipant(clave: '159', shortName: 'BANK OF CHINA', fullName: 'Bank of China México', isBank: true),
    SpeiParticipant(clave: '160', shortName: 'BANCO S3', fullName: 'Banco S3 México', isBank: true),
    SpeiParticipant(clave: '138', shortName: 'UALA', fullName: 'Ualá (ABC Capital)', isBank: true),
    SpeiParticipant(clave: '167', shortName: 'HEY BANCO', fullName: 'Hey Banco (Banregio)', isBank: true),

    // ── Banca de Desarrollo ──
    SpeiParticipant(clave: '006', shortName: 'BANCOMEXT', fullName: 'Banco Nacional de Comercio Exterior', isBank: true),
    SpeiParticipant(clave: '009', shortName: 'BANOBRAS', fullName: 'Banco Nacional de Obras y Servicios Públicos', isBank: true),
    SpeiParticipant(clave: '019', shortName: 'BANJERCITO', fullName: 'Banco Nacional del Ejército, Fuerza Aérea y Armada', isBank: true),
    SpeiParticipant(clave: '135', shortName: 'NAFIN', fullName: 'Nacional Financiera', isBank: true),
    SpeiParticipant(clave: '166', shortName: 'BaBien', fullName: 'Banco del Bienestar (antes Bansefi)', isBank: true),
    SpeiParticipant(clave: '168', shortName: 'HIPOTECARIA FED', fullName: 'Sociedad Hipotecaria Federal', isBank: true),

    // ── Casas de Bolsa y Otros Participantes ──
    SpeiParticipant(clave: '600', shortName: 'MONEXCB', fullName: 'Monex Casa de Bolsa'),
    SpeiParticipant(clave: '601', shortName: 'GBM', fullName: 'GBM Grupo Bursátil Mexicano'),
    SpeiParticipant(clave: '602', shortName: 'MASARI', fullName: 'Masari Casa de Bolsa'),
    SpeiParticipant(clave: '605', shortName: 'VALUE', fullName: 'Value Casa de Bolsa'),
    SpeiParticipant(clave: '616', shortName: 'FINAMEX', fullName: 'Casa de Bolsa Finamex'),
    SpeiParticipant(clave: '617', shortName: 'VALMEX', fullName: 'Valores Mexicanos Casa de Bolsa'),
    SpeiParticipant(clave: '620', shortName: 'PROFUTURO', fullName: 'Profuturo'),
    SpeiParticipant(clave: '631', shortName: 'CI BOLSA', fullName: 'CI Casa de Bolsa'),
    SpeiParticipant(clave: '634', shortName: 'FINCOMUN', fullName: 'Fincomún Servicios Financieros'),
    SpeiParticipant(clave: '638', shortName: 'NU MEXICO', fullName: 'Nu México (Financiera)'),
    SpeiParticipant(clave: '646', shortName: 'STP', fullName: 'Sistema de Transferencias y Pagos'),
    SpeiParticipant(clave: '652', shortName: 'CREDICAPITAL', fullName: 'Credicapital'),
    SpeiParticipant(clave: '653', shortName: 'KUSPIT', fullName: 'Kuspit Casa de Bolsa'),
    SpeiParticipant(clave: '656', shortName: 'UNAGRA', fullName: 'Unagra'),
    SpeiParticipant(clave: '659', shortName: 'ASP INTEGRA OPC', fullName: 'ASP Integra OPC'),
    SpeiParticipant(clave: '661', shortName: 'KLAR', fullName: 'Klar'),
    SpeiParticipant(clave: '670', shortName: 'LIBERTAD', fullName: 'Libertad Servicios Financieros'),
    SpeiParticipant(clave: '677', shortName: 'CAJA POP MEXICANA', fullName: 'Caja Popular Mexicana'),
    SpeiParticipant(clave: '680', shortName: 'CRISTOBAL COLON', fullName: 'Cristóbal Colón'),
    SpeiParticipant(clave: '683', shortName: 'CAJA TELEFONIST', fullName: 'Caja de Ahorro de los Telefonistas'),
    SpeiParticipant(clave: '684', shortName: 'TRANSFER', fullName: 'Transfer'),
    SpeiParticipant(clave: '685', shortName: 'FONDO (FIRA)', fullName: 'Fondo FIRA'),
    SpeiParticipant(clave: '688', shortName: 'CREDICLUB', fullName: 'Crediclub'),
    SpeiParticipant(clave: '699', shortName: 'FONDEADORA', fullName: 'Fondeadora'),
    SpeiParticipant(clave: '703', shortName: 'TESORED', fullName: 'Tesored'),
    SpeiParticipant(clave: '706', shortName: 'ARCUS FI', fullName: 'Arcus Financial Intelligence'),
    SpeiParticipant(clave: '710', shortName: 'NVIO', fullName: 'NVIO Pagos'),
    SpeiParticipant(clave: '715', shortName: 'CASHI CUENTA', fullName: 'Cashi (Walmart)'),
    SpeiParticipant(clave: '720', shortName: 'MexPago', fullName: 'MexPago'),
    SpeiParticipant(clave: '721', shortName: 'albo', fullName: 'albo'),
    SpeiParticipant(clave: '722', shortName: 'Mercado Pago', fullName: 'Mercado Pago W'),
    SpeiParticipant(clave: '723', shortName: 'Cuenca', fullName: 'Cuenca'),
    SpeiParticipant(clave: '725', shortName: 'COOPDESARROLLO', fullName: 'Cooperativa de Desarrollo'),
    SpeiParticipant(clave: '727', shortName: 'TRANSFER DIRECT', fullName: 'Transfer Direct'),
    SpeiParticipant(clave: '728', shortName: 'SPIN BY OXXO', fullName: 'Spin by OXXO'),
    SpeiParticipant(clave: '729', shortName: 'Dep y Pag Dig', fullName: 'Depósitos y Pagos Digitales'),
    SpeiParticipant(clave: '730', shortName: 'Swap', fullName: 'Swap'),
    SpeiParticipant(clave: '732', shortName: 'Peibo', fullName: 'Peibo'),
    SpeiParticipant(clave: '734', shortName: 'FINCO PAY', fullName: 'Finco Pay'),
    SpeiParticipant(clave: '738', shortName: 'FINTOC', fullName: 'Fintoc'),
  ];

  /// Busca un participante por los primeros 3 dígitos de la CLABE
  static SpeiParticipant? fromClabe(String clabe) {
    if (clabe.length < 3) return null;
    final prefix = clabe.substring(0, 3);
    try {
      return all.firstWhere((p) => p.clave == prefix);
    } catch (_) {
      return null;
    }
  }

  /// Busca participantes por nombre (búsqueda parcial, case-insensitive)
  static List<SpeiParticipant> search(String query) {
    if (query.isEmpty) return all;
    final q = query.toLowerCase();
    return all.where((p) =>
      p.shortName.toLowerCase().contains(q) ||
      p.fullName.toLowerCase().contains(q) ||
      p.clave.contains(q)
    ).toList();
  }

  /// Solo bancos (banca múltiple + desarrollo)
  static List<SpeiParticipant> get banks => all.where((p) => p.isBank).toList();

  /// Bancos principales (los más comunes para tarjeta de débito)
  static List<SpeiParticipant> get mainBanks => all.where((p) =>
    p.isBank && const [
      '002', '012', '014', '021', '030', '036', '042', '044',
      '058', '062', '072', '127', '130', '133', '136', '137',
      '145', '166', '167',
    ].contains(p.clave)
  ).toList();
}

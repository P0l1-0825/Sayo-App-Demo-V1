class KycSession {
  final String sessionUrl;
  final String shortKey;
  final String? sessionId;
  final String? accessToken;

  const KycSession({
    required this.sessionUrl,
    required this.shortKey,
    this.sessionId,
    this.accessToken,
  });

  factory KycSession.fromFlowResponse(Map<String, dynamic> json) {
    return KycSession(
      sessionUrl: json['url'] as String? ?? '',
      shortKey: json['short_key'] as String? ?? '',
    );
  }

  KycSession withToken(String token, String id) {
    return KycSession(
      sessionUrl: sessionUrl,
      shortKey: shortKey,
      sessionId: id,
      accessToken: token,
    );
  }
}

class DocumentVerification {
  final String evaluation;
  final String? documentType;
  final Map<String, dynamic>? validations;

  const DocumentVerification({
    required this.evaluation,
    this.documentType,
    this.validations,
  });

  bool get isApproved => evaluation == 'APPROVED';

  factory DocumentVerification.fromJson(Map<String, dynamic> json) {
    return DocumentVerification(
      evaluation: json['evaluation'] as String? ?? 'UNKNOWN',
      documentType: json['document_type'] as String?,
      validations: json['validations'] as Map<String, dynamic>?,
    );
  }
}

class ExtractedData {
  final String? fullName;
  final String? curp;
  final String? address;
  final String? birthDate;
  final String? gender;
  final String? documentNumber;
  final String? faceBase64;
  final Map<String, dynamic> raw;

  const ExtractedData({
    this.fullName,
    this.curp,
    this.address,
    this.birthDate,
    this.gender,
    this.documentNumber,
    this.faceBase64,
    this.raw = const {},
  });

  factory ExtractedData.fromJson(Map<String, dynamic> json) {
    final personal = json['personal'] as Map<String, dynamic>? ?? {};
    final document = json['document'] as Map<String, dynamic>? ?? {};
    final addr = json['address'] as Map<String, dynamic>? ?? {};

    return ExtractedData(
      fullName: personal['full_name'] as String?,
      curp: personal['curp'] as String?,
      birthDate: personal['birth_date'] as String?,
      gender: personal['gender'] as String?,
      address: addr['full_address'] as String?,
      documentNumber: document['document_number'] as String?,
      faceBase64: json['face_base64'] as String?,
      raw: json,
    );
  }
}

class LivenessResult {
  final String evaluation;
  final double? score;
  final String? bestFrameBase64;

  const LivenessResult({
    required this.evaluation,
    this.score,
    this.bestFrameBase64,
  });

  bool get isAlive => evaluation == 'APPROVED';

  factory LivenessResult.fromJson(Map<String, dynamic> json) {
    return LivenessResult(
      evaluation: json['evaluation'] as String? ?? 'UNKNOWN',
      score: (json['score'] as num?)?.toDouble(),
      bestFrameBase64: json['best_frame'] as String?,
    );
  }
}

class FaceComparison {
  final double score;
  final bool isSamePerson;

  const FaceComparison({
    required this.score,
    required this.isSamePerson,
  });

  factory FaceComparison.fromJson(Map<String, dynamic> json) {
    return FaceComparison(
      score: (json['score'] as num?)?.toDouble() ?? 0,
      isSamePerson: json['is_same_person'] as bool? ?? false,
    );
  }
}

class BlacklistResult {
  final String organization;
  final bool foundInService;
  final bool mustBeFound;

  const BlacklistResult({
    required this.organization,
    required this.foundInService,
    required this.mustBeFound,
  });

  bool get isValid => mustBeFound ? foundInService : !foundInService;

  factory BlacklistResult.fromJson(Map<String, dynamic> json) {
    return BlacklistResult(
      organization: json['organization'] as String? ?? '',
      foundInService: json['found_in_service'] as bool? ?? false,
      mustBeFound: json['must_be_found'] as bool? ?? false,
    );
  }
}

import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AutoEcoleService {
  AutoEcoleService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  String? get currentUid => _auth.currentUser?.uid;

  Future<DocumentSnapshot<Map<String, dynamic>>?>
      getCurrentUserProfile() async {
    final uid = currentUid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchCurrentUserProfile() {
    final uid = currentUid;
    if (uid == null) {
      return const Stream.empty();
    }
    return _db.collection('users').doc(uid).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchAutoEcole(
      String autoEcoleId) {
    return _db.collection('auto_ecoles').doc(autoEcoleId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchEleves(String autoEcoleId) {
    return _db
        .collection('auto_ecoles')
        .doc(autoEcoleId)
        .collection('eleves')
        .orderBy('derniereActivite', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchDevoirsForCurrentUser() {
    final uid = currentUid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('devoirs')
        .where('eleveUid', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      watchAssignedLessonsForCurrentUser() {
    final uid = currentUid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('lecons_assignees')
        .where('eleveUid', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchReservations(
      String autoEcoleId) {
    return _db
        .collection('reservations')
        .where('autoEcoleId', isEqualTo: autoEcoleId)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      watchReservationsForCurrentMonitor() {
    final uid = currentUid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('reservations')
        .where('moniteurUids', arrayContains: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      watchReservationsForCurrentStudent() {
    final uid = currentUid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('reservations')
        .where('eleveUid', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>
      watchNotificationsForCurrentUser() {
    final uid = currentUid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('notifications')
        .where('userUid', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchLessonCatalog(
      String autoEcoleId) {
    return _db
        .collection('auto_ecoles')
        .doc(autoEcoleId)
        .collection('catalogue_lecons')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getLessonCatalog(
      String autoEcoleId) async {
    final snapshot = await _db
        .collection('auto_ecoles')
        .doc(autoEcoleId)
        .collection('catalogue_lecons')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchHomeworkCatalog(
      String autoEcoleId) {
    return _db
        .collection('auto_ecoles')
        .doc(autoEcoleId)
        .collection('catalogue_devoirs')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getHomeworkCatalog(
      String autoEcoleId) async {
    final snapshot = await _db
        .collection('auto_ecoles')
        .doc(autoEcoleId)
        .collection('catalogue_devoirs')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs;
  }

  Future<Map<String, dynamic>> uploadCatalogDocument({
    required String autoEcoleId,
    required String catalogType,
    required String fileName,
    required Uint8List bytes,
    String? contentType,
  }) async {
    final uid = _requireUser();
    final safeCatalogType = catalogType.trim().isEmpty
        ? 'documents'
        : _sanitizeStorageSegment(catalogType);
    final safeFileName = _sanitizeStorageSegment(fileName);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = _storage.ref().child(
          'auto_ecoles/$autoEcoleId/catalogue_documents/$safeCatalogType/$timestamp-$safeFileName',
        );
    final metadata = SettableMetadata(
      contentType: contentType ?? 'application/octet-stream',
      customMetadata: {
        'autoEcoleId': autoEcoleId,
        'catalogType': safeCatalogType,
        'uploadedBy': uid,
        'originalName': fileName,
      },
    );

    final task = await ref.putData(bytes, metadata);
    final url = await task.ref.getDownloadURL();

    return {
      'attachmentName': fileName,
      'attachmentUrl': url,
      'attachmentPath': task.ref.fullPath,
      'attachmentContentType': contentType ?? 'application/octet-stream',
      'attachmentSize': bytes.length,
    };
  }

  Future<String> createAutoEcole({
    required String nom,
    required String ville,
    required String telephone,
    required String moniteurNom,
  }) async {
    final uid = _requireUser();
    final codeClasse = _generateClassCode();
    final autoEcoleRef = _db.collection('auto_ecoles').doc();

    await autoEcoleRef.set({
      'nom': nom.trim(),
      'ville': ville.trim(),
      'telephone': telephone.trim(),
      'codeClasse': codeClasse,
      'moniteurPrincipalUid': uid,
      'moniteurUids': [uid],
      'eleveUids': <String>[],
      'dateCreation': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('users').doc(uid).set({
      'role': 'moniteur',
      'autoEcoleId': autoEcoleRef.id,
      'autoEcoleNom': nom.trim(),
      'codeClasse': codeClasse,
      'displayName': moniteurNom.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return codeClasse;
  }

  Future<void> joinAutoEcoleByCode({
    required String codeClasse,
    required String nom,
    required String prenom,
    required Map<String, dynamic> stats,
  }) async {
    final uid = _requireUser();
    final normalizedCode = codeClasse.trim().toUpperCase();
    final snapshot = await _db
        .collection('auto_ecoles')
        .where('codeClasse', isEqualTo: normalizedCode)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('Code de classe introuvable.');
    }

    final autoEcoleDoc = snapshot.docs.first;
    final autoEcoleId = autoEcoleDoc.id;
    final autoEcoleData = autoEcoleDoc.data();
    final autoEcoleNom = autoEcoleData['nom'] as String? ?? '';
    final rawMonitorUids = autoEcoleData['moniteurUids'];
    final monitorUids = rawMonitorUids is List
        ? rawMonitorUids.whereType<String>().toList()
        : <String>[];
    final principalUid = autoEcoleData['moniteurPrincipalUid'] as String?;
    final linkedMonitorUids = monitorUids.isNotEmpty
        ? monitorUids
        : [if (principalUid != null) principalUid];
    final eleveData = {
      'uid': uid,
      'nom': nom.trim(),
      'prenom': prenom.trim(),
      'tauxReussite': stats['successRate'] ?? 0,
      'testsCount': stats['testsCount'] ?? 0,
      'fautesCount': stats['mistakesCount'] ?? 0,
      'heuresValidees': 0,
      'pointsFaibles': <String>[],
      'derniereActivite': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final batch = _db.batch();
    batch.set(
      _db.collection('users').doc(uid),
      {
        'role': 'eleve',
        'autoEcoleId': autoEcoleId,
        'autoEcoleNom': autoEcoleNom,
        'moniteurUids': linkedMonitorUids,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    batch.update(_db.collection('auto_ecoles').doc(autoEcoleId), {
      'eleveUids': FieldValue.arrayUnion([uid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(
      _db
          .collection('auto_ecoles')
          .doc(autoEcoleId)
          .collection('eleves')
          .doc(uid),
      eleveData,
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  Future<void> assignDevoir({
    required String autoEcoleId,
    required String eleveUid,
    required String titre,
    required String description,
    required String themeId,
    required String themeName,
    required int nombreQuestions,
    required DateTime dateLimite,
    required String moniteurNom,
    String sourceType = 'personnalise',
    String? sourceRef,
    Map<String, dynamic>? attachment,
  }) async {
    final uid = _requireUser();
    await _db.collection('devoirs').add({
      'autoEcoleId': autoEcoleId,
      'moniteurUid': uid,
      'moniteurNom': moniteurNom.trim(),
      'eleveUid': eleveUid,
      'titre': titre.trim(),
      'description': description.trim(),
      'themeId': themeId,
      'themeName': themeName.trim(),
      'nombreQuestions': nombreQuestions,
      'sourceType': sourceType,
      'sourceRef': sourceRef,
      ..._attachmentFields(attachment),
      'dateCreation': FieldValue.serverTimestamp(),
      'dateLimite': Timestamp.fromDate(dateLimite),
      'statut': 'en_attente',
      'scoreObtenu': null,
      'dateCompletion': null,
    });
  }

  Future<void> assignLesson({
    required String autoEcoleId,
    required String eleveUid,
    required String titre,
    required String type,
    required String description,
    required String objectifs,
    required int dureeMinutes,
    required DateTime dateLimite,
    required String moniteurNom,
    String sourceType = 'personnalisee',
    String? sourceRef,
    Map<String, dynamic>? attachment,
  }) async {
    final uid = _requireUser();
    final lessonRef = await _db.collection('lecons_assignees').add({
      'autoEcoleId': autoEcoleId,
      'moniteurUid': uid,
      'moniteurNom': moniteurNom.trim(),
      'eleveUid': eleveUid,
      'titre': titre.trim(),
      'type': type.trim(),
      'description': description.trim(),
      'objectifs': objectifs.trim(),
      'dureeMinutes': dureeMinutes,
      'sourceType': sourceType,
      'sourceRef': sourceRef,
      ..._attachmentFields(attachment),
      'statut': 'envoyee',
      'dateCreation': FieldValue.serverTimestamp(),
      'dateLimite': Timestamp.fromDate(dateLimite),
      'dateVue': null,
      'dateCompletion': null,
    });

    await _db.collection('notifications').add({
      'userUid': eleveUid,
      'type': 'lesson_assigned',
      'lessonId': lessonRef.id,
      'autoEcoleId': autoEcoleId,
      'title': 'Nouvelle lecon assignee',
      'message':
          '${moniteurNom.trim().isEmpty ? 'Ton moniteur' : moniteurNom.trim()} t a envoye: ${titre.trim()}.',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateAssignedLessonStatus({
    required String lessonId,
    required String statut,
  }) async {
    final update = <String, dynamic>{
      'statut': statut,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (statut == 'vue') {
      update['dateVue'] = FieldValue.serverTimestamp();
    }
    if (statut == 'terminee') {
      update['dateCompletion'] = FieldValue.serverTimestamp();
    }
    await _db.collection('lecons_assignees').doc(lessonId).set(
          update,
          SetOptions(merge: true),
        );
  }

  Future<void> createLesson({
    required String autoEcoleId,
    required String titre,
    required String type,
    required int dureeMinutes,
    required String objectifs,
    String description = '',
    bool predefined = false,
    String source = 'creation',
    Map<String, dynamic>? attachment,
  }) async {
    final uid = _requireUser();
    await _db
        .collection('auto_ecoles')
        .doc(autoEcoleId)
        .collection('catalogue_lecons')
        .add({
      'titre': titre.trim(),
      'type': type.trim(),
      'dureeMinutes': dureeMinutes,
      'description': description.trim(),
      'objectifs': objectifs.trim(),
      'standardVersion': 1,
      ..._attachmentFields(attachment),
      'predefined': predefined,
      'source': source,
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> createHomeworkTemplate({
    required String autoEcoleId,
    required String titre,
    required String description,
    required String themeId,
    required String themeName,
    required int nombreQuestions,
    required int delaiJours,
    bool predefined = false,
    String source = 'creation',
    Map<String, dynamic>? attachment,
  }) async {
    final uid = _requireUser();
    await _db
        .collection('auto_ecoles')
        .doc(autoEcoleId)
        .collection('catalogue_devoirs')
        .add({
      'titre': titre.trim(),
      'description': description.trim(),
      'themeId': themeId,
      'themeName': themeName.trim(),
      'nombreQuestions': nombreQuestions,
      'delaiJours': delaiJours,
      'standardVersion': 1,
      ..._attachmentFields(attachment),
      'predefined': predefined,
      'source': source,
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<int> importPredefinedHomeworks(String autoEcoleId) async {
    final uid = _requireUser();
    final catalogRef = _db
        .collection('auto_ecoles')
        .doc(autoEcoleId)
        .collection('catalogue_devoirs');
    final existing =
        await catalogRef.where('predefined', isEqualTo: true).get();
    final existingTitles = existing.docs
        .map((doc) => (doc.data()['titre'] as String? ?? '').toLowerCase())
        .toSet();
    final batch = _db.batch();
    var importedCount = 0;

    for (final homework in _predefinedHomeworks) {
      final title = homework['titre'] as String;
      if (existingTitles.contains(title.toLowerCase())) continue;
      batch.set(catalogRef.doc(), {
        ...homework,
        'standardVersion': 1,
        ..._attachmentFields(null),
        'predefined': true,
        'source': 'standard',
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      importedCount++;
    }

    if (importedCount > 0) {
      await batch.commit();
    }
    return importedCount;
  }

  Future<int> importHomeworksFromText({
    required String autoEcoleId,
    required String rawText,
  }) async {
    final uid = _requireUser();
    final rows = rawText
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (rows.isEmpty) return 0;

    final batch = _db.batch();
    final catalogRef = _db
        .collection('auto_ecoles')
        .doc(autoEcoleId)
        .collection('catalogue_devoirs');
    var importedCount = 0;

    for (final row in rows) {
      final parts = row.split(';').map((part) => part.trim()).toList();
      if (parts.first.toLowerCase() == 'titre') continue;
      final titre = parts.isNotEmpty ? parts[0] : '';
      if (titre.isEmpty) continue;
      final themeName =
          parts.length > 1 && parts[1].isNotEmpty ? parts[1] : 'Circulation';
      final questionCount = parts.length > 2 ? int.tryParse(parts[2]) : null;
      final deadlineDays = parts.length > 3 ? int.tryParse(parts[3]) : null;
      final description = parts.length > 4 ? parts.sublist(4).join('; ') : '';

      batch.set(catalogRef.doc(), {
        'titre': titre,
        'description': description,
        'themeId': _themeIdForName(themeName),
        'themeName': themeName,
        'nombreQuestions': questionCount ?? 20,
        'delaiJours': deadlineDays ?? 7,
        'standardVersion': 1,
        ..._attachmentFields(null),
        'predefined': false,
        'source': 'texte',
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      importedCount++;
    }

    if (importedCount > 0) {
      await batch.commit();
    }
    return importedCount;
  }

  Future<int> importPredefinedLessons(String autoEcoleId) async {
    final uid = _requireUser();
    final catalogRef = _db
        .collection('auto_ecoles')
        .doc(autoEcoleId)
        .collection('catalogue_lecons');
    final existing =
        await catalogRef.where('predefined', isEqualTo: true).get();
    final existingTitles = existing.docs
        .map((doc) => (doc.data()['titre'] as String? ?? '').toLowerCase())
        .toSet();
    final batch = _db.batch();
    var importedCount = 0;

    for (final lesson in _predefinedLessons) {
      final title = lesson['titre'] as String;
      if (existingTitles.contains(title.toLowerCase())) continue;
      batch.set(catalogRef.doc(), {
        ...lesson,
        'description': lesson['description'] as String? ?? '',
        'standardVersion': 1,
        ..._attachmentFields(null),
        'predefined': true,
        'source': 'standard',
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      importedCount++;
    }

    if (importedCount > 0) {
      await batch.commit();
    }
    return importedCount;
  }

  Future<int> importLessonsFromText({
    required String autoEcoleId,
    required String rawText,
  }) async {
    final uid = _requireUser();
    final rows = rawText
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (rows.isEmpty) return 0;

    final batch = _db.batch();
    final catalogRef = _db
        .collection('auto_ecoles')
        .doc(autoEcoleId)
        .collection('catalogue_lecons');
    var importedCount = 0;

    for (final row in rows) {
      final parts = row.split(';').map((part) => part.trim()).toList();
      if (parts.first.toLowerCase() == 'titre') continue;
      final titre = parts.isNotEmpty ? parts[0] : '';
      if (titre.isEmpty) continue;
      final type =
          parts.length > 1 && parts[1].isNotEmpty ? parts[1] : 'conduite';
      final duration = parts.length > 2 ? int.tryParse(parts[2]) : null;
      final objectifs = parts.length > 3 ? parts.sublist(3).join('; ') : '';

      batch.set(catalogRef.doc(), {
        'titre': titre,
        'type': type,
        'dureeMinutes': duration ?? 60,
        'description': '',
        'objectifs': objectifs,
        'standardVersion': 1,
        ..._attachmentFields(null),
        'predefined': false,
        'source': 'texte',
        'createdBy': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      importedCount++;
    }

    if (importedCount > 0) {
      await batch.commit();
    }
    return importedCount;
  }

  Future<void> requestReservation({
    required String autoEcoleId,
    required String eleveNom,
    required DateTime dateHeure,
    required int dureeMinutes,
    required String typeLecon,
    String? moniteurUid,
  }) async {
    final uid = _requireUser();
    List<String> monitorUids = moniteurUid == null ? <String>[] : [moniteurUid];

    try {
      final userDoc = await _db.collection('users').doc(uid).get();
      final rawProfileMonitorUids = userDoc.data()?['moniteurUids'];
      if (rawProfileMonitorUids is List && rawProfileMonitorUids.isNotEmpty) {
        monitorUids = rawProfileMonitorUids.whereType<String>().toList();
      }
    } catch (_) {
      // Keep trying with the auto-ecole document below.
    }

    try {
      final autoEcole =
          await _db.collection('auto_ecoles').doc(autoEcoleId).get();
      final data = autoEcole.data();
      final rawMonitorUids = data?['moniteurUids'];
      if (rawMonitorUids is List) {
        monitorUids = rawMonitorUids.whereType<String>().toList();
      }
    } catch (_) {
      // The reservation can still be created; notification may be unavailable.
    }

    if (monitorUids.isEmpty) {
      throw Exception(
          'Aucun moniteur lie a cette auto-ecole. Demande non envoyee.');
    }

    final reservationRef = await _db.collection('reservations').add({
      'autoEcoleId': autoEcoleId,
      'eleveUid': uid,
      'eleveNom': eleveNom.trim(),
      'moniteurUid': moniteurUid,
      'moniteurUids': monitorUids,
      'dateHeure': Timestamp.fromDate(dateHeure),
      'dureeMinutes': dureeMinutes,
      'typeLecon': typeLecon,
      'statut': 'en_attente',
      'dateCreation': FieldValue.serverTimestamp(),
    });

    try {
      for (final monitorUid in monitorUids) {
        await _db.collection('notifications').add({
          'userUid': monitorUid,
          'type': 'reservation_request',
          'reservationId': reservationRef.id,
          'autoEcoleId': autoEcoleId,
          'title': 'Nouvelle demande de lecon',
          'message':
              '${eleveNom.trim().isEmpty ? 'Un eleve' : eleveNom.trim()} demande une lecon $typeLecon de $dureeMinutes min.',
          'read': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (_) {
      // The reservation is the critical operation; notification can be retried
      // by the UI flow or server rules later.
    }
  }

  Future<void> updateReservationStatus({
    required String reservationId,
    required String statut,
  }) async {
    final reservationRef = _db.collection('reservations').doc(reservationId);
    final reservation = await reservationRef.get();
    final data = reservation.data();
    final eleveUid = data?['eleveUid'] as String?;
    final typeLecon = data?['typeLecon'] as String? ?? 'lecon';
    final statusLabel = statut == 'confirme' ? 'confirmee' : 'annulee';

    await reservationRef.set({
      'statut': statut,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (eleveUid == null || eleveUid.isEmpty) return;

    await _db.collection('notifications').add({
      'userUid': eleveUid,
      'type': 'reservation',
      'reservationId': reservationId,
      'title': 'Demande de lecon $statusLabel',
      'message': 'Ta demande de $typeLecon a ete $statusLabel par le moniteur.',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<int> repairLegacyReservationsForMonitor(String autoEcoleId) async {
    final uid = _requireUser();
    final autoEcole =
        await _db.collection('auto_ecoles').doc(autoEcoleId).get();
    final data = autoEcole.data();
    if (data == null) return 0;

    final rawMonitorUids = data['moniteurUids'];
    final monitorUids = rawMonitorUids is List
        ? rawMonitorUids.whereType<String>().toList()
        : <String>[];
    final principalUid = data['moniteurPrincipalUid'] as String?;
    final linkedMonitorUids = monitorUids.isNotEmpty
        ? monitorUids
        : [if (principalUid != null) principalUid];

    if (!linkedMonitorUids.contains(uid)) {
      throw Exception('Ce compte n est pas moniteur de cette auto-ecole.');
    }

    final snapshot = await _db
        .collection('reservations')
        .where('autoEcoleId', isEqualTo: autoEcoleId)
        .get();

    var repairedCount = 0;
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      final reservation = doc.data();
      final rawReservationMonitors = reservation['moniteurUids'];
      final reservationMonitors = rawReservationMonitors is List
          ? rawReservationMonitors.whereType<String>().toList()
          : <String>[];

      if (reservationMonitors.isEmpty || !reservationMonitors.contains(uid)) {
        batch.set(
          doc.reference,
          {
            'moniteurUids': FieldValue.arrayUnion(linkedMonitorUids),
            'moniteurUid': reservation['moniteurUid'] ?? uid,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        repairedCount++;
      }
    }

    if (repairedCount > 0) {
      await batch.commit();
    }
    return repairedCount;
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).set({
      'read': true,
      'readAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> validateDrivingHours({
    required String autoEcoleId,
    required String eleveUid,
    required int dureeMinutes,
    required DateTime date,
    required String remarques,
    required List<String> competencesValidees,
    required int noteGenerale,
  }) async {
    final moniteurUid = _requireUser();
    final batch = _db.batch();
    final heureRef = _db.collection('heures_conduite').doc();
    batch.set(heureRef, {
      'autoEcoleId': autoEcoleId,
      'eleveUid': eleveUid,
      'moniteurUid': moniteurUid,
      'date': Timestamp.fromDate(date),
      'dureeMinutes': dureeMinutes,
      'remarques': remarques.trim(),
      'competencesValidees': competencesValidees,
      'noteGenerale': noteGenerale,
      'dateCreation': FieldValue.serverTimestamp(),
    });
    batch.set(
      _db
          .collection('auto_ecoles')
          .doc(autoEcoleId)
          .collection('eleves')
          .doc(eleveUid),
      {
        'heuresValidees': FieldValue.increment(dureeMinutes / 60),
        'derniereActivite': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  Future<void> syncStudentProgress({
    required String uid,
    required Map<String, dynamic> stats,
  }) async {
    final userDoc = await _db.collection('users').doc(uid).get();
    final userData = userDoc.data();
    final autoEcoleId = userData?['autoEcoleId'] as String?;
    if (autoEcoleId == null || autoEcoleId.isEmpty) return;

    await _db
        .collection('auto_ecoles')
        .doc(autoEcoleId)
        .collection('eleves')
        .doc(uid)
        .set({
      'tauxReussite': stats['successRate'] ?? 0,
      'testsCount': stats['testsCount'] ?? 0,
      'fautesCount': stats['mistakesCount'] ?? 0,
      'derniereActivite': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String _requireUser() {
    final uid = currentUid;
    if (uid == null) {
      throw Exception('Utilisateur non connecte.');
    }
    return uid;
  }

  String _generateClassCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Map<String, dynamic> _attachmentFields(Map<String, dynamic>? attachment) {
    final url = attachment?['attachmentUrl'] as String?;
    if (url == null || url.trim().isEmpty) {
      return {
        'hasAttachment': false,
        'attachmentName': null,
        'attachmentUrl': null,
        'attachmentPath': null,
        'attachmentContentType': null,
        'attachmentSize': null,
      };
    }

    return {
      'hasAttachment': true,
      'attachmentName': attachment?['attachmentName'] as String? ?? 'Document',
      'attachmentUrl': url,
      'attachmentPath': attachment?['attachmentPath'] as String?,
      'attachmentContentType':
          attachment?['attachmentContentType'] as String? ??
              'application/octet-stream',
      'attachmentSize': attachment?['attachmentSize'] as int?,
    };
  }

  String _sanitizeStorageSegment(String value) {
    final sanitized = value
        .trim()
        .replaceAll(RegExp(r'[\\/#?%*:|"<>]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
    if (sanitized.isEmpty) return 'document';
    return sanitized.length > 96 ? sanitized.substring(0, 96) : sanitized;
  }

  String _themeIdForName(String themeName) {
    final normalized = themeName.trim().toLowerCase();
    if (normalized.contains('conducteur')) return '2';
    if (normalized.contains('route')) return '3';
    return '1';
  }

  static const List<Map<String, dynamic>> _predefinedLessons = [
    {
      'titre': 'Installation au poste de conduite',
      'type': 'conduite',
      'dureeMinutes': 60,
      'description': 'Standard commun pour verifier installation, visibilite et commandes.',
      'objectifs': 'Reglages, commandes, controles avant depart.',
    },
    {
      'titre': 'Demarrage et arret en securite',
      'type': 'conduite',
      'dureeMinutes': 60,
      'description': 'Standard commun pour travailler depart, arret et maitrise basse vitesse.',
      'objectifs': 'Point de patinage, freinage doux, observation.',
    },
    {
      'titre': 'Gestion des intersections',
      'type': 'conduite',
      'dureeMinutes': 90,
      'description': 'Standard commun pour traiter les intersections simples et complexes.',
      'objectifs': 'Priorites, allure, placement et controles.',
    },
    {
      'titre': 'Stationnement en bataille',
      'type': 'manoeuvre',
      'dureeMinutes': 45,
      'description': 'Standard commun pour pratiquer une manoeuvre courte et repetitive.',
      'objectifs': 'Trajectoire, reperes, securite autour du vehicule.',
    },
    {
      'titre': 'Creneau et demi-tour',
      'type': 'manoeuvre',
      'dureeMinutes': 60,
      'description': 'Standard commun pour enchainer observation, precision et correction.',
      'objectifs': 'Observation, precision, gestion du volant.',
    },
    {
      'titre': 'Circulation dense et autonomie',
      'type': 'conduite',
      'dureeMinutes': 90,
      'description': 'Standard commun pour renforcer decisions autonomes en trafic dense.',
      'objectifs': 'Anticipation, decisions, adaptation aux usagers.',
    },
  ];

  static const List<Map<String, dynamic>> _predefinedHomeworks = [
    {
      'titre': 'Revision priorites',
      'description': 'Revoir les intersections et les regles de priorite.',
      'themeId': '1',
      'themeName': 'Circulation',
      'nombreQuestions': 20,
      'delaiJours': 7,
    },
    {
      'titre': 'Controle conducteur',
      'description': 'Travailler vigilance, fatigue et prise de decision.',
      'themeId': '2',
      'themeName': 'Conducteur',
      'nombreQuestions': 15,
      'delaiJours': 5,
    },
    {
      'titre': 'Lecture de route',
      'description': 'Identifier les dangers, adapter allure et distances.',
      'themeId': '3',
      'themeName': 'Route',
      'nombreQuestions': 25,
      'delaiJours': 7,
    },
    {
      'titre': 'Preparation examen blanc',
      'description': 'Serie complete pour verifier les acquis avant examen.',
      'themeId': '1',
      'themeName': 'Circulation',
      'nombreQuestions': 40,
      'delaiJours': 10,
    },
  ];
}

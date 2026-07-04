import 'session.dart';


class BuildSessionResult {
  const BuildSessionResult({required this.session, required this.newCursor});

  final Session session;
  final int newCursor;

  factory BuildSessionResult.fromJson(Map<String, dynamic> j) => BuildSessionResult(
        session: Session.fromJson(j['session'] as Map<String, dynamic>),
        newCursor: j['newCursor'] as int,
      );
}

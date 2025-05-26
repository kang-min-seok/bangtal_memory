import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../hive/escape_record.dart';
import '../hive/genre_list.dart';

class QrImportPage extends StatefulWidget {
  const QrImportPage({super.key});

  @override
  State<QrImportPage> createState() => _QrImportPageState();
}

class _QrImportPageState extends State<QrImportPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  final List<String?> _chunks = [];   // 인덱스 0…n-1
  int _total = 0;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Theme.of(context).colorScheme.background,
          title: const Text('QR 코드로 복원')
      ),
      body: QRView(
        key: qrKey,
        formatsAllowed: const [BarcodeFormat.qrcode],
        onQRViewCreated: (ctrl) {
          controller = ctrl;
          ctrl.scannedDataStream.listen(_onScan);
        },
        overlay: QrScannerOverlayShape(                // 가이드 프레임
          borderColor: Theme.of(context).primaryColor,
          borderRadius: 12,
          borderLength: 30,
          borderWidth: 6,
          cutOutSize: MediaQuery.of(context).size.width * 0.75,
        ),
        onPermissionSet: (ctrl, permissionGranted) {
          if (!permissionGranted) {
            // 권한 거부 시 안내 다이얼로그
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('카메라 권한 필요'),
                content: const Text('QR 코드를 스캔하려면 카메라 권한을 허용해 주세요.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('확인'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // TODO 가져올때 첫번째 qr인식 성공했으면 첫번째 qr은 더이상 인식하지 않게끔 하기
  // 만약 또 똑같은걸 인식했다면 토스트 메세지로 다음 qr찍어달라고 하기
  void _onScan(Barcode scan) async {
    final text = scan.code ?? '';
    // 포맷: "순번/총개|payload"
    final parts = text.split('|');
    if (parts.length != 2) return;

    final header = parts[0].split('/');
    if (header.length != 2) return;

    final idx   = int.tryParse(header[0]) ?? 0;
    final total = int.tryParse(header[1]) ?? 0;
    if (idx == 0 || total == 0) return;

    // 배열 크기 확보
    if (_chunks.length != total) _chunks.length = total;
    _chunks[idx - 1] = parts[1];
    _total = total;

    // 진행 상황 안내
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('QR ${idx}/$total 스캔 완료')),
    );

    // 모두 스캔되면 복구
    if (_chunks.every((c) => c != null)) {
      controller?.pauseCamera();
      final merged = _chunks.join();
      await _restoreFromBase64(merged);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _restoreFromBase64(String b64) async {
    try {
      final gzBytes   = base64Decode(b64);
      final jsonBytes = GZipDecoder().decodeBytes(gzBytes);
      final map       = jsonDecode(utf8.decode(jsonBytes));

      await _importData(map);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('데이터 복원이 완료되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('복원 실패: $e')),
        );
      }
    }
  }

  Future<void> _importData(Map<String, dynamic> map) async {
    final recBox   = Hive.box<EscapeRecord>('escape_records');
    final genreBox = Hive.box<GenreList>('genreLists');

    await recBox.clear();
    await genreBox.clear();

    for (final g in map['genres']) {
      final obj = GenreList(id: 0, genre: g['genre'], colorValue: g['colorValue']);
      obj.id = await genreBox.add(obj);
      await obj.save();
    }

    for (final r in map['records']) {
      final obj = EscapeRecord(
        id:0, date:r['date'], storeName:r['storeName'], themeName:r['themeName'],
        difficulty:r['difficulty'], satisfaction:r['satisfaction'],
        genre:r['genre'], region:r['region'],
      );
      obj.id = await recBox.add(obj);
      await obj.save();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

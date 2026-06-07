import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mayone_app/theme/app_theme.dart';

/// 염색약 레벨 계산기.
///
/// 레벨이 다른 두 염색약(약1, 약2)을 섞어 원하는 레벨을 만들 때의
/// 혼합 비율과 실제 용량(g)을 계산한다.
///
/// 혼합 결과 레벨은 가중 평균을 따른다:
///   target = (a1 * l1 + a2 * l2) / (a1 + a2)
/// 이를 비율로 풀면:
///   a1 : a2 = (l2 - target) : (target - l1)
/// (a1 = 약1의 양, a2 = 약2의 양)
class ColorCal extends StatefulWidget {
  const ColorCal({super.key});

  @override
  State<ColorCal> createState() => _ColorCalState();
}

class _ColorCalState extends State<ColorCal> {
  final TextEditingController _level1 = TextEditingController();
  final TextEditingController _level2 = TextEditingController();
  final TextEditingController _vol1 = TextEditingController(text: '100');
  final TextEditingController _vol2 = TextEditingController();
  final TextEditingController _target = TextEditingController();

  bool _isUpdatingVolumes = false;

  /// 약1 : 약2 의 정수 비율(기약분수). 계산 불가 시 null.
  int? _ratio1;
  int? _ratio2;

  /// 입력이 유효하지 않을 때 사용자에게 보여줄 안내 문구.
  String? _error;

  bool get _hasRatio => _ratio1 != null && _ratio2 != null;

  @override
  void initState() {
    super.initState();
    _level1.addListener(_calculateRatio);
    _level2.addListener(_calculateRatio);
    _target.addListener(_calculateRatio);
    _vol1.addListener(_recalcFromVol1);
    _vol2.addListener(_recalcFromVol2);
  }

  @override
  void dispose() {
    _level1.dispose();
    _level2.dispose();
    _target.dispose();
    _vol1.dispose();
    _vol2.dispose();
    super.dispose();
  }

  // ─────────────────────────── 로직 ───────────────────────────

  void _calculateRatio() {
    final int? l1 = int.tryParse(_level1.text.trim());
    final int? l2 = int.tryParse(_level2.text.trim());
    final int? target = int.tryParse(_target.text.trim());

    // 아직 다 입력하지 않은 상태 → 결과/안내 모두 비움
    if (l1 == null || l2 == null || target == null) {
      _setRatio(null, null, error: null);
      return;
    }

    final int lo = math.min(l1, l2);
    final int hi = math.max(l1, l2);

    // 혼합으로는 두 레벨 "사이"의 값만 만들 수 있다.
    if (target < lo || target > hi) {
      _setRatio(
        null,
        null,
        error: '원하는 레벨은 약1·약2 레벨 사이($lo~$hi)여야 합니다.',
      );
      return;
    }

    // 두 약의 레벨이 같으면 어떤 비율로 섞어도 같은 레벨 → 비율 의미 없음.
    if (l1 == l2) {
      _setRatio(1, 1, error: null);
      return;
    }

    // a1 : a2 = (l2 - target) : (target - l1)
    // 범위 검증을 통과했으므로 두 값의 부호는 같다 → 절댓값으로 정규화.
    int r1 = (l2 - target).abs();
    int r2 = (target - l1).abs();

    final int divisor = _gcd(r1, r2);
    if (divisor > 0) {
      r1 ~/= divisor;
      r2 ~/= divisor;
    }

    _setRatio(r1, r2, error: null);
  }

  void _setRatio(int? r1, int? r2, {required String? error}) {
    setState(() {
      _ratio1 = r1;
      _ratio2 = r2;
      _error = error;
    });
    // 비율이 갱신되면 현재 vol1 기준으로 vol2를 다시 맞춘다.
    _recalcFromVol1();
  }

  void _recalcFromVol1() {
    if (_isUpdatingVolumes || !_hasRatio) return;

    final double? v1 = double.tryParse(_vol1.text);

    _isUpdatingVolumes = true;
    try {
      if (v1 == null) {
        _vol2.text = '';
      } else if (_ratio1 == 0) {
        // 약1을 쓰지 않는 조합 → 약1 용량은 항상 0.
        _vol1.text = '0';
        _vol1.selection =
            const TextSelection.collapsed(offset: 1); // '0' 뒤로 커서 이동
      } else {
        _vol2.text = (v1 * _ratio2! / _ratio1!).toStringAsFixed(1);
      }
    } finally {
      _isUpdatingVolumes = false;
    }
    // 총 용량 표시는 build()에서 컨트롤러 값을 읽어 계산하므로,
    // 용량이 바뀌면 부모 위젯을 다시 그려 줘야 한다.
    if (mounted) setState(() {});
  }

  void _recalcFromVol2() {
    if (_isUpdatingVolumes || !_hasRatio) return;

    final double? v2 = double.tryParse(_vol2.text);

    _isUpdatingVolumes = true;
    try {
      if (v2 == null) {
        _vol1.text = '';
      } else if (_ratio2 == 0) {
        // 약2를 쓰지 않는 조합 → 약2 용량은 항상 0.
        _vol2.text = '0';
        _vol2.selection = const TextSelection.collapsed(offset: 1);
      } else {
        _vol1.text = (v2 * _ratio1! / _ratio2!).toStringAsFixed(1);
      }
    } finally {
      _isUpdatingVolumes = false;
    }
    if (mounted) setState(() {});
  }

  static int _gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final int t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  /// 약1 + 약2 총 용량(둘 다 유효할 때만).
  double? get _totalVolume {
    final double? v1 = double.tryParse(_vol1.text);
    final double? v2 = double.tryParse(_vol2.text);
    if (v1 == null || v2 == null) return null;
    return v1 + v2;
  }

  // ─────────────────────────── UI ───────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        const _SectionTitle(
          title: '염색약 레벨 계산기',
          subtitle: '레벨이 다른 두 약을 섞어 원하는 레벨을 만들어요',
        ),
        const SizedBox(height: 20),
        _buildLevelCard(),
        const SizedBox(height: 16),
        _buildResultCard(),
        const SizedBox(height: 16),
        _buildVolumeCard(),
        const SizedBox(height: 20),
        _buildHint(),
      ],
    );
  }

  Widget _buildLevelCard() {
    return _CardSection(
      heading: '약 레벨 입력',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _LabeledField(
                  label: '약 1',
                  controller: _level1,
                  hint: '레벨',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LabeledField(
                  label: '약 2',
                  controller: _level2,
                  hint: '레벨',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _LabeledField(
            label: '원하는 레벨',
            controller: _target,
            hint: '목표 레벨',
            accent: true,
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final Widget content;
    if (_error != null) {
      content = Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.warning, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    } else if (_hasRatio) {
      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ratioChip('약 1', _ratio1!),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              ':',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.coffee,
              ),
            ),
          ),
          _ratioChip('약 2', _ratio2!),
        ],
      );
    } else {
      content = const Text(
        '약 1·약 2·원하는 레벨을 입력하면\n혼합 비율이 표시됩니다.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.muted, height: 1.4),
      );
    }

    return _CardSection(
      heading: '혼합 비율',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Center(child: content),
      ),
    );
  }

  Widget _ratioChip(String label, int value) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: AppColors.brown,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildVolumeCard() {
    final double? total = _totalVolume;
    return _CardSection(
      heading: '용량 계산 (g)',
      trailing: total != null
          ? Text(
              '총 ${total.toStringAsFixed(1)}g',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            )
          : null,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _LabeledField(
                  label: '약 1 용량',
                  controller: _vol1,
                  hint: 'g',
                  allowDecimal: true,
                  enabled: _hasRatio,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LabeledField(
                  label: '약 2 용량',
                  controller: _vol2,
                  hint: 'g',
                  allowDecimal: true,
                  enabled: _hasRatio,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _hasRatio
                ? '한쪽 용량을 입력하면 다른 쪽이 자동으로 계산돼요.'
                : '먼저 위에서 레벨을 입력해 주세요.',
            style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildHint() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tan),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.accent, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '같은 컬러(색조)일 때만 계산이 정확합니다.\n레벨 숫자만 입력해 주세요.',
              style: TextStyle(color: AppColors.coffee, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── 재사용 위젯 ───────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.brown,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({
    required this.heading,
    required this.child,
    this.trailing,
  });

  final String heading;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  heading,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.coffee,
                    letterSpacing: 0.5,
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.hint,
    this.accent = false,
    this.allowDecimal = false,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool accent;
  final bool allowDecimal;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: accent ? AppColors.accent : AppColors.coffee,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
          textAlign: TextAlign.center,
          inputFormatters: [
            allowDecimal
                ? FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                : FilteringTextInputFormatter.digitsOnly,
          ],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.brown,
          ),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

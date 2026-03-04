import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class QuestionDetailScreen extends StatefulWidget {
  final String questionId;
  const QuestionDetailScreen({super.key, required this.questionId});

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  final _answerController = TextEditingController();
  bool _submittingAnswer = false;

  // Demo data
  final _question = {
    'title': 'When is the best time to apply DAP fertilizer for rice?',
    'body': 'I am growing rice in kharif season in Telangana. My soil is clay-loam. I want to understand the best schedule for applying DAP fertilizer. Should I apply at transplanting or later? How much per acre?',
    'author': 'Ramesh K',
    'votes': 12,
    'tags': ['Fertilizers', 'Rice'],
    'createdAt': '2 hours ago',
  };

  final List<Map<String, dynamic>> _answers = [
    {
      'id': '1',
      'body': 'For rice, DAP should be applied at the time of transplanting as a basal dose. Recommended dose is 50 kg/acre. Mix it well with the soil before transplanting. Apply in splits – half at transplanting and half at tillering stage.',
      'author': 'Dr. Suresh A (Agriculture Officer)',
      'votes': 8,
      'isAccepted': true,
      'createdAt': '1h ago',
    },
    {
      'id': '2',
      'body': 'I recommend the 4-split application method: 25% at basal, 25% at active tillering, 25% at panicle initiation, and 25% at flowering. This gives better results in my experience.',
      'author': 'Lakshmi P (Farmer, 15 yrs)',
      'votes': 5,
      'isAccepted': false,
      'createdAt': '45m ago',
    },
    {
      'id': '3',
      'body': 'Before applying DAP, get a soil test done. Your soil might already have enough phosphorus. Over-application can harm the crop.',
      'author': 'Bala R',
      'votes': 3,
      'isAccepted': false,
      'createdAt': '30m ago',
    },
  ];

  int _questionVotes = 12;
  final Map<String, int> _answerVotes = {};

  @override
  void initState() {
    super.initState();
    for (final a in _answers) {
      _answerVotes[a['id'] as String] = a['votes'] as int;
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _submitAnswer() async {
    if (_answerController.text.trim().isEmpty) return;
    setState(() => _submittingAnswer = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _answers.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'body': _answerController.text.trim(),
          'author': 'You',
          'votes': 0,
          'isAccepted': false,
          'createdAt': 'Just now',
        });
        _answerVotes[_answers.last['id'] as String] = 0;
        _answerController.clear();
        _submittingAnswer = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Question')),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Question
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gray100),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_question['title'] as String,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gray800)),
                  const SizedBox(height: 8),
                  Text(_question['body'] as String,
                      style: const TextStyle(fontSize: 13, color: AppColors.gray600, height: 1.5)),
                  const SizedBox(height: 12),

                  // Tags
                  Wrap(spacing: 6, children: [
                    ...(_question['tags'] as List).map((t) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.brand50, borderRadius: BorderRadius.circular(20)),
                      child: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.brand700)),
                    )),
                  ]),
                  const SizedBox(height: 12),

                  // Footer
                  Row(children: [
                    // Vote
                    _VoteWidget(
                      count: _questionVotes,
                      onUp: () => setState(() => _questionVotes++),
                      onDown: () => setState(() { if (_questionVotes > 0) _questionVotes--; }),
                    ),
                    const Spacer(),
                    Text(_question['author'] as String,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.brand600)),
                    const Text(' · ', style: TextStyle(color: AppColors.gray300)),
                    Text(_question['createdAt'] as String, style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
                  ]),
                ]),
              ),
              const SizedBox(height: 20),

              // Answers header
              Text('${_answers.length} Answers',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gray700)),
              const SizedBox(height: 12),

              // Answers list
              ..._answers.map((a) {
                final id = a['id'] as String;
                final accepted = a['isAccepted'] as bool;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: accepted ? AppColors.green50 : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: accepted ? AppColors.green200 : AppColors.gray100),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (accepted)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.green100, borderRadius: BorderRadius.circular(20)),
                        child: const Text('✅ Accepted Answer',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.green700)),
                      ),
                    Text(a['body'] as String, style: const TextStyle(fontSize: 13, color: AppColors.gray600, height: 1.5)),
                    const SizedBox(height: 10),
                    Row(children: [
                      _VoteWidget(
                        count: _answerVotes[id] ?? 0,
                        onUp: () => setState(() => _answerVotes[id] = (_answerVotes[id] ?? 0) + 1),
                        onDown: () => setState(() { if ((_answerVotes[id] ?? 0) > 0) _answerVotes[id] = _answerVotes[id]! - 1; }),
                      ),
                      const Spacer(),
                      Text(a['author'] as String,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.brand600)),
                      const Text(' · ', style: TextStyle(color: AppColors.gray300)),
                      Text(a['createdAt'] as String, style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
                    ]),
                  ]),
                );
              }),
              const SizedBox(height: 20),
            ]),
          ),
        ),

        // Answer input
        Container(
          padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.gray100)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, -2))],
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _answerController,
                decoration: const InputDecoration(hintText: 'Write an answer...', contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _submittingAnswer ? null : _submitAnswer,
              child: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: AppColors.brand600, borderRadius: BorderRadius.circular(12)),
                child: _submittingAnswer
                    ? const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _VoteWidget extends StatelessWidget {
  final int count;
  final VoidCallback onUp;
  final VoidCallback onDown;
  const _VoteWidget({required this.count, required this.onUp, required this.onDown});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      GestureDetector(
        onTap: onUp,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: AppColors.brand50, borderRadius: BorderRadius.circular(6)),
          child: const Icon(Icons.arrow_upward_rounded, size: 16, color: AppColors.brand600),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text('$count', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray700)),
      ),
      GestureDetector(
        onTap: onDown,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(6)),
          child: const Icon(Icons.arrow_downward_rounded, size: 16, color: AppColors.gray400),
        ),
      ),
    ]);
  }
}

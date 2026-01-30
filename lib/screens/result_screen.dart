import 'dart:io';
import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;
  const ResultScreen({super.key, required this.imagePath});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String result = "Analyzing...";
  bool isLoading = true;
  Map<String, dynamic> medicalInfo = {};

  @override
  void initState() {
    super.initState();
    runAI();
  }

  Future<void> runAI() async {
    try {
      print("🔍 Starting analysis for: ${widget.imagePath}");
      
      final prediction = await AiService().predict(File(widget.imagePath));
      
      if (!mounted) return;

      // Replace "normal" or "normal skin" with "No disease detected"
      String displayResult = prediction;
      String normalizedPrediction = prediction.toLowerCase().trim();
      if (normalizedPrediction == 'normal' || 
          normalizedPrediction == 'normal skin' ||  normalizedPrediction.contains('normal_skin')
       ) {
        displayResult = "No disease detected";
      }

      setState(() {
        result = displayResult;
        medicalInfo = _getMedicalInfo(prediction);
        isLoading = false;
      });
      
      print("✅ Analysis complete: $prediction");
    } catch (e, stackTrace) {
      print("❌ Analysis error: $e");
      print("📍 Stack trace: $stackTrace");
      
      if (!mounted) return;

      setState(() {
        result = "Analysis failed: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  /// 🏥 OFFLINE MEDICAL KNOWLEDGE BASE
  /// Returns precautions, treatments, and suggestions based on disease type
  Map<String, dynamic> _getMedicalInfo(String disease) {
    // Normalize the disease name for matching
    final normalizedDisease = disease.toLowerCase().trim();
    
    // 📚 Comprehensive offline medical database
    final Map<String, Map<String, dynamic>> medicalDatabase = {
      'acne': {
        'severity': 'Mild to Moderate',
        'description': 'Common skin condition causing pimples, blackheads, and inflamed bumps',
        'precautions': [
          'Wash face twice daily with gentle cleanser',
          'Avoid touching or picking at acne',
          'Remove makeup before sleeping',
          'Use oil-free, non-comedogenic products',
          'Keep hair clean and away from face',
          'Change pillowcases regularly',
        ],
        'treatments': [
          'Benzoyl Peroxide 2.5-5% (gel/cream)',
          'Salicylic Acid wash or gel',
          'Adapalene 0.1% gel (OTC retinoid)',
          'Niacinamide serum',
          'Tea tree oil (diluted)',
        ],
        'suggestions': [
          'Avoid greasy or oily foods',
          'Stay hydrated (8-10 glasses water daily)',
          'Manage stress through exercise/meditation',
          'Get adequate sleep (7-8 hours)',
          'Consider dietary triggers (dairy, sugar)',
        ],
        'whenToSeeDoctor': [
          'Severe or cystic acne',
          'Scarring or dark spots',
          'No improvement after 8-12 weeks',
          'Painful nodules or cysts',
        ],
      },
      
      'eczema': {
        'severity': 'Mild to Severe',
        'description': 'Inflammatory skin condition causing dry, itchy, and inflamed patches',
        'precautions': [
          'Moisturize skin 2-3 times daily',
          'Take short, lukewarm showers (not hot)',
          'Use fragrance-free, hypoallergenic products',
          'Wear soft, breathable cotton clothing',
          'Avoid harsh soaps and detergents',
          'Use humidifier in dry environments',
        ],
        'treatments': [
          'Hydrocortisone cream 1% (OTC)',
          'Cetaphil or CeraVe moisturizing cream',
          'Colloidal oatmeal baths',
          'Petroleum jelly (Vaseline)',
          'Antihistamines for itching (Cetirizine)',
        ],
        'suggestions': [
          'Identify and avoid triggers (stress, allergens)',
          'Keep nails short to prevent scratching',
          'Apply cold compress for itch relief',
          'Wear gloves when using cleaning products',
          'Manage stress levels',
        ],
        'whenToSeeDoctor': [
          'Severe itching affecting sleep',
          'Signs of infection (pus, fever)',
          'Widespread rash or worsening symptoms',
          'No improvement with OTC treatments',
        ],
      },
      
      'psoriasis': {
        'severity': 'Moderate to Severe',
        'description': 'Chronic autoimmune condition causing thick, scaly skin patches',
        'precautions': [
          'Keep skin well-moisturized daily',
          'Avoid skin injuries (cuts, scrapes)',
          'Limit alcohol consumption',
          'Quit smoking',
          'Manage stress effectively',
          'Avoid very hot water',
        ],
        'treatments': [
          'Coal tar ointment or shampoo',
          'Salicylic acid cream',
          'Thick moisturizers (CeraVe, Eucerin)',
          'Hydrocortisone cream 1%',
          'Vitamin D analogs (consult doctor)',
        ],
        'suggestions': [
          'Get moderate sunlight exposure (10-15 min)',
          'Take lukewarm oatmeal baths',
          'Use gentle, fragrance-free products',
          'Maintain healthy weight',
          'Consider anti-inflammatory diet',
        ],
        'whenToSeeDoctor': [
          'Covers large body areas',
          'Joint pain or swelling',
          'Severe discomfort or disability',
          'OTC treatments ineffective',
        ],
      },

      "ringworm": {
        'severity': 'Mild to Moderate',
        'description': 'Fungal infection causing red, ring-shaped rash with clear center',
        'precautions': [
          'Keep affected area clean and dry',
          'Avoid sharing personal items (towels, clothing)',
          'Wear loose-fitting, breathable clothing',
          'Change socks and underwear daily',
          'Disinfect surfaces and items regularly',
        ],
        'treatments': [
          'Clotrimazole cream 1%',
          'Miconazole cream or spray',
          'Terbinafine cream (Lamisil)',
          'Tolnaftate powder',
          'Complete full treatment course (2-4 weeks)',
        ],
        'suggestions': [
          'Avoid scratching the rash',
          'Use antifungal powder in shoes',
          'Wear sandals in public showers',
          'Boost immune system with healthy diet',
        ],
        'whenToSeeDoctor': [
          'No improvement after 2 weeks',
          'Spreading to other areas',
          'Severe pain or discharge',
          'Diabetic with fungal infection',
        ],
      },
      
      'melanoma': {
        'severity': 'SERIOUS - Requires Immediate Medical Attention',
        'description': 'Serious form of skin cancer that can spread rapidly',
        'precautions': [
          '⚠️ SEE A DERMATOLOGIST IMMEDIATELY',
          'Do not attempt self-treatment',
          'Protect from sun exposure',
          'Document any changes with photos',
          'Check entire body for similar spots',
        ],
        'treatments': [
          '🚨 MEDICAL EMERGENCY - No OTC treatment',
          'Requires professional medical evaluation',
          'Early detection is critical',
          'Surgical removal may be necessary',
        ],
        'suggestions': [
          'Schedule dermatology appointment TODAY',
          'Use broad-spectrum SPF 50+ sunscreen',
          'Avoid tanning beds completely',
          'Perform monthly self-skin checks',
          'Bring list of questions to appointment',
        ],
        'whenToSeeDoctor': [
          '🚨 IMMEDIATELY - This is urgent',
          'Any suspicious mole or growth',
          'ABCDE signs: Asymmetry, Border, Color, Diameter, Evolving',
        ],
      },
      
      'rosacea': {
        'severity': 'Mild to Moderate',
        'description': 'Chronic skin condition causing facial redness and visible blood vessels',
        'precautions': [
          'Identify and avoid personal triggers',
          'Use gentle, fragrance-free skincare',
          'Avoid hot beverages and spicy foods',
          'Protect face from extreme temperatures',
          'Use sunscreen daily (SPF 30+)',
          'Avoid alcohol-based products',
        ],
        'treatments': [
          'Azelaic acid 10% gel',
          'Metronidazole 0.75% gel (consult doctor)',
          'Green-tinted color-correcting primer',
          'Gentle cleanser (Cetaphil, Vanicream)',
          'Niacinamide serum',
        ],
        'suggestions': [
          'Keep a trigger diary',
          'Use cool compresses for flare-ups',
          'Avoid rubbing or scrubbing face',
          'Choose mineral-based makeup',
          'Manage emotional stress',
        ],
        'whenToSeeDoctor': [
          'Eye involvement (redness, irritation)',
          'Thickening of facial skin',
          'Persistent redness or worsening',
          'No improvement with lifestyle changes',
        ],
      },
      
      'dermatitis': {
        'severity': 'Mild to Moderate',
        'description': 'General skin inflammation causing redness, swelling, and itching',
        'precautions': [
          'Identify and remove irritants/allergens',
          'Moisturize frequently with fragrance-free lotion',
          'Avoid scratching affected areas',
          'Wear protective gloves for tasks',
          'Use mild, unscented soaps',
        ],
        'treatments': [
          'Hydrocortisone cream 1%',
          'Calamine lotion for itch relief',
          'Antihistamines (Benadryl, Zyrtec)',
          'Thick emollient creams',
          'Cool wet compresses',
        ],
        'suggestions': [
          'Patch test new products before use',
          'Rinse skin after swimming',
          'Use hypoallergenic laundry detergent',
          'Keep affected area clean and dry',
          'Avoid known allergens',
        ],
        'whenToSeeDoctor': [
          'Severe or spreading rash',
          'Signs of infection',
          'No improvement after 1 week',
          'Affects daily activities',
        ],
      },
      
      'fungal infection': {
        'severity': 'Mild to Moderate',
        'description': 'Infection caused by fungi, often in warm, moist areas',
        'precautions': [
          'Keep affected area clean and dry',
          'Wear breathable, loose-fitting clothes',
          'Change socks and underwear daily',
          'Avoid sharing personal items',
          'Dry thoroughly after bathing',
          'Use antifungal powder in shoes',
        ],
        'treatments': [
          'Clotrimazole cream 1%',
          'Miconazole cream or spray',
          'Terbinafine cream (Lamisil)',
          'Tolnaftate powder',
          'Tea tree oil (diluted)',
        ],
        'suggestions': [
          'Complete full treatment course (2-4 weeks)',
          'Disinfect or replace contaminated items',
          'Wear sandals in public showers',
          'Keep skin folds dry',
          'Boost immune system with healthy diet',
        ],
        'whenToSeeDoctor': [
          'No improvement after 2 weeks',
          'Spreading to other areas',
          'Severe pain or discharge',
          'Diabetic with fungal infection',
        ],
      },
      
      'warts': {
        'severity': 'Mild',
        'description': 'Small, rough growths caused by human papillomavirus (HPV)',
        'precautions': [
          'Avoid picking or scratching warts',
          'Cover with bandage to prevent spread',
          'Do not share towels or personal items',
          'Wear flip-flops in public areas',
          'Keep hands and feet dry',
        ],
        'treatments': [
          'Salicylic acid 17% gel/liquid',
          'Duct tape occlusion therapy',
          'Freeze-off products (Compound W)',
          'Apple cider vinegar (diluted, cautiously)',
          'Over-the-counter wart removers',
        ],
        'suggestions': [
          'Be patient - treatment takes weeks',
          'File down wart gently before treatment',
          'Boost immune system naturally',
          'Avoid walking barefoot in public',
          'Do not share nail clippers',
        ],
        'whenToSeeDoctor': [
          'Painful or bleeding warts',
          'Warts on face or genitals',
          'Many warts appearing suddenly',
          'Diabetic or immunocompromised',
        ],
      },
      
      'vitiligo': {
        'severity': 'Mild to Moderate (Cosmetic)',
        'description': 'Skin condition causing loss of pigment in patches',
        'precautions': [
          'Use high SPF sunscreen on all skin',
          'Protect depigmented areas from sun',
          'Avoid skin injuries or trauma',
          'Manage stress and anxiety',
          'Use gentle skincare products',
        ],
        'treatments': [
          'Topical corticosteroids (consult doctor)',
          'Vitamin D3 supplements',
          'Broad-spectrum SPF 50+ sunscreen',
          'Cosmetic camouflage makeup',
          'Tacrolimus ointment (prescription)',
        ],
        'suggestions': [
          'Consider support groups',
          'Use self-tanners to blend patches',
          'Maintain overall skin health',
          'Eat antioxidant-rich foods',
          'Consider phototherapy (consult doctor)',
        ],
        'whenToSeeDoctor': [
          'Rapid spread of patches',
          'Concerns about appearance',
          'Interest in treatment options',
          'Psychological impact',
        ],
      },
      
      'hives': {
        'severity': 'Mild to Moderate (Can be Severe)',
        'description': 'Raised, itchy welts on skin, often due to allergic reaction',
        'precautions': [
          'Identify and avoid triggers',
          'Avoid tight clothing',
          'Stay in cool environment',
          'Avoid hot showers/baths',
          'Do not scratch the welts',
        ],
        'treatments': [
          'Antihistamines (Cetirizine, Loratadine)',
          'Benadryl for acute relief',
          'Calamine lotion',
          'Cool compresses',
          'Hydrocortisone cream 1%',
        ],
        'suggestions': [
          'Keep a trigger diary',
          'Take lukewarm oatmeal baths',
          'Wear loose, soft clothing',
          'Apply aloe vera gel',
          'Reduce stress levels',
        ],
        'whenToSeeDoctor': [
          'Difficulty breathing or swallowing',
          'Swelling of lips, tongue, or throat',
          'Dizziness or fainting',
          'Hives lasting more than 6 weeks',
        ],
      },
    };

    // Try to find exact match or partial match
    for (var entry in medicalDatabase.entries) {
      if (normalizedDisease.contains(entry.key) || 
          entry.key.contains(normalizedDisease)) {
        return entry.value;
      }
    }

    // Default response for unknown conditions
    return {
      'severity': 'No evidence of disease',
      'description': 'If the issue persists, try Fixes below ',
      'Fixes': [ 
        'Zoom in and try again',
        'Take a clear photo in good light and upload it',
        'Ensure the affected area is visible and unobstructed',
        'See a skin specialist , if unsure about the condition',
      ],
      
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Analysis Results"),
        centerTitle: true,
        elevation: 2,
      ),
      body: isLoading
          ? _buildLoadingView()
          : _buildResultView(),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(strokeWidth: 3),
          SizedBox(height: 20),
          Text(
            "Analyzing image...",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            "This may take a few moments",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Image Preview Card
          _buildImageCard(),
          
          // Diagnosis Result
          _buildDiagnosisCard(),
          
          // Medical Disclaimer
          _buildDisclaimerCard(),
          
          // Medical Information (if available)
          if (medicalInfo.isNotEmpty) ...[
            _buildFixesCard(),
            _buildPrecautionsCard(),
            _buildTreatmentsCard(),
            _buildSuggestionsCard(),
            _buildWhenToSeeDoctorCard(),
          ],
          
          // Action Buttons
          _buildActionButtons(),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildImageCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(widget.imagePath),
          height: 250,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDiagnosisCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          const Icon(Icons.medical_services, size: 40, color: Colors.blue),
          const SizedBox(height: 12),
          const Text(
            "Detected Condition",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          if (medicalInfo.containsKey('severity')) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getSeverityColor(medicalInfo['severity']),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                medicalInfo['severity'],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
          if (medicalInfo.containsKey('description')) ...[
            const SizedBox(height: 12),
            Text(
              medicalInfo['description'],
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    if (severity.contains('SERIOUS') || severity.contains('EMERGENCY')) {
      return Colors.red;
    } else if (severity.contains('Severe')) {
      return Colors.orange;
    } else if (severity.contains('Moderate')) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }

  Widget _buildDisclaimerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[300]!, width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Medical Disclaimer",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "This is AI-assisted screening only. Always consult a qualified dermatologist for professional diagnosis and treatment.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange[900],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixesCard() {
    if (!medicalInfo.containsKey('Fixes')){
      print("No Fixes found in medicalInfo");
      return const SizedBox.shrink();
    }
    print("Building Fixes card with items: ${medicalInfo['Fixes']}");
    return _buildInfoCard(
      title: "🔧 Troubleshooting Tips",
      items: medicalInfo['Fixes'],
      color: Colors.blue,
    );
  }

  Widget _buildPrecautionsCard() {
    if (!medicalInfo.containsKey('precautions')) return const SizedBox.shrink();
    
    return _buildInfoCard(
      title: "🛡️ Precautions & Prevention",
      items: medicalInfo['precautions'],
      color: Colors.green,
    );
  }

  Widget _buildTreatmentsCard() {
    if (!medicalInfo.containsKey('treatments')) return const SizedBox.shrink();
    
    return _buildInfoCard(
      title: "💊 Common Treatments (OTC)",
      items: medicalInfo['treatments'],
      color: Colors.purple,
    );
  }

  Widget _buildSuggestionsCard() {
    if (!medicalInfo.containsKey('suggestions')) return const SizedBox.shrink();
    
    return _buildInfoCard(
      title: "💡 Lifestyle Suggestions",
      items: medicalInfo['suggestions'],
      color: Colors.teal,
    );
  }

  Widget _buildWhenToSeeDoctorCard() {
    if (!medicalInfo.containsKey('whenToSeeDoctor')) return const SizedBox.shrink();
    
    return _buildInfoCard(
      title: "🏥 When to See a Doctor",
      items: medicalInfo['whenToSeeDoctor'],
      color: Colors.red,
      isUrgent: true,
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<dynamic> items,
    required Color color,
    bool isUrgent = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.9),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isUrgent ? Colors.red : color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.4,
                            fontWeight: isUrgent ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text("New Scan"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  result = "Analyzing...";
                  medicalInfo = {};
                });
                runAI();
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Re-analyze"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
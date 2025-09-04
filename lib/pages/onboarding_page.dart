import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';

class OnboardingPage extends StatefulWidget {
  final String userId;
  
  const OnboardingPage({super.key, required this.userId});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _userService = UserService();
  late PageController _pageController;
  
  int _currentStep = 0;
  bool _isLoading = false;
  
  // Required fields
  String _selectedCurrency = 'USD';
  final TextEditingController _usernameController = TextEditingController();
  
  // Optional fields
  final List<String> _selectedInterests = [];
  String _selectedAgeGroup = '18-25';
  
  // Available options
  final List<String> _currencies = [
    'USD', 'KRW', 'CNY'
  ];
  
  final List<String> _interests = [
    'Fashion & Accessories', 'Electronics', 'Home & Living', 'Beauty & Health',
    'Sports & Outdoors', 'Books & Media', 'Art & Collectibles', 'Food & Beverages',
    'Travel Gear', 'Local Crafts', 'Antiques', 'Luxury Items'
  ];
  
  final List<String> _ageGroups = [
    'Under 18', '18-25', '26-35', '36-45', '46-55', '56-65', '65+'
  ];
  

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadExistingPreferences();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingPreferences() async {
    // No Firebase - just use default values
    setState(() {
      _selectedCurrency = 'USD';
      _usernameController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getLocalizedText('Welcome to Local Price Lens')),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_currentStep + 1) / 5, // 5 total steps
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getLocalizedText('Step ${_currentStep + 1} of 5'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swiping
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildCurrencyStep(),
                _buildUsernameStep(),
                _buildInterestsStep(),
                _buildAgeStep(),
              ],
            ),
          ),
          
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: Text(_getLocalizedText('Previous')),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentStep == 3 
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _currentStep == 3 ? _getLocalizedText('Complete') : _getLocalizedText('Next'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Skip option for optional steps
          if (_currentStep >= 2) // Only show for optional steps
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Center(
                child: TextButton(
                  onPressed: _skipToComplete,
                  child: Text(_getLocalizedText('Skip optional questions')),
                ),
              ),
            ),
          
          // Test button to bypass Firebase (remove in production)
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Test mode - go directly to loading page
                  Navigator.pushReplacementNamed(context, '/loading');
                },
                icon: const Icon(Icons.flash_on),
                label: const Text('🧪 Test Mode (Skip Firebase)'),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.orange.shade100,
                  foregroundColor: Colors.orange.shade800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCurrencyStep() {
    return _buildStepContent(
      title: _getLocalizedText('Select Your Currency'),
      subtitle: _getLocalizedText('Choose your preferred currency for price display'),
      icon: Icons.attach_money,
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedCurrency,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              labelText: _getLocalizedText('Preferred Currency'),
            ),
            items: _currencies.map((String currency) {
              String currencyName = '';
              switch (currency) {
                case 'USD':
                  currencyName = 'USD - US Dollar';
                  break;
                case 'KRW':
                  currencyName = 'KRW - Korean Won';
                  break;
                case 'CNY':
                  currencyName = 'CNY - Chinese Yuan';
                  break;
                default:
                  currencyName = currency;
              }
              return DropdownMenuItem<String>(
                value: currency,
                child: Text(currencyName),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedCurrency = newValue;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameStep() {
    return _buildStepContent(
      title: _getLocalizedText('Choose Your Username'),
      subtitle: _getLocalizedText('Pick a friendly username for your profile'),
      icon: Icons.person,
      child: Column(
        children: [
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              labelText: _getLocalizedText('Username'),
              hintText: _getLocalizedText('Enter your username'),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return _getLocalizedText('Username is required');
              }
              if (value.trim().length < 3) {
                return _getLocalizedText('Username must be at least 3 characters');
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsStep() {
    return _buildStepContent(
      title: _getLocalizedText('Shopping Interests'),
      subtitle: _getLocalizedText('What types of items interest you? (Optional)'),
      icon: Icons.shopping_bag,
      child: Expanded(
        child: Column(
          children: [
            Text(
              _getLocalizedText('Select your shopping interests to get personalized recommendations'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3.0,
                ),
                itemCount: _interests.length,
                itemBuilder: (context, index) {
                  final interest = _interests[index];
                  final isSelected = _selectedInterests.contains(interest);
                  
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedInterests.remove(interest);
                        } else {
                          _selectedInterests.add(interest);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? AppTheme.lightTheme.colorScheme.primary
                          : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected 
                            ? AppTheme.lightTheme.colorScheme.primary
                            : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _getLocalizedText(interest),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeStep() {
    return _buildStepContent(
      title: _getLocalizedText('Age Group'),
      subtitle: _getLocalizedText('Select your age group (Optional)'),
      icon: Icons.person_outline,
      child: Column(
        children: [
          Text(
            _getLocalizedText('This helps us provide better recommendations'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _selectedAgeGroup,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              labelText: _getLocalizedText('Age Group'),
            ),
            items: _ageGroups.map((String ageGroup) {
              return DropdownMenuItem<String>(
                value: ageGroup,
                child: Text(_getLocalizedText(ageGroup)),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedAgeGroup = newValue;
                });
              }
            },
          ),
        ],
      ),
    );
  }


  Widget _buildStepContent({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Icon(
            icon,
            size: 64,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      // Validate required fields
      if (_currentStep == 1 && _usernameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_getLocalizedText('Username is required'))),
        );
        return;
      }
      
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipToComplete() {
    // Save basic user data to UserService even when skipping
    _userService.setCurrency(_selectedCurrency);
    _userService.setUsername(_usernameController.text);
    
    // Skip Firebase saving and go directly to loading page
    // This ensures the skip button always works
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/loading');
    }
  }


  // Localization function
  String _getLocalizedText(String text) {
    // Use English as default since language is set during signup
    switch ('English') {
      case 'Korean':
        return _getKoreanText(text);
      case 'Chinese':
        return _getChineseText(text);
      case 'Japanese':
        return _getJapaneseText(text);
      case 'Vietnamese':
        return _getVietnameseText(text);
      default:
        return text; // English
    }
  }

  // Korean translations
  String _getKoreanText(String text) {
    switch (text) {
      case 'Welcome to Local Price Lens':
        return 'Local Price Lens에 오신 것을 환영합니다';
      case 'Step 1 of 5':
        return '5단계 중 1단계';
      case 'Step 2 of 5':
        return '5단계 중 2단계';
      case 'Step 3 of 5':
        return '5단계 중 3단계';
      case 'Step 4 of 5':
        return '5단계 중 4단계';
      case 'Step 5 of 5':
        return '5단계 중 5단계';
      case 'Choose Your Language':
        return '언어 선택';
      case 'Select your preferred language for the app':
        return '앱에서 사용할 언어를 선택하세요';
      case 'Preferred Language':
        return '선호 언어';
      case 'Select Your Currency':
        return '통화 선택';
      case 'Choose your preferred currency for price display':
        return '가격 표시에 사용할 통화를 선택하세요';
      case 'Preferred Currency':
        return '선호 통화';
      case 'Choose Your Username':
        return '사용자명 선택';
      case 'Pick a friendly username for your profile':
        return '프로필에 사용할 친근한 사용자명을 선택하세요';
      case 'Username':
        return '사용자명';
      case 'Enter your username':
        return '사용자명을 입력하세요';
      case 'Previous':
        return '이전';
      case 'Next':
        return '다음';
      case 'Complete':
        return '완료';
      case 'Skip optional questions':
        return '선택사항 건너뛰기';
      case 'Language changed to':
        return '언어가 다음으로 변경되었습니다:';
      default:
        return text;
    }
  }

  // Chinese translations
  String _getChineseText(String text) {
    switch (text) {
      case 'Welcome to Local Price Lens':
        return '欢迎使用 Local Price Lens';
      case 'Step 1 of 5':
        return '第 1 步，共 5 步';
      case 'Step 2 of 5':
        return '第 2 步，共 5 步';
      case 'Step 3 of 5':
        return '第 3 步，共 5 步';
      case 'Step 4 of 5':
        return '第 4 步，共 5 步';
      case 'Step 5 of 5':
        return '第 5 步，共 5 步';
      case 'Choose Your Language':
        return '选择您的语言';
      case 'Select your preferred language for the app':
        return '选择您在应用中使用的语言';
      case 'Preferred Language':
        return '首选语言';
      case 'Select Your Currency':
        return '选择您的货币';
      case 'Choose your preferred currency for price display':
        return '选择显示价格时使用的货币';
      case 'Preferred Currency':
        return '首选货币';
      case 'Choose Your Username':
        return '选择您的用户名';
      case 'Pick a friendly username for your profile':
        return '为您的个人资料选择一个友好的用户名';
      case 'Username':
        return '用户名';
      case 'Enter your username':
        return '输入用户名';
      case 'Previous':
        return '上一步';
      case 'Next':
        return '下一步';
      case 'Complete':
        return '完成';
      case 'Skip optional questions':
        return '跳过可选问题';
      case 'Language changed to':
        return '语言已更改为：';
      default:
        return text;
    }
  }

  // Japanese translations
  String _getJapaneseText(String text) {
    switch (text) {
      case 'Welcome to Local Price Lens':
        return 'Local Price Lens へようこそ';
      case 'Step 1 of 5':
        return '5ステップ中 1 ステップ';
      case 'Step 2 of 5':
        return '5ステップ中 2 ステップ';
      case 'Step 3 of 5':
        return '5ステップ中 3 ステップ';
      case 'Step 4 of 5':
        return '5ステップ中 4 ステップ';
      case 'Step 5 of 5':
        return '5ステップ中 5 ステップ';
      case 'Choose Your Language':
        return '言語を選択';
      case 'Select your preferred language for the app':
        return 'アプリで使用する言語を選択してください';
      case 'Preferred Language':
        return '希望言語';
      case 'Select Your Currency':
        return '通貨を選択';
      case 'Choose your preferred currency for price display':
        return '価格表示に使用する通貨を選択してください';
      case 'Preferred Currency':
        return '希望通貨';
      case 'Choose Your Username':
        return 'ユーザー名を選択';
      case 'Pick a friendly username for your profile':
        return 'プロフィールに使用する親しみやすいユーザー名を選択してください';
      case 'Username':
        return 'ユーザー名';
      case 'Enter your username':
        return 'ユーザー名を入力してください';
      case 'Previous':
        return '前へ';
      case 'Next':
        return '次へ';
      case 'Complete':
        return '完了';
      case 'Skip optional questions':
        return 'オプション質問をスキップ';
      case 'Language changed to':
        return '言語が以下に変更されました：';
      default:
        return text;
    }
  }

  // Vietnamese translations
  String _getVietnameseText(String text) {
    switch (text) {
      case 'Welcome to Local Price Lens':
        return 'Chào mừng đến với Local Price Lens';
      case 'Step 1 of 5':
        return 'Bước 1 trong 5';
      case 'Step 2 of 5':
        return 'Bước 2 trong 5';
      case 'Step 3 of 5':
        return 'Bước 3 trong 5';
      case 'Step 4 of 5':
        return 'Bước 4 trong 5';
      case 'Step 5 of 5':
        return 'Bước 5 trong 5';
      case 'Choose Your Language':
        return 'Chọn ngôn ngữ của bạn';
      case 'Select your preferred language for the app':
        return 'Chọn ngôn ngữ bạn muốn sử dụng trong ứng dụng';
      case 'Preferred Language':
        return 'Ngôn ngữ ưa thích';
      case 'Select Your Currency':
        return 'Chọn tiền tệ của bạn';
      case 'Choose your preferred currency for price display':
        return 'Chọn tiền tệ bạn muốn hiển thị giá';
      case 'Preferred Currency':
        return 'Tiền tệ ưa thích';
      case 'Choose Your Username':
        return 'Chọn tên người dùng';
      case 'Pick a friendly username for your profile':
        return 'Chọn tên người dùng thân thiện cho hồ sơ của bạn';
      case 'Username':
        return 'Tên người dùng';
      case 'Enter your username':
        return 'Nhập tên người dùng';
      case 'Previous':
        return 'Trước';
      case 'Next':
        return 'Tiếp theo';
      case 'Complete':
        return 'Hoàn thành';
      case 'Skip optional questions':
        return 'Bỏ qua câu hỏi tùy chọn';
      case 'Language changed to':
        return 'Ngôn ngữ đã thay đổi thành:';
      default:
        return text;
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() {
      _isLoading = true;
    });

    // Save user data to UserService
    _userService.setCurrency(_selectedCurrency);
    _userService.setUsername(_usernameController.text);
    _userService.setInterests(_selectedInterests);
    _userService.setAgeGroup(_selectedAgeGroup);

    // Simulate saving delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Navigate to loading page
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/loading');
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // No Firebase - data is not saved
}

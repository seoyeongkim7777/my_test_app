import 'package:flutter/material.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  String _currentLanguage = 'English';
  
  String get currentLanguage => _currentLanguage;
  
  void changeLanguage(String newLanguage) {
    if (_currentLanguage != newLanguage) {
      _currentLanguage = newLanguage;
      notifyListeners();
    }
  }
  
  // Get localized text based on current language
  String getLocalizedText(String text) {
    switch (_currentLanguage) {
      case 'Korean':
        return _getKoreanText(text);
      case 'Chinese':
        return _getChineseText(text);
      default:
        return text; // English
    }
  }
  
  // Korean translations
  String _getKoreanText(String text) {
    switch (text) {
      // Basic UI
      case 'Welcome':
        return '환영합니다';
      case 'Home':
        return '홈';
      case 'Profile':
        return '프로필';
      case 'Settings':
        return '설정';
      case 'Camera':
        return '카메라';
      case 'Search':
        return '검색';
      case 'Submit':
        return '제출';
      case 'Cancel':
        return '취소';
      case 'Save':
        return '저장';
      case 'Delete':
        return '삭제';
      case 'Edit':
        return '편집';
      case 'Loading...':
        return '로딩 중...';
      case 'Error':
        return '오류';
      case 'Success':
        return '성공';
      case 'Price':
        return '가격';
      case 'Store':
        return '상점';
      case 'Location':
        return '위치';
      case 'Date':
        return '날짜';
      case 'Time':
        return '시간';
      case 'Distance':
        return '거리';
      case 'Currency':
        return '통화';
      case 'Language':
        return '언어';
      case 'Username':
        return '사용자명';
      case 'Email':
        return '이메일';
      case 'Password':
        return '비밀번호';
      case 'Login':
        return '로그인';
      case 'Signup':
        return '회원가입';
      case 'Logout':
        return '로그아웃';
      case 'Continue':
        return '계속';
      case 'Back':
        return '뒤로';
      case 'Next':
        return '다음';
      case 'Previous':
        return '이전';
      case 'Complete':
        return '완료';
      case 'Skip':
        return '건너뛰기';
      case 'Required':
        return '필수';
      case 'Optional':
        return '선택사항';
      case 'Yes':
        return '예';
      case 'No':
        return '아니오';
      case 'OK':
        return '확인';
      case 'Close':
        return '닫기';
      case 'Open':
        return '열기';
      case 'Add':
        return '추가';
      case 'Remove':
        return '제거';
      case 'Update':
        return '업데이트';
      case 'Refresh':
        return '새로고침';
      case 'Apply':
        return '적용';
      case 'Confirm':
        return '확인';
      case 'Deny':
        return '거부';
      case 'Accept':
        return '수락';
      case 'Reject':
        return '거부';
      case 'Review':
        return '검토';
      case 'Reset':
        return '초기화';
      case 'Clear':
        return '지우기';
      case 'Gallery':
        return '갤러리';

      // App specific
      case 'Local Price Lens':
        return 'Local Price Lens';
      case 'Are you sure you want to logout?':
        return '정말 로그아웃하시겠습니까?';
      case 'Search for items...':
        return '아이템 검색...';
      case 'Searching for':
        return '검색 중:';
      case 'Recent Posts Nearby':
        return '주변 최근 게시물';
      case 'items':
        return '아이템';
      case 'See the Real Price':
        return '실제 가격 보기';
      case 'Set Search Radius':
        return '검색 반경 설정';
      case 'Adjust the area to search for nearby items and stores':
        return '주변 아이템과 상점을 검색할 영역을 조정하세요';
      case 'Map View':
        return '지도 보기';
      case 'Interactive map with radius selection':
        return '반경 선택이 가능한 인터랙티브 지도';
      case 'Search Radius':
        return '검색 반경';
      case 'Few blocks':
        return '몇 블록';
      case 'Whole city':
        return '전체 도시';
      case 'Reset to Current Location':
        return '현재 위치로 재설정';
      case 'Resetting to current location...':
        return '현재 위치로 재설정 중...';
      case 'Apply Changes':
        return '변경사항 적용';
      case 'Search radius updated to':
        return '검색 반경이 다음으로 업데이트되었습니다:';
      case 'Explore Nearby Cities':
        return '주변 도시 탐험';
      case 'Discover beautiful coastal destinations! Take the express bus from Busan to explore nearby cities. Journey times vary from 1-3 hours. Perfect for day trips to see famous landmarks, beautiful beaches, and local attractions.':
        return '아름다운 해안 목적지를 발견하세요! 부산에서 익스프레스 버스를 타고 주변 도시를 탐험하세요. 여행 시간은 1-3시간 정도 소요됩니다. 유명한 랜드마크, 아름다운 해변, 현지 명소를 보기 위한 당일 여행에 완벽합니다.';
      case 'Explore Routes':
        return '경로 탐험';
      case 'Exploring routes...':
        return '경로 탐험 중...';
      case 'Discover More':
        return '더 알아보기';
      case 'Discovering more...':
        return '더 알아보는 중...';

      // Permissions
      case 'Camera permission is required to take photos':
        return '사진을 찍으려면 카메라 권한이 필요합니다';
      case 'Photo library permission is required to select images':
        return '이미지를 선택하려면 사진 라이브러리 권한이 필요합니다';
      case 'Location permission is required to show nearby items':
        return '주변 아이템을 보려면 위치 권한이 필요합니다';
      case 'Camera permission denied':
        return '카메라 권한이 거부되었습니다';
      case 'Photo library permission denied':
        return '사진 라이브러리 권한이 거부되었습니다';

      // Login/Signup
      case 'Sign Up':
        return '회원가입';
      case 'Create Account':
        return '계정 만들기';
      case 'Welcome Back':
        return '다시 오신 것을 환영합니다';
      case 'Sign up to get started':
        return '시작하려면 회원가입하세요';
      case 'Sign in to continue':
        return '계속하려면 로그인하세요';
      case 'Enter your email':
        return '이메일을 입력하세요';
      case 'Please enter your email':
        return '이메일을 입력해주세요';
      case 'Please enter a valid email':
        return '유효한 이메일을 입력해주세요';
      case 'Enter your password':
        return '비밀번호를 입력하세요';
      case 'Please enter your password':
        return '비밀번호를 입력해주세요';
      case 'Password must be at least 6 characters':
        return '비밀번호는 최소 6자 이상이어야 합니다';
      case 'Enter a friendly username':
        return '친근한 사용자명을 입력하세요';
      case 'Please enter a username':
        return '사용자명을 입력해주세요';
      case 'Username must be at least 2 characters':
        return '사용자명은 최소 2자 이상이어야 합니다';
      case 'Authentication failed. Please try again.':
        return '인증에 실패했습니다. 다시 시도해주세요.';
      case 'Already have an account? Login':
        return '이미 계정이 있으신가요? 로그인';
      case 'Don\'t have an account? Sign Up':
        return '계정이 없으신가요? 회원가입';
      case 'Test App (Skip Auth)':
        return '테스트 앱 (인증 건너뛰기)';

      // Profile
      case 'Your Profile':
        return '프로필';
      case 'Language & Currency':
        return '언어 및 통화';
      case 'Your Posted Items':
        return '게시한 아이템';
      case 'No items posted yet':
        return '아직 게시한 아이템이 없습니다';
      case 'Start by posting your first item to compare prices with others':
        return '다른 사람들과 가격을 비교하기 위해 첫 번째 아이템을 게시해보세요';

      // Item Submission
      case 'Step 1 of 4':
        return '4단계 중 1단계';
      case 'Step 2 of 4':
        return '4단계 중 2단계';
      case 'Step 3 of 4':
        return '4단계 중 3단계';
      case 'Step 4 of 4':
        return '4단계 중 4단계';
      case 'Take a Photo':
        return '사진 찍기';
      case 'Take a photo of the item you want to compare':
        return '비교하고 싶은 아이템의 사진을 찍으세요';
      case 'Enter Item Details':
        return '아이템 세부정보 입력';
      case 'Tell us about the item you found':
        return '찾은 아이템에 대해 알려주세요';
      case 'Item Name':
        return '아이템 이름';
      case 'Enter item name':
        return '아이템 이름을 입력하세요';
      case 'Store Name':
        return '상점 이름';
      case 'Enter store name':
        return '상점 이름을 입력하세요';
      case 'Enter Price':
        return '가격 입력';
      case 'Enter the price you found':
        return '찾은 가격을 입력하세요';
      case 'Enter price':
        return '가격을 입력하세요';
      case 'Review & Submit':
        return '검토 및 제출';
      case 'Review your item details before submitting':
        return '제출하기 전에 아이템 세부정보를 검토하세요';
      case 'Submit Item':
        return '아이템 제출';
      case 'Item submitted successfully!':
        return '아이템이 성공적으로 제출되었습니다!';
      case 'Your item has been added to our database':
        return '아이템이 데이터베이스에 추가되었습니다';
      case 'View Results':
        return '결과 보기';
      case 'Please enter item name':
        return '아이템 이름을 입력해주세요';
      case 'Please enter store name':
        return '상점 이름을 입력해주세요';
      case 'Please enter a valid price':
        return '유효한 가격을 입력해주세요';
      case 'Please take a photo or select from gallery':
        return '사진을 찍거나 갤러리에서 선택해주세요';

      // Onboarding
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
      case 'Enter your username':
        return '사용자명을 입력하세요';
      case 'Skip optional questions':
        return '선택사항 건너뛰기';
      case 'Language changed to':
        return '언어가 다음으로 변경되었습니다:';
      case 'Shopping Interests':
        return '쇼핑 관심사';
      case 'What types of items interest you? (Optional)':
        return '어떤 종류의 아이템에 관심이 있으신가요? (선택사항)';
      case 'Select your shopping interests to get personalized recommendations':
        return '개인화된 추천을 받기 위해 쇼핑 관심사를 선택하세요';
      case 'Age Group':
        return '연령대';
      case 'Select your age group (Optional)':
        return '연령대를 선택하세요 (선택사항)';
      case 'This helps us provide better recommendations':
        return '이것은 더 나은 추천을 제공하는 데 도움이 됩니다';

      default:
        return text;
    }
  }
  
  // Chinese translations
  String _getChineseText(String text) {
    switch (text) {
      // Basic UI
      case 'Welcome':
        return '欢迎';
      case 'Home':
        return '首页';
      case 'Profile':
        return '个人资料';
      case 'Settings':
        return '设置';
      case 'Camera':
        return '相机';
      case 'Search':
        return '搜索';
      case 'Submit':
        return '提交';
      case 'Cancel':
        return '取消';
      case 'Save':
        return '保存';
      case 'Delete':
        return '删除';
      case 'Edit':
        return '编辑';
      case 'Loading...':
        return '加载中...';
      case 'Error':
        return '错误';
      case 'Success':
        return '成功';
      case 'Price':
        return '价格';
      case 'Store':
        return '商店';
      case 'Location':
        return '位置';
      case 'Date':
        return '日期';
      case 'Time':
        return '时间';
      case 'Distance':
        return '距离';
      case 'Currency':
        return '货币';
      case 'Language':
        return '语言';
      case 'Username':
        return '用户名';
      case 'Email':
        return '邮箱';
      case 'Password':
        return '密码';
      case 'Login':
        return '登录';
      case 'Signup':
        return '注册';
      case 'Logout':
        return '登出';
      case 'Continue':
        return '继续';
      case 'Back':
        return '返回';
      case 'Next':
        return '下一步';
      case 'Previous':
        return '上一步';
      case 'Complete':
        return '完成';
      case 'Skip':
        return '跳过';
      case 'Required':
        return '必填';
      case 'Optional':
        return '可选';
      case 'Yes':
        return '是';
      case 'No':
        return '否';
      case 'OK':
        return '确定';
      case 'Close':
        return '关闭';
      case 'Open':
        return '打开';
      case 'Add':
        return '添加';
      case 'Remove':
        return '移除';
      case 'Update':
        return '更新';
      case 'Refresh':
        return '刷新';
      case 'Apply':
        return '应用';
      case 'Confirm':
        return '确认';
      case 'Deny':
        return '拒绝';
      case 'Accept':
        return '接受';
      case 'Reject':
        return '拒绝';
      case 'Review':
        return '审查';
      case 'Reset':
        return '重置';
      case 'Clear':
        return '清除';
      case 'Gallery':
        return '相册';

      // App specific
      case 'Local Price Lens':
        return 'Local Price Lens';
      case 'Are you sure you want to logout?':
        return '您确定要登出吗？';
      case 'Search for items...':
        return '搜索商品...';
      case 'Searching for':
        return '搜索中：';
      case 'Recent Posts Nearby':
        return '附近最新发布';
      case 'items':
        return '商品';
      case 'See the Real Price':
        return '查看真实价格';
      case 'Set Search Radius':
        return '设置搜索半径';
      case 'Adjust the area to search for nearby items and stores':
        return '调整搜索附近商品和商店的区域';
      case 'Map View':
        return '地图视图';
      case 'Interactive map with radius selection':
        return '带半径选择的交互式地图';
      case 'Search Radius':
        return '搜索半径';
      case 'Few blocks':
        return '几个街区';
      case 'Whole city':
        return '整个城市';
      case 'Reset to Current Location':
        return '重置到当前位置';
      case 'Resetting to current location...':
        return '正在重置到当前位置...';
      case 'Apply Changes':
        return '应用更改';
      case 'Search radius updated to':
        return '搜索半径已更新为：';
      case 'Explore Nearby Cities':
        return '探索附近城市';
      case 'Discover beautiful coastal destinations! Take the express bus from Busan to explore nearby cities. Journey times vary from 1-3 hours. Perfect for day trips to see famous landmarks, beautiful beaches, and local attractions.':
        return '发现美丽的海滨目的地！从釜山乘坐快车探索附近城市。行程时间1-3小时不等。非常适合一日游，参观著名地标、美丽海滩和当地景点。';
      case 'Explore Routes':
        return '探索路线';
      case 'Exploring routes...':
        return '正在探索路线...';
      case 'Discover More':
        return '了解更多';
      case 'Discovering more...':
        return '正在了解更多...';

      // Permissions
      case 'Camera permission is required to take photos':
        return '拍照需要相机权限';
      case 'Photo library permission is required to select images':
        return '选择图片需要照片库权限';
      case 'Location permission is required to show nearby items':
        return '显示附近商品需要位置权限';
      case 'Camera permission denied':
        return '相机权限被拒绝';
      case 'Photo library permission denied':
        return '照片库权限被拒绝';

      // Login/Signup
      case 'Sign Up':
        return '注册';
      case 'Create Account':
        return '创建账户';
      case 'Welcome Back':
        return '欢迎回来';
      case 'Sign up to get started':
        return '注册开始使用';
      case 'Sign in to continue':
        return '登录继续';
      case 'Enter your email':
        return '输入您的邮箱';
      case 'Please enter your email':
        return '请输入您的邮箱';
      case 'Please enter a valid email':
        return '请输入有效的邮箱';
      case 'Enter your password':
        return '输入您的密码';
      case 'Please enter your password':
        return '请输入您的密码';
      case 'Password must be at least 6 characters':
        return '密码至少需要6个字符';
      case 'Enter a friendly username':
        return '输入一个友好的用户名';
      case 'Please enter a username':
        return '请输入用户名';
      case 'Username must be at least 2 characters':
        return '用户名至少需要2个字符';
      case 'Authentication failed. Please try again.':
        return '认证失败，请重试。';
      case 'Already have an account? Login':
        return '已有账户？登录';
      case 'Don\'t have an account? Sign Up':
        return '没有账户？注册';
      case 'Test App (Skip Auth)':
        return '测试应用（跳过认证）';

      // Profile
      case 'Your Profile':
        return '您的个人资料';
      case 'Language & Currency':
        return '语言和货币';
      case 'Your Posted Items':
        return '您发布的商品';
      case 'No items posted yet':
        return '尚未发布任何商品';
      case 'Start by posting your first item to compare prices with others':
        return '开始发布您的第一个商品，与他人比较价格';

      // Item Submission
      case 'Step 1 of 4':
        return '第1步，共4步';
      case 'Step 2 of 4':
        return '第2步，共4步';
      case 'Step 3 of 4':
        return '第3步，共4步';
      case 'Step 4 of 4':
        return '第4步，共4步';
      case 'Take a Photo':
        return '拍照';
      case 'Take a photo of the item you want to compare':
        return '拍摄您想要比较的商品照片';
      case 'Enter Item Details':
        return '输入商品详情';
      case 'Tell us about the item you found':
        return '告诉我们您找到的商品';
      case 'Item Name':
        return '商品名称';
      case 'Enter item name':
        return '输入商品名称';
      case 'Store Name':
        return '商店名称';
      case 'Enter store name':
        return '输入商店名称';
      case 'Enter Price':
        return '输入价格';
      case 'Enter the price you found':
        return '输入您找到的价格';
      case 'Enter price':
        return '输入价格';
      case 'Review & Submit':
        return '审查并提交';
      case 'Review your item details before submitting':
        return '提交前审查您的商品详情';
      case 'Submit Item':
        return '提交商品';
      case 'Item submitted successfully!':
        return '商品提交成功！';
      case 'Your item has been added to our database':
        return '您的商品已添加到我们的数据库';
      case 'View Results':
        return '查看结果';
      case 'Please enter item name':
        return '请输入商品名称';
      case 'Please enter store name':
        return '请输入商店名称';
      case 'Please enter a valid price':
        return '请输入有效价格';
      case 'Please take a photo or select from gallery':
        return '请拍照或从相册中选择';

      // Onboarding
      case 'Welcome to Local Price Lens':
        return '欢迎使用 Local Price Lens';
      case 'Step 1 of 5':
        return '第1步，共5步';
      case 'Step 2 of 5':
        return '第2步，共5步';
      case 'Step 3 of 5':
        return '第3步，共5步';
      case 'Step 4 of 5':
        return '第4步，共5步';
      case 'Step 5 of 5':
        return '第5步，共5步';
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
      case 'Enter your username':
        return '输入用户名';
      case 'Skip optional questions':
        return '跳过可选问题';
      case 'Language changed to':
        return '语言已更改为：';
      case 'Shopping Interests':
        return '购物兴趣';
      case 'What types of items interest you? (Optional)':
        return '您对什么类型的商品感兴趣？（可选）';
      case 'Select your shopping interests to get personalized recommendations':
        return '选择您的购物兴趣以获得个性化推荐';
      case 'Age Group':
        return '年龄组';
      case 'Select your age group (Optional)':
        return '选择您的年龄组（可选）';
      case 'This helps us provide better recommendations':
        return '这有助于我们提供更好的推荐';

      default:
        return text;
    }
  }
}
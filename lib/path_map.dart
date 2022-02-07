import 'dart:io';

class Path {
  late Map<String, String> targetDirs;
  late Map<String, String> deleteDirs;

  // *백업 대상이 파일인 경우 key에 '파일'을 포함시켜야 함*
  Path(String str) {
    targetDirs = {
      'target1': r'C:\Users\' '$str' r'\Documents\aaa',
      'target2': r'C:\Users\' '$str' r'\Downloads\bbb',
      '인터넷 익스플로러 즐겨찾기': r'C:\Users\' '$str' r'\Favorites',
      '엣지 즐겨찾기 파일': r'C:\Users\'
          '$str'
          r'\AppData\Local\Microsoft\Edge\User Data\Default\Bookmarks',
      '메모지': r'C:\work\ps\mo\사용자메모지',
    };
    deleteDirs = {
      '문서 폴더(내 계정)': r'C:\Users\' '$str' r'\Documents',
      '문서 폴더(관리자 계정)': r'C:\Users\Administrator\Documents',
      '다운로드 폴더(내 계정)': r'C:\Users\' '$str' r'\Downloads',
      '다운로드 폴더(관리자 계정)': r'C:\Users\Administrator\Downloads',
      '인증서': r'C:\GPKI',
      '최근문서': r'C:\Users\' '$str' r'\AppData\Roaming\Microsoft\Windows\Recent',
      '활동기록': 'ms-settings:privacy-activityhistory',
      '휴지통': 'shell:RecycleBinFolder',
    };
  }
}

final String userName = Platform.environment['username'] ?? '사용자 확인 불가';
final Map<String, String> targetDirs = Path(userName).targetDirs;

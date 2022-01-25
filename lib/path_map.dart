class Path {
  late Map<String, String> targetDirs;

  Path(String str) {
    targetDirs = {
      'target1': r'C:\Users\' '$str' r'\Documents\aaa',
      'target2': r'C:\Users\' '$str' r'\Downloads\bbb',
      '엣지 즐겨찾기 파일': r'C:\Users\'
          '$str'
          r'\AppData\Local\Microsoft\Edge\User Data\Default\Bookmarks',
      '메모지': r'C:\work\ps\mo\사용자메모지',
    };
  }
}

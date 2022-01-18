class Path {
  late Map<String, String> targetDirs;
  late Map<String, String> targetDirs2;

  Path(String str) {
    targetDirs = {
      'target1': r'C:\Users\' '$str' r'\Documents\aaa',
      'target2': r'C:\Users\' '$str' r'\Downloads\bbb',
      '엣지 즐겨찾기': r'C:\Users\'
          '$str'
          r'\AppData\Local\Microsoft\Edge\User Data\Default\Bookmarks',
    };

    targetDirs2 = {
      'target1': r'C:\Users\' '$str' r'\Documents\aaa111',
      'target2': r'C:\Users\' '$str' r'\Downloads\bbb111',
      '엣지 즐겨찾기': r'C:\Users\'
          '$str'
          r'\AppData\Local\Microsoft\Edge\User Data\Default\Bookmarks111',
    };
  }
}

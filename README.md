# DOMA 

## 왜 만들었나요?

레시피 저장, 생각보다 애매합니다.

카톡에 넣어두면 나중에 다시 찾기가 어렵고,  
노션에 적어두자니 열고 찾고 들어가는 과정이 조금 무겁습니다.

유튜브에서 맛있어 보이는 레시피를 발견해도  
“이건 나중에 꼭 해먹어야지” 해놓고  
막상 다시 만들려고 하면 또 그 영상을 찾고 있게 됩니다.

그래서 만들었습니다.

DOMA는  
레시피를 아주 가볍게 저장해두고,  
필요할 때 다시 쉽게 꺼내보기 위한 앱입니다.

거창한 기능은 없습니다.  
대신 정말 자주 쓰게 되는 기본 기능만 넣었습니다.

- 제목 저장
- 재료와 수량 기록
- 메모 남기기
- 유튜브/블로그 링크 붙여두기
- 태그로 분류해서 상황에 맞게 찾아보기

예를 들어

- 집에서 간단히 해먹을 음식
- 손님 올 때 꺼내볼 음식
- 술안주로 괜찮았던 음식
- 언젠가 다시 보고 싶은 유튜브 레시피

이런 것들을 한 곳에 담아둘 수 있습니다.

복잡하게 정리하는 앱이라기보다는,  
**“나중에 다시 보려고 챙겨두는 조리법 보관함”**에 가깝습니다.

---

## 한 줄 소개

로컬에 조리법을 저장하고, 검색하고, 분류(태그)로 정리해두는 Flutter 기반 레시피 MVP 앱입니다.

## 기능

- 조리법 기록: 제목, 대표 사진(갤러리), 재료 목록(수량/단위), 조리 기록(메모), 출처 링크(예: YouTube)
- 조리법 조회/수정/삭제
- 검색(제목 기준) + 분류(태그) 필터링
- 분류(태그) 관리 화면
- 단위 관리 화면

## 기술 스택

- Flutter / Dart
- 상태관리: Riverpod (`flutter_riverpod`)
- 라우팅: `go_router`
- 로컬 DB: Isar (`isar`, `isar_flutter_libs`, `isar_generator`)
- 기타: `image_picker`(사진 선택), `url_launcher`(외부 링크 열기)

## 프로젝트 구조

- `lib/main.dart`: 앱 테마 + 라우팅 설정
- `lib/ui/screens/`: 화면(UI)
  - `home_screen.dart`: 검색/태그 필터 + 조리법 목록
  - `recipe_detail_screen.dart`: 상세 화면(삭제/링크 열기)
  - `recipe_edit_screen.dart`: 작성/수정 화면(재료/태그/단위 선택)
  - `tag_management_screen.dart`: 분류(태그) 관리
  - `unit_management_screen.dart`: 단위 관리
- `lib/models/`: Isar 스키마
  - `recipe.dart`(collection), `ingredient.dart`(embedded), `tag.dart`/`unit.dart`(collection)
- `lib/repositories/recipe_repository.dart`: Isar 초기화 및 CRUD/검색 로직
- `lib/providers/`: Riverpod provider 모음
- `assets/`: 기본 이미지/폰트

## 라우팅

- `/`: 홈
- `/detail/:id`: 조리법 상세
- `/edit` 또는 `/edit?id=123`: 조리법 작성/수정
- `/tags`: 분류(태그) 관리
- `/units`: 단위 관리

## 실행 방법

### 1) 준비물

- Flutter SDK (Dart `>= 3.8`)
- iOS/Android/데스크톱 빌드에 필요한 각 플랫폼 툴체인(Xcode, Android Studio 등)

### 2) 의존성 설치 및 실행

```bash
flutter pub get
flutter run
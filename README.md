# madcamp_week2


![Untitled](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/69f523c1-bda1-4145-bf69-d54bde38459b/Untitled.png)
# **👂TO-DO-Listener : 
음성인식 기반 투두리스트 관리앱**

> ‘손으로 일일이 쓰는 플래너는 **귀찮아…**’
> 

> ‘나의 To-do list를 **관리해주고 패턴 분석**까지 해주는 서비스 없나..?’
> 

<aside>
💡 **TO-DO-Listener 는**
Clova API를 사용하여 🔊음성으로 Daily ToDoList를 작성할 수 있고, DB에 저장된 목록의 날짜 별 성취도를 관리하여 나의 
✏️**워라밸, 달성률, 투두 키워드✏️**를 분석해줍니다.

</aside>

## **프로젝트 소개**

---

### **개발 환경**

- **프론트엔드:** Flutter
- **백엔드-서버:** Nest.js
- **Cloud:** Kcloud (kaist 제공)
- **DB:** MongoDB

### **팀원**

🏋️‍♂️김예락(고려대학교)_백엔드, 로고,총괄

🏋️‍♂️박영민 (카이스트)_프론트,보조

[kimyerak - Overview](https://github.com/kimyerak)

[YoungMin0B - Overview](https://github.com/YoungMin0B)

### **프로젝트 주제**

- **목적:** 서버 및 DB를 활용하는 것에 익숙해지기 위해 공통의 과제 수행.
- **결과물:** 서버, DB, SDK를 활용한 안드로이드 앱.
    - Firebase 사용을 지양하고, 데이터를 서버와 주고받는 기능 포함.

## **📱App Preview**

---

### 0️⃣Intro: Splash

![splash (2) (1).gif](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/65ebe066-91bb-41cb-a637-4f9a457d8744/splash_(2)_(1).gif)

Splash / Google Login / Main                                                                                                                                                                                                       

google-signin api로 user정보 비교 후 

로그인 승인과정 구현

[Ppreview.mp4](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/49f211cc-d6af-4323-97a2-9abb2f48b994/Ppreview.mp4)

Voice Recognition/Calender/Analyzer/MyPage

### 1️⃣Tab1 |  To-Do-Listener

---

![voice-recognition.jpg](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/fbce834b-6e8e-4989-b908-f2ea0ede943b/voice-recognition.jpg)

Vocie-Recognition

-음성인식한 work/life(빨강/파랑) type의 listview-todolist 생성

-checkbox, longclick으로 완료여부 표시 , 삭제

-생성 , 체크, 삭제 정보 api를 통해 db에 전달되어, 

calendar dialog와 listview-todolist에 양방향 동기적으로  반영, 

음성인식 및 MongoDB 연동

![DB기능.gif](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/7e13b461-4175-4ea3-a006-5d536e9b7b67/DB%EA%B8%B0%EB%8A%A5.gif)

### 2️⃣Tab2 | Calendar

---

![calender.jpg](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/dea7e7cf-a28d-4ef6-87d1-36202f982fd4/calender.jpg)

Calendar

-캘린더에 해당날짜 총 todolist 개수 표시(marker api로 화면 initiate 동시에 db에서 로드)

![dialog.jpg](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/3ee83a80-80a2-40b3-b426-646a2d765044/dialog.jpg)

Dialog

-dialog에 listview-todolist와 progress-bar로 기록 조회 및 달성여부 수정가능

-api를 통해 수정된 정보 DB에 전달하여 동기적으로 연동가능

### 3️⃣Tab3 | Analyze

---

일별,주별,월별 분석

![analyze1.jpg](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/d75c9468-cc07-45a4-baa2-fc8dfcf27243/analyze1.jpg)

![analyze2.jpg](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/b381dd85-b869-4957-ac2f-c859d3be0fe7/analyze2.jpg)

1️⃣ 도넛형 다이어그램

![analyze0.jpg](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/9b8b5474-3ac5-468c-8811-5fb92c8dc1b9/analyze0.jpg)

2️⃣ 꺾은선 그래프

![analyze.jpg](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/7fba20a7-743b-49f2-ad4e-09f0d1640046/analyze.jpg)

3️⃣워드 클라우드

### 4️⃣Tab4 Profile

---

My Page

user 정보 조회

![Screenshot_20240710-182005.jpg](https://prod-files-secure.s3.us-west-2.amazonaws.com/f6cb388f-3934-47d6-9928-26d2e10eb0fc/e47a59d1-c8f0-4c72-93d2-ecf5272dbe05/Screenshot_20240710-182005.jpg)

## 🌀 DB (mongoDB)

```jsx
@Schema()
export class Todo {
  @Prop({ required: true })
  type: string;

  @Prop({ required: true })
  content: string;

  @Prop({ required: true })
  complete: boolean;

  date?: Date; // 추가된 필드
}

export const TodoSchema = SchemaFactory.createForClass(Todo);
```

```jsx
@Schema()
export class UserDayTodo extends Document {
  @Prop({ required: true })
  name: string;

  @Prop({ type: Date, required: true })
  date: Date;

  @Prop({ type: [TodoSchema], required: true })
  todos: Todo[];
}

export const UserDayTodoSchema = SchemaFactory.createForClass(UserDayTodo);
export type UserDayTodoDocument = UserDayTodo & Document;
export type TodoDocument = Todo & Document;
```

## 🌐백엔드 APIs - 8개

[API](https://www.notion.so/e0348b87c7ad4226aebb513eae97adac?pvs=21)

## 🪂사용된 외부 API / 라이브러리

1️⃣Vocie-Recognition: `_toggleRecording->startRecording->_speechRecognitionService(recognizeSpeech(audioBytes = audioFile)-..>`

2️⃣CompletetionRates-Chart:  `calculateCompletionRates(`
`date = DateTime.now().subtract(Duration(days: 6 - i)`

`dayTodos = todosList.where((element){`
`completedTodos = filteredTodos.where((todo) => todo['complete'] == true`

3️⃣Word-Cloud-Analyze: `JSON -> API -> collectFrequentWords(text_analysis.dart)-> fetchAndSetData -> WordCloudData(word_cloud.dart)`

DB에 저장된 todolist의 type종류(work/life), complete여부(checkbox), content(todolist내용)을 각각 이용하여 하루 Work/Life 차지비율 , 일주일 달성률 변화추이, 한달 todolist 주된내용을 시각화해준다 

<aside>
💭 예락

나중에 친구의 투두리스트랑 대시보드까지 연동해서 러닝메이트걸 불러오는 기능을 확장해보고 싶다. 서버 배포에 많은 도움을 주신 kcloud썼던 선배님들 넘 감사~ nest 첨 써봤는데 고수분들께서 많이 도와주셔서 백엔드를 원활히 구축할 수 있었습니당. 하이퍼클로버 ai도 은근 괜찮다

</aside>

<aside>
🗣 영민

우선, 깃과 많이 친해진 것 같고, 좋은 가르침을 많이 받았으며, 디자인요소들을 관리할때 코드가 길다보니까, 디비에 쓰이는 객체를 조금씩 바꿔서 UI에 입력했을 떄, 헷갈리면 디버깅할 때 찾기 매우 힘들다. 클린코딩으의 중요성,챗지피티 의존도에 벗어나기

</aside>

### APK 파일 다운로드

---

https://drive.google.com/file/d/1P6egwUJ7ZZMiAEgmtBg6RRzj0UoZ9ADC/view?usp=drive_link

# Compiler
2019-1학기 아주대학교 소프트웨어학과 컴파일러 과제

## hw1
**Mini C 언어의 어휘를 분석하는 lexical analyzer 작성**

### 개요
- flex을 이용
- keywords, integer, double, string, oerators, comments, 기타 특수 문자들을 분석
- TOKEN_LIST, SYMBOL_TABLE, STRING_TABLE 구현

### 프로그램
- `ex1.txt`
  * 정상 프로그램 입력
- `ex2.txt`
  * 오류가 포함된 프로그램 입력
- `hw1.l`
  * 소스 프로그램
  
> 자세한 내용과 결과는 [여기](https://github.com/surin-0/Compiler/blob/master/hw1/hw1_201720723_report.pdf)를 참고

## hw2
**수식 인터프리터 개발**
### 개요
- hw1의 Lexical Analyzer을 이용하여 수식 Interpreter개발
- Recursive descent parsing 기법 이용
- 자세한 내용은 [보고서](https://github.com/surin-0/Compiler/blob/master/hw2/hw2_201720723_report.pdf)를 참고
  * 본 과제에서 다룬 expression
  * parsing 방법
  * 주요 자료구조
  * 프로그램 module hierarchy
  * 실행 결과

## hwe
**bottom-up parsing을 이용한 mini-c 인터프리터 개발**

### 개요
- 지난 과제까지 사용하였던 lex가 아닌 yacc을 사용
- mini-c언어의 문법(상수와 변수, 수식 계산, if와 while의 조건문, block)
  * if문의 경우 else와 함께 쓰인 경우만 인정
  * 중첩 if문 허용
  * 선택 사항 : 함수, return문 (**구현 완료**)
- 자세한 내용은 [보고서](https://github.com/surin-0/Compiler/blob/master/hw2/hw2_201720723_report.pdf)를 참고
  * grammar rule 분석
  * 주요 자료구조
  * 프로그램 module hierarchy
  * 실행 결과

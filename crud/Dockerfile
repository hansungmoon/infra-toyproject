FROM node:16-alpine

# 앱 디렉터리 생성
WORKDIR /app

# 앱 의존성 설치
COPY package.json /app

RUN npm install

# 앱 소스 추가
COPY . .

EXPOSE 3000

CMD [ "node", "test.js" ]
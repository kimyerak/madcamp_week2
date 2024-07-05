import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { KakaoModule } from './kakao/kakao.module';

@Module({
  imports: [KakaoModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}

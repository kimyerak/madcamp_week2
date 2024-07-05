import { Controller, Get, Query, Res, HttpStatus } from '@nestjs/common';
import axios from 'axios';
import { Response } from 'express';

const redirectUri = 'http://143.248.228.145:8000/auth/kakao/callback';
const clientId = 'f3f114d55c1422b2b3e9c1b357c7b660'; // 카카오 REST API 키를 여기에 입력하세요.

@Controller()
export class KakaoController {
  @Get('/authorize')
  authorize(@Res() res: Response) {
    const kakaoAuthURL = `https://kauth.kakao.com/oauth/authorize?response_type=code&client_id=${clientId}&redirect_uri=${redirectUri}`;
    return res.redirect(kakaoAuthURL);
  }

  @Get('/auth/kakao/callback')
  async kakaoCallback(@Query('code') authCode: string, @Res() res: Response) {
    try {
      const tokenResponse = await axios.post('https://kauth.kakao.com/oauth/token', null, {
        params: {
          grant_type: 'authorization_code',
          client_id: clientId,
          redirect_uri: redirectUri,
          code: authCode,
        },
      });

      const { access_token } = tokenResponse.data;
      res.cookie('access_token', access_token);
      return res.redirect('/profile');
    } catch (error) {
      return res.status(HttpStatus.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
  }

  @Get('/profile')
  async profile(@Res() res: Response) {
    const accessToken = res.req.cookies.access_token;

    if (!accessToken) {
      return res.status(HttpStatus.UNAUTHORIZED).json({ error: 'Unauthorized' });
    }

    try {
      const profileResponse = await axios.get('https://kapi.kakao.com/v2/user/me', {
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
      });

      return res.json(profileResponse.data);
    } catch (error) {
      return res.status(HttpStatus.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
  }

  @Get('/logout')
  async logout(@Res() res: Response) {
    const accessToken = res.req.cookies.access_token;

    if (!accessToken) {
      return res.status(HttpStatus.UNAUTHORIZED).json({ error: 'Unauthorized' });
    }

    try {
      await axios.post('https://kapi.kakao.com/v1/user/logout', null, {
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
      });

      res.clearCookie('access_token');
      return res.json({ message: 'Logged out successfully' });
    } catch (error) {
      return res.status(HttpStatus.INTERNAL_SERVER_ERROR).json({ error: error.message });
    }
  }
}

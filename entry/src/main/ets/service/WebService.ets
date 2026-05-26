import http from '@ohos.net.http';
import { WeatherInfo } from '../model/WeatherModel';
import resourceManager from '@ohos.resourceManager';
import util from '@ohos.util';
import common from '@ohos.app.ability.common';

// 定义配置类型接口
interface AmapConfig {
  weatherKey: string;
  baseUrl: string;
}

// 模块级变量，显式类型声明
let amapConfig: AmapConfig | null = null;
let configPromise: Promise<void> | null = null;

/**
 * 加载高德配置（需要传入 context）
 * @param context UIAbilityContext 用于读取 rawfile
 */
export async function initAmapConfig(context: common.UIAbilityContext): Promise<void> {
  if (amapConfig !== null) {
    return;
  }
  if (configPromise !== null) {
    return configPromise;
  }

  configPromise = (async (): Promise<void> => {
    try {
      const rawFileContent: Uint8Array = await context.resourceManager.getRawFileContent('app_config.json');
      const textDecoder: util.TextDecoder = new util.TextDecoder('utf-8');
      const jsonStr: string = textDecoder.decodeWithStream(rawFileContent, { stream: false });
      const parsed: object = JSON.parse(jsonStr);
      // 不使用解构，改用显式访问
      const amapObj: Record<string, string> = (parsed as Record<string, Record<string, string>>)['amap'];
      if (!amapObj) {
        throw new Error('配置文件缺少 amap 字段');
      }
      const weatherKey: string = amapObj['weatherKey'];
      const baseUrl: string = amapObj['baseUrl'];
      if (typeof weatherKey !== 'string' || weatherKey.length === 0) {
        throw new Error('配置文件缺少 amap.weatherKey');
      }
      if (typeof baseUrl !== 'string' || baseUrl.length === 0) {
        throw new Error('配置文件缺少 amap.baseUrl');
      }
      amapConfig = {
        weatherKey: weatherKey,
        baseUrl: baseUrl
      };
    } catch (err) {
      console.error(`加载配置文件失败: ${JSON.stringify(err)}`);
      throw new Error('无法加载天气服务配置，请检查 app_config.json');
    }
  })();
  return configPromise;
}

/**
 * 获取实时天气（调用前必须先调用 initAmapConfig）
 * @param city 城市名称
 */
export async function getRealTimeWeather(city: string): Promise<WeatherInfo> {
  // 确保配置已加载
  if (amapConfig === null) {
    throw new Error('天气服务未初始化，请先调用 initAmapConfig');
  }

  const targetCity: string = city.trim();
  console.info(`WebService: 开始请求 ${targetCity} 的天气数据`);

  if (targetCity.length === 0) {
    console.error('WebService: 城市名称不能为空');
    throw new Error('城市名称不能为空');
  }

  const httpRequest: http.HttpRequest = http.createHttp();
  const encodedCity: string = encodeURIComponent(targetCity);
  const queryParams: string = `city=${encodedCity}&key=${amapConfig.weatherKey}&extensions=base&output=json`;
  const requestUrl: string = `${amapConfig.baseUrl}?${queryParams}`;

  console.info(`WebService: 请求URL: ${requestUrl}`);

  return new Promise((resolve: (value: WeatherInfo) => void, reject: (reason: Error) => void) => {
    httpRequest.request(
      requestUrl,
      {
        method: http.RequestMethod.GET,
        header: { 'Content-Type': 'application/json;charset=UTF-8' },
        connectTimeout: 10000,
        readTimeout: 10000
      },
      (err: HttpErrorResponse | null, response: http.HttpResponse) => {
        try {
          if (err !== null && err !== undefined) {
            const errCode: number = err.code !== undefined ? err.code : -1;
            const errMsg: string = err.message !== undefined ? err.message : '未知网络错误';
            console.error(`WebService: 高德API网络错误：${errCode} - ${errMsg}`);
            reject(new Error(`网络请求失败：${errMsg}`));
            return;
          }

          if (response.responseCode !== 200) {
            console.error(`WebService: 请求失败，状态码：${response.responseCode}`);
            reject(new Error(`请求失败，状态码：${response.responseCode}`));
            return;
          }

          const responseText: string = response.result.toString();
          console.info(`WebService: 响应数据: ${responseText.substring(0, 200)}...`);
          if (responseText.length === 0) {
            console.error('WebService: 高德API返回空数据');
            reject(new Error('高德API返回空数据'));
            return;
          }

          const result: AmapWeatherResponse = JSON.parse(responseText) as AmapWeatherResponse;
          console.info(`WebService: API状态码: ${result.status}`);

          if (result.status !== '1') {
            let errMsg: string = result.info !== undefined ? `API错误：${result.info}` : 'API错误：未知错误';
            console.error(`WebService: ${errMsg}`);
            reject(new Error(errMsg));
            return;
          }

          if (result.lives === undefined || result.lives.length === 0) {
            console.error(`WebService: 未查询到${targetCity}的天气数据`);
            reject(new Error(`未查询到${targetCity}的天气数据，请检查城市名是否为全称（如：北京）`));
            return;
          }

          const liveWeather: AmapLiveWeather = result.lives[0];
          console.info(`WebService: 成功获取到 ${liveWeather.city} 的天气数据`);
          const weatherInfo: WeatherInfo = {
            city: liveWeather.city,
            temp: `${liveWeather.temperature}℃`,
            weather: liveWeather.weather,
            wind: `${liveWeather.winddirection} ${liveWeather.windpower}级`,
            humidity: `${liveWeather.humidity}%`,
            updateTime: new Date().toLocaleString()
          };
          resolve(weatherInfo);
        } catch (parseErr) {
          const error: Error = parseErr as Error;
          console.error(`WebService: 高德API数据解析失败：${error.message}`);
          reject(new Error(`数据解析失败：${error.message}`));
        } finally {
          httpRequest.destroy();
        }
      }
    );
  });
}

// 接口定义（保持不变）
export interface AmapWeatherResponse {
  status: string;
  info?: string;
  lives: AmapLiveWeather[];
}

export interface AmapLiveWeather {
  city: string;
  temperature: string;
  weather: string;
  winddirection: string;
  windpower: string;
  humidity: string;
}

export interface HttpErrorResponse {
  code?: number;
  message?: string;
}
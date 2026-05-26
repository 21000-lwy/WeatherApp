// WeatherDetailPage.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { WeatherInfo } from '../model/WeatherModel';
import { getRealTimeWeather } from '../service/WebService';
import { weatherStore } from '../model/WeatherStore';

@Entry
@Component
struct WeatherDetailPage {
  @State weatherDetail: WeatherInfo | null = null;
  @State loading: boolean = false;
  @State errorMsg: string = '';
  aboutToAppear(): void {
    this.loadWeatherDetail();
  }
  async loadWeatherDetail(): Promise<void> {
    const currentCity = weatherStore.currentCity;
    if (!currentCity) {
      this.errorMsg = '未获取到城市信息';
      return;
    }
    this.loading = true;
    this.errorMsg = '';
    try {
      if (weatherStore.currentWeather && weatherStore.currentWeather.city === currentCity) {
        this.weatherDetail = weatherStore.currentWeather;
      } else {
        const weather = await getRealTimeWeather(currentCity);
        this.weatherDetail = weather;
      }
    } catch (err) {
      this.errorMsg = err.message;

      promptAction.showToast({
        message: `获取详情失败: ${err.message}`,
        duration: 2000
      });
    } finally {
      this.loading = false;
    }
  }
  private getWeatherIcon(weather: string): string {
    if (weather.includes('晴')) {
      return '☀️';
    } else if (weather.includes('多云')) {
      return '⛅';
    } else if (weather.includes('阴')) {
      return '☁️';
    } else if (weather.includes('雨')) {
      return '🌧️';
    } else if (weather.includes('雪')) {
      return '❄️';
    } else if (weather.includes('雷')) {
      return '⛈️';
    } else if (weather.includes('雾')) {
      return '🌫️';
    } else {
      return '🌈';
    }
  }
  build() {
    Column({ space: 0 }) {
      Stack() {
        Column()
          .width('100%')
          .height(160)
          .linearGradient({
            angle: 180,
            colors: [['#ff6983f4', 0.0], ['#ffa66ee3', 1.0]]
          })
          .opacity(0.8);

        Column() {
          Row({ space: 10 }) {
            Button() {
              Text('←')
                .fontSize(24)
                .fontColor('#FFFFFF')
            }
            .width(44)
            .height(44)
            .backgroundColor('#ffbcb2e3')
            .borderRadius(22)
            .onClick(() => {
              router.back();
            })

            Text('天气详情')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .flexGrow(1);
          }
          .width('100%')
          .height(60)
          .padding({ left: 20, right: 20 })
          .alignItems(VerticalAlign.Center);

          // 城市标题
          if (this.weatherDetail) {
            Row({ space: 10 }) {
              Text(this.getWeatherIcon(this.weatherDetail.weather))
                .fontSize(30);
              Column({ space: 5 }) {
                Text(this.weatherDetail.city)
                  .fontSize(20)
                  .fontColor('#FFFFFF')
                  .fontWeight(FontWeight.Bold);
                Text('详细天气信息')
                  .fontSize(12)
                  .fontColor('#ffcacffe');
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.Center);
          }
        }
        .width('100%')
        .margin({ top: 20,bottom:10 })
      }
      .width('100%')
      .height(130);
      Scroll() {
        Stack() {
          Column() {
            Image($r('app.media.bg3'))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
              .opacity(0.9)
          }
          .width('100%')
          .height('100%')

          Column({ space: 20 }) {
            if (this.loading) {
              Column() {
                LoadingProgress()
                  .width(60)
                  .height(60)
                  .color('#764ba2');
                Text('正在加载天气详情...')
                  .fontSize(16)
                  .fontColor('#666666')
                  .margin({ top: 15 });
              }
              .width('100%')
              .height(300)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center);
            } else if (this.errorMsg) {
              Column({ space: 15 }) {
                Text('⚠️')
                  .fontSize(60);
                Text('加载失败')
                  .fontSize(20)
                  .fontColor('#FF6B6B');
                Text(this.errorMsg)
                  .fontSize(14)
                  .fontColor('#666666')
                  .textAlign(TextAlign.Center)
                  .margin({ left: 30, right: 30 });
                Button() {
                  Text('重试')
                    .fontSize(16)
                    .fontColor('#FFFFFF')
                }
                .width(140)
                .height(44)
                .margin({ top: 10 })
                .backgroundColor('#667eea')
                .borderRadius(22)
                .onClick(() => {
                  this.loadWeatherDetail();
                })
              }
              .width('100%')
              .height(300)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center);
            } else if (this.weatherDetail) {
              Column({ space: 20 }) {
                Column({ space: 15 }) {
                  Row() {
                    Text('🌡️ 温度')
                      .fontSize(18)
                      .fontColor('#666666')
                      .flexGrow(1);
                    Text(this.weatherDetail.temp)
                      .fontSize(32)
                      .fontColor('#FF6B35')
                      .fontWeight(FontWeight.Bold);
                  }
                  .width('100%')
                  .padding({ left: 25, right: 25 });

                  Progress({
                    value: parseInt(this.weatherDetail.temp) || 25,
                    total: 50,
                    type: ProgressType.Linear
                  })
                    .width('85%')
                    .height(12)
                    .color('#FF6B35')
                    .backgroundColor('#FF6B3510')
                    .borderRadius(6);
                }
                .width('90%')
                .padding({ top: 25, bottom: 25 })
                .backgroundColor('#FFFFFF')
                .borderRadius(24)
                .shadow({
                  radius: 15,
                  color: '#00000008',
                  offsetX: 0,
                  offsetY: 4
                });
                Column({ space: 15 }) {
                  Row() {
                    Text('☁️ 天气状况')
                      .fontSize(18)
                      .fontColor('#666666')
                      .flexGrow(1);
                    Text(this.weatherDetail.weather)
                      .fontSize(22)
                      .fontColor('#333333')
                      .fontWeight(FontWeight.Bold);
                  }
                  .width('100%')
                  .padding({ left: 25, right: 25 });

                  Text('当前天气状况良好，适合户外活动')
                    .fontSize(14)
                    .fontColor('#999999')
                    .width('85%')
                    .textAlign(TextAlign.Center);
                }
                .width('90%')
                .padding({ top: 25, bottom: 25 })
                .backgroundColor('#FFFFFF')
                .borderRadius(24)
                .shadow({
                  radius: 15,
                  color: '#00000008',
                  offsetX: 0,
                  offsetY: 4
                });
                Column({ space: 15 }) {
                  Row() {
                    Text('🌬️ 风向风力')
                      .fontSize(18)
                      .fontColor('#666666')
                      .flexGrow(1);
                    Text(this.weatherDetail.wind)
                      .fontSize(22)
                      .fontColor('#333333')
                      .fontWeight(FontWeight.Medium);
                  }
                  .width('100%')
                  .padding({ left: 25, right: 25 });

                  Text('风速适中，对出行影响较小')
                    .fontSize(14)
                    .fontColor('#999999')
                    .width('85%')
                    .textAlign(TextAlign.Center);
                }
                .width('90%')
                .padding({ top: 25, bottom: 25 })
                .backgroundColor('#FFFFFF')
                .borderRadius(24)
                .shadow({
                  radius: 15,
                  color: '#00000008',
                  offsetX: 0,
                  offsetY: 4
                });
                Column({ space: 15 }) {
                  Row() {
                    Text('💧 湿度')
                      .fontSize(18)
                      .fontColor('#666666')
                      .flexGrow(1);
                    Text(this.weatherDetail.humidity)
                      .fontSize(32)
                      .fontColor('#36D1DC')
                      .fontWeight(FontWeight.Bold);
                  }
                  .width('100%')
                  .padding({ left: 25, right: 25 });

                  Progress({
                    value: parseInt(this.weatherDetail.humidity) || 50,
                    total: 100,
                    type: ProgressType.Linear
                  })
                    .width('85%')
                    .height(12)
                    .color('#36D1DC')
                    .backgroundColor('#36D1DC10')
                    .borderRadius(6);
                }
                .width('90%')
                .padding({ top: 25, bottom: 25 })
                .backgroundColor('#FFFFFF')
                .borderRadius(24)
                .shadow({
                  radius: 15,
                  color: '#00000008',
                  offsetX: 0,
                  offsetY: 4
                });
                Column({ space: 15 }) {
                  Row() {
                    Text('🕒 更新时间')
                      .fontSize(18)
                      .fontColor('#666666')
                      .flexGrow(1);
                    Text(this.weatherDetail.updateTime)
                      .fontSize(16)
                      .fontColor('#333333')
                      .fontWeight(FontWeight.Medium);
                  }
                  .width('100%')
                  .padding({ left: 25, right: 25 });

                  Text('数据来源于高德天气API')
                    .fontSize(12)
                    .fontColor('#999999')
                    .width('85%')
                    .textAlign(TextAlign.Center);
                }
                .width('90%')
                .padding({ top: 25, bottom: 25 })
                .backgroundColor('#FFFFFF')
                .borderRadius(24)
                .shadow({
                  radius: 15,
                  color: '#00000008',
                  offsetX: 0,
                  offsetY: 4
                });
                Column({ space: 12 }) {
                  Text('💡 温馨提示')
                    .fontSize(18)
                    .fontColor('#333333')
                    .fontWeight(FontWeight.Medium)
                    .width('100%')
                    .textAlign(TextAlign.Center);

                  Text('根据当前天气情况，建议您：')
                    .fontSize(14)
                    .fontColor('#666666')
                    .width('90%')
                    .textAlign(TextAlign.Center);

                  if (this.weatherDetail.weather.includes('雨')) {
                    Text('携带雨具，注意防雨')
                      .fontSize(14)
                      .fontColor('#FF6B6B')
                      .fontWeight(FontWeight.Medium);
                  } else if (this.weatherDetail.weather.includes('晴')) {
                    Text('适合户外活动，注意防晒')
                      .fontSize(14)
                      .fontColor('#4CAF50')
                      .fontWeight(FontWeight.Medium);
                  } else {
                    Text('天气适宜，注意适时增减衣物')
                      .fontSize(14)
                      .fontColor('#2196F3')
                      .fontWeight(FontWeight.Medium);
                  }
                }
                .width('90%')
                .padding({ top: 20, bottom: 20 })
                .backgroundColor('#FFFFFF')
                .borderRadius(24)
                .shadow({
                  radius: 15,
                  color: '#00000008',
                  offsetX: 0,
                  offsetY: 4
                })
                .margin({ bottom: 30 });
              }
              .width('100%')
              .alignItems(HorizontalAlign.Center);
            }
          }
          .width('100%')
          .padding({ top: 20, bottom: 30 })
        }
        .width('100%')
        .height('100%')
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .scrollBarColor('#CCCCCC')
      .scrollBarWidth(6)
      .flexGrow(1)
      .backgroundColor('#F8F9FA');
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA');
  }
}
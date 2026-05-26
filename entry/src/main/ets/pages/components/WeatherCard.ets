// components/WeatherCard.ets
import { WeatherInfo } from '../../model/WeatherModel';
import router from '@ohos.router';

@Component
export struct WeatherCard {
  @Prop weatherInfo: WeatherInfo | null = null;
  @Prop currentCity: string = '';

  onCitySelect?: () => void;
  onViewDetail?: () => void;

  private getWeatherIcon(weather: string): string {
    if (weather.includes('晴')) return '☀️';
    if (weather.includes('多云')) return '⛅';
    if (weather.includes('阴')) return '☁️';
    if (weather.includes('雨')) return '🌧️';
    if (weather.includes('雪')) return '❄️';
    if (weather.includes('雷')) return '⛈️';
    if (weather.includes('雾')) return '🌫️';
    return '🌈';
  }
  build() {
    Column({ space: 20 }) {
      if (this.weatherInfo) {
        // 主天气卡片
        Column({ space: 10 }) {
          Text(this.weatherInfo.city)
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333');

          Row({ space: 10 }) {
            Text(this.getWeatherIcon(this.weatherInfo.weather))
              .fontSize(64);
            Column({ space: 5 }) {
              Text(this.weatherInfo.temp)
                .fontSize(56)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333');
              Text(this.weatherInfo.weather)
                .fontSize(20)
                .fontColor('#666666');
            }
          }
        }
        .width('90%')
        .padding({ top: 20, bottom: 20 })
        .backgroundColor('#FFFFFF')
        .borderRadius(24)
        .shadow({ radius: 20, color: '#00000010', offsetX: 0, offsetY: 4 })
        .alignItems(HorizontalAlign.Center)
        .opacity(0.9);
        Grid() {
          GridItem() {
            Column({ space: 12 }) {
              Text('🌬️')
                .fontSize(28);
              Text('风向风力')
                .fontSize(14)
                .fontColor('#999999');
              Text(this.weatherInfo.wind)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333');
            }
            .width('100%')
            .padding(20)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .alignItems(HorizontalAlign.Center)
            .opacity(0.9);
          }

          GridItem() {
            Column({ space: 12 }) {
              Text('💧')
                .fontSize(28);
              Text('湿度')
                .fontSize(14)
                .fontColor('#999999');
              Text(this.weatherInfo.humidity)
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor('#333333');
            }
            .width('100%')
            .padding(20)
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .alignItems(HorizontalAlign.Center)
            .opacity(0.9);
          }
        }
        .columnsTemplate('1fr 1fr')
        .rowsTemplate('1fr')
        .columnsGap(15)
        .rowsGap(15)
        .width('90%')
        .height(140);

        Text(`🕒 更新时间: ${this.weatherInfo.updateTime}`)
          .fontSize(12)
          .fontColor('#999999')
          .margin({ top: 10 });

        Row({ space: 15 }) {
          Button() {
            Text('切换城市')
              .fontSize(16)
              .fontColor('#667eea')
          }
          .width(140)
          .height(48)
          .backgroundColor('#F0F0FF')
          .borderRadius(24)
          .onClick(() => {
            if (this.onCitySelect) {
              this.onCitySelect();
            } else {
              router.pushUrl({ url: 'pages/CitySelectPage' });
            }
          })

          Button() {
            Text('查看详情')
              .fontSize(16)
              .fontColor('#FFFFFF')
          }
          .width(140)
          .height(48)
          .backgroundColor('#667eea')
          .borderRadius(24)
          .onClick(() => {
            if (this.onViewDetail) {
              this.onViewDetail();
            } else {
              router.pushUrl({
                url: 'pages/WeatherDetailPage',
                params: { city: this.currentCity }
              });
            }
          })
        }
        .width('90%')
        .margin({ top: 20 })
        .justifyContent(FlexAlign.Center);
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center);
  }
}
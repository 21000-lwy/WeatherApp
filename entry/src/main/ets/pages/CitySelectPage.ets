// CitySelectPage.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { getRealTimeWeather } from '../service/WebService';
import { weatherStore } from '../model/WeatherStore';

@Entry
@Component
struct CitySelectPage {
  @State cityInput: string = '';
  @State loading: boolean = false;

  private handleCitySelect = async (): Promise<void> => {
    const targetCity = this.cityInput.trim();

    if (!targetCity) {
      promptAction.showToast({
        message: '请输入城市名称',
        duration: 1500
      });
      return;
    }

    this.loading = true;

    try {
      const weather = await getRealTimeWeather(targetCity);
      weatherStore.updateWeather(targetCity, weather);
      router.back();
    } catch (err) {
      const error = err as Error;

      promptAction.showToast({
        message: `查询失败: ${error.message}`,
        duration: 2000
      });
    } finally {
      this.loading = false;
    }
  };
  build() {
    Column({ space: 0 }) {
      Stack() {
        Column()
          .width('100%')
          .height(160)
          .backgroundColor('#ffdaeffe');
        Column() {
          Row({ space: 10 }) {
            Button() {
              Text('←')
                .fontSize(24)
                .fontColor('#ffbdd8f8')
            }
            .width(44)
            .height(44)
            .backgroundColor('#ff6f89cd')
            .borderRadius(22)
            .onClick(() => {
              router.back();
            })
            Text('选择城市')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#ff1c4966')
              .flexGrow(1);
          }
          .width('100%')
          .height(60)
          .padding({ left: 20, right: 20 })
          .alignItems(VerticalAlign.Center);
        }
        .width('100%')
        .margin({ top: 20 })
      }
      .width('100%')
      .height(120);
      Scroll() {
        Stack() {
          Image($r('app.media.bg2'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
            .opacity(0.6);
          Column({ space: 25 }) {
            Column({ space: 15 }) {
              Text('🔍 搜索城市天气')
                .fontSize(20)
                .fontColor('#333333')
                .fontWeight(FontWeight.Medium)
                .margin({ top: 20 })
                .margin({ bottom: 10 });
              Row() {
                TextInput({
                  placeholder: '请输入城市名称，如：北京、上海...',
                  text: this.cityInput
                })
                  .flexGrow(1)
                  .height(50)
                  .padding({ left: 20, right: 20 })
                  .backgroundColor('#FFFFFF')
                  .borderRadius(25)
                  .border({ width: 1, color: '#ffffffff' })
                  .placeholderColor('#999999')
                  .placeholderFont({ size: 16 })
                  .fontColor('#333333')
                  .fontSize(16)
                  .onChange((value: string) => {
                    this.cityInput = value;
                  });

                if (this.cityInput) {
                  Button() {
                    Text('×')
                      .fontSize(20)
                      .fontColor('#999999')
                  }
                  .width(35)
                  .height(40)
                  .backgroundColor('transparent')
                  .onClick(() => {
                    this.cityInput = '';
                  })
                }
              }
              .width('100%')
              .padding({ left: 20, right: 20 })
              .backgroundColor('#FFFFFF')
              .borderRadius(25)
              .shadow({
                radius: 10,
                color: '#00000008',
                offsetX: 0,
                offsetY: 4
              });
              Button() {
                if (this.loading) {
                  LoadingProgress()
                    .width(24)
                    .height(24)
                    .color('#FFFFFF')
                } else {
                  Row({ space: 8 }) {
                    Text('查询天气')
                      .fontSize(18)
                      .fontColor('#FFFFFF')
                  }
                }
              }
              .width('90%')
              .height(52)
              .margin({ top: 15 })
              .backgroundColor(this.cityInput.trim() ? '#667eea' : '#CCCCCC')
              .borderRadius(26)
              .enabled(!this.loading && !!this.cityInput.trim())
              .onClick(() => {
                this.handleCitySelect();
              })
            }
            .width('90%')
            .padding({ top: 20, bottom: 25, left: 20, right: 20 })
            .backgroundColor('#84ffffff')
            .borderRadius(24)
            .shadow({
              radius: 20,
              color: '#00000010',
              offsetX: 0,
              offsetY: 6
            });
            Column({ space: 15 }) {
              Row() {
                Text('🏙️ 热门城市')
                  .fontSize(18)
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Medium)
                  .flexGrow(1);
                Text('点击快速查询')
                  .fontSize(12)
                  .fontColor('#999999');
              }
              .width('100%')
              .margin({ bottom: 10 });
              Grid() {
                GridItem() {
                  Button() {
                    Text('北京')
                      .fontSize(15)
                      .fontColor('#333333')
                  }
                  .width('100%')
                  .height(42)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .onClick(() => {
                    this.cityInput = '北京';
                    setTimeout(() => {
                      this.handleCitySelect();
                    }, 100);
                  })
                }
                GridItem() {
                  Button() {
                    Text('上海')
                      .fontSize(15)
                      .fontColor('#333333')
                  }
                  .width('100%')
                  .height(42)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .onClick(() => {
                    this.cityInput = '上海';
                    setTimeout(() => {
                      this.handleCitySelect();
                    }, 100);
                  })
                }
                GridItem() {
                  Button() {
                    Text('广州')
                      .fontSize(15)
                      .fontColor('#333333')
                  }
                  .width('100%')
                  .height(42)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .onClick(() => {
                    this.cityInput = '广州';
                    setTimeout(() => {
                      this.handleCitySelect();
                    }, 100);
                  })
                }
                GridItem() {
                  Button() {
                    Text('深圳')
                      .fontSize(15)
                      .fontColor('#333333')
                  }
                  .width('100%')
                  .height(42)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .onClick(() => {
                    this.cityInput = '深圳';
                    setTimeout(() => {
                      this.handleCitySelect();
                    }, 100);
                  })
                }
                GridItem() {
                  Button() {
                    Text('杭州')
                      .fontSize(15)
                      .fontColor('#333333')
                  }
                  .width('100%')
                  .height(42)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .onClick(() => {
                    this.cityInput = '杭州';
                    setTimeout(() => {
                      this.handleCitySelect();
                    }, 100);
                  })
                }
                GridItem() {
                  Button() {
                    Text('成都')
                      .fontSize(15)
                      .fontColor('#333333')
                  }
                  .width('100%')
                  .height(42)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .onClick(() => {
                    this.cityInput = '成都';
                    setTimeout(() => {
                      this.handleCitySelect();
                    }, 100);
                  })
                }
                GridItem() {
                  Button() {
                    Text('武汉')
                      .fontSize(15)
                      .fontColor('#333333')
                  }
                  .width('100%')
                  .height(42)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .onClick(() => {
                    this.cityInput = '武汉';
                    setTimeout(() => {
                      this.handleCitySelect();
                    }, 100);
                  })
                }
                GridItem() {
                  Button() {
                    Text('西安')
                      .fontSize(15)
                      .fontColor('#333333')
                  }
                  .width('100%')
                  .height(42)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .onClick(() => {
                    this.cityInput = '西安';
                    setTimeout(() => {
                      this.handleCitySelect();
                    }, 100);
                  })
                }
              }
              .columnsTemplate('1fr 1fr 1fr')
              .rowsTemplate('1fr 1fr 1fr 1fr')
              .columnsGap(8)
              .rowsGap(8)
              .width('100%')
              .height(200);
              Text('💡 提示：请确保输入正确的城市全称，如"北京"、"上海"等')
                .fontSize(15)
                .fontColor('#666666')
                .width('100%')
                .textAlign(TextAlign.Center)
                .margin({ top: 10 });
            }
            .width('90%')
            .padding({ top: 20, bottom: 25, left: 20, right: 20 })
            .backgroundColor('#7fffffff')
            .borderRadius(24)
            .shadow({
              radius: 20,
              color: '#00000010',
              offsetX: 0,
              offsetY: 6
            });
          }
          .width('100%')
          .padding({ top: 20, bottom: 30 })
          .alignItems(HorizontalAlign.Center)
          .backgroundColor('transparent')
        }
        .width('100%')
        .height('100%')
      }
      .scrollable(ScrollDirection.Vertical)
      .flexGrow(1)
      .backgroundColor('transparent');
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8F9FA');
  }
}
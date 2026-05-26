// components/TopBar.ets
import router from '@ohos.router';
@Component
export struct TopBar {
  @Prop currentCity: string = '';
  onRefresh?: () => void;
  onSearch?: () => void;
  onSortHistory?: () => void;
  build() {
    Stack() {
      Column()
        .width('100%')
        .height(120)
        .linearGradient({
          angle: 180,
          colors: [
            [0x667eea, 0.0],
            [0x764ba2, 1.0]
          ]
        });
      Column({ space: 10 }) {
        Row({ space: 8 }) {
          Text('天气助手')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .flexGrow(1)
            .margin({ left: 20 });

          Button() {
            Image($r('app.media.ic_refresh'))
              .width(24)
              .height(24)
          }
          .width(44)
          .height(44)
          .backgroundColor('#ffcebcf3')
          .borderRadius(22)
          .onClick(() => {
            if (this.onRefresh) {
              this.onRefresh();
            }
            if (this.onSortHistory) {
              this.onSortHistory();
            }
          })
          Button() {
            Image($r('app.media.ic_search'))
              .width(24)
              .height(24)
          }
          .width(44)
          .height(44)
          .backgroundColor('#ffc9ddff')
          .borderRadius(22)
          .margin({ right: 20 })
          .onClick(() => {
            if (this.onSearch) {
              this.onSearch();
            } else {
              router.pushUrl({ url: 'pages/CitySelectPage' });
            }
          })
        }
        .width('100%')
        .height(60)
        .alignItems(VerticalAlign.Center);
        Row() {
          Text('📍 ')
            .fontSize(16)
            .fontColor('#FFFFFF');
          Text(this.currentCity)
            .fontSize(20)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium);
        }
        .width('100%')
        .justifyContent(FlexAlign.Center);
      }
      .width('100%')
      .margin({ top: 10 })
    }
    .width('100%')
    .height(120);
  }
}
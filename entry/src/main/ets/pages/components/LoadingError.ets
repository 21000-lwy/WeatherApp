// components/LoadingError.ets
@Component
export struct LoadingError {
  @Prop loading: boolean = false;
  @Prop errorMsg: string = '';
  @Prop currentCity: string = '';

  onRetry?: () => void;

  build() {
    Column() {
      if (this.loading) {
        Column() {
          LoadingProgress()
            .width(60)
            .height(60)
            .color('#764ba2');
          Text('正在获取天气数据...')
            .fontSize(16)
            .fontColor('#666666')
            .margin({ top: 15 });
        }
        .width('100%')
        .height(300)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      }
      else if (this.errorMsg) {
        Column({ space: 15 }) {
          Text('⚠️')
            .fontSize(60);
          Text('获取天气数据失败')
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
            if (this.onRetry) {
              this.onRetry();
            }
          })
        }
        .width('100%')
        .height(300)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      }
    }
  }
}
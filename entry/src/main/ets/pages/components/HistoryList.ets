// components/HistoryList.ets
import { HistoryCity } from '../../model/WeatherModel';

@Component
export struct HistoryList {
  @Prop historyCities: HistoryCity[] = [];
  @Prop currentCity: string = '';

  onDeleteItem?: (id: number) => void;
  onSwitchCity?: (city: string) => void;

  build() {
    Column({ space: 15 }) {
      Row() {
        Text('📜 历史查询')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .flexGrow(1);

        if (this.historyCities.length > 0) {
          Text(`共${this.historyCities.length}条`)
            .fontSize(14)
            .fontColor('#999999');
        }
      }
      .width('90%')
      .margin({ top: 30, bottom: 5 });

      if (this.historyCities.length === 0) {
        Column() {
          Text('📝')
            .fontSize(48);
          Text('暂无查询历史')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 10 });
          Text('切换城市查询天气后，会在这里显示记录')
            .fontSize(12)
            .fontColor('#CCCCCC')
            .margin({ top: 5 });
        }
        .width('100%')
        .height(150)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      } else {
        Column({ space: 12 }) {
          ForEach(this.historyCities, (item: HistoryCity, index: number) => {
            Row({ space: 12 }) {
              // 序号
              Column() {
                Text((index + 1).toString())
                  .fontSize(14)
                  .fontColor('#FFFFFF')
                  .fontWeight(FontWeight.Bold)
              }
              .width(30)
              .height(30)
              .backgroundColor('#667eea')
              .borderRadius(15)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center);

              Column({ space: 4 }) {
                Text(item.cityName)
                  .fontSize(16)
                  .fontColor('#333333')
                  .fontWeight(FontWeight.Medium);
                Text(item.queryTime)
                  .fontSize(12)
                  .fontColor('#999999');
              }
              .flexGrow(1);

              if (item.cityName === this.currentCity) {
                Column() {
                  Text('当前')
                    .fontSize(12)
                    .fontColor('#667eea')
                    .fontWeight(FontWeight.Medium)
                }
                .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                .backgroundColor('#66d6fff8')
                .borderRadius(12);
              }

              Button() {
                Text('×')
                  .fontSize(18)
                  .fontColor('#FF6B6B')
              }
              .width(32)
              .height(32)
              .backgroundColor('#ffffeafd')
              .borderRadius(16)
              .onClick(() => {
                if (this.onDeleteItem) {
                  this.onDeleteItem(item.id);
                }
              });
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 15, bottom: 15 })
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .opacity(0.9)
            .shadow({ radius: 5, color: '#00000005', offsetX: 0, offsetY: 2 })
            .onClick(() => {
              if (this.onSwitchCity) {
                this.onSwitchCity(item.cityName);
              }
            });
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20, bottom: 30 });
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center);
  }
}
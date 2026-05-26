import UIAbility from '@ohos.app.ability.UIAbility';
import window from '@ohos.window';
import { AbilityConstant, Want } from '@kit.AbilityKit';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    console.info('EntryAbility onCreate');
  }
  onDestroy() {
    console.info('EntryAbility onDestroy');
  }
  onWindowStageCreate(windowStage: window.WindowStage) {
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err) {
        console.error(`loadContent failed: ${JSON.stringify(err)}`);
      } else {
        console.info('loadContent success');
      }
    });
  }
  onWindowStageDestroy() {
    console.info('EntryAbility onWindowStageDestroy');
  }
  onForeground() {
    console.info('EntryAbility onForeground');
  }
  onBackground() {
    console.info('EntryAbility onBackground');
  }
}
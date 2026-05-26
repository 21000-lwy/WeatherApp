// Index.ets
import router from '@ohos.router';
import common from '@ohos.app.ability.common';
import promptAction from '@ohos.promptAction';
import { HistoryCity, WeatherInfo } from '../model/WeatherModel';
import { dbModel } from '../model/DatabaseModel';
import { getRealTimeWeather, initAmapConfig } from '../service/WebService';
import { weatherStore } from '../model/WeatherStore';
import { TopBar } from './components/TopBar';
import { LoadingError } from './components/LoadingError';
import { WeatherCard } from './components/WeatherCard';
import { HistoryList } from './components/HistoryList';

@Entry
@Component
struct Index {
  @State currentWeather: WeatherInfo | null = null;
  @State loading: boolean = false;
  @State errorMsg: string = '';
  @State currentCity: string = '北京';
  @State historyCities: HistoryCity[] = [];

  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  private weatherStoreListener?: (city: string, weather: WeatherInfo | null) => void;
  private fetchingPromise: Promise<void> | null = null;   // 当前正在进行的请求Promise
  private fetchingCity: string = '';                      // 正在请求的城市名

  async aboutToAppear(): Promise<void> {
    const context = getContext(this) as common.UIAbilityContext;
    await dbModel.init(context);
    await initAmapConfig(context);
    await this.loadInitialData();
  }
  private async loadInitialData(): Promise<void> {
    this.currentCity = weatherStore.currentCity;

    if (weatherStore.currentWeather) {
      this.currentWeather = weatherStore.currentWeather;
    } else {
      await this.fetchWeather(this.currentCity);
    }
    await this.loadHistoryCities();
    this.setupWeatherStoreListener();
  }
  private setupWeatherStoreListener(): void {
    this.weatherStoreListener = (city: string, weather: WeatherInfo | null) => {
      this.currentCity = city;
      if (weather) {
        this.currentWeather = weather;
        this.errorMsg = '';
      }
    };
    weatherStore.addListener(this.weatherStoreListener);
  }
  aboutToDisappear(): void {
    if (this.weatherStoreListener) {
      weatherStore.removeListener(this.weatherStoreListener);
    }
    this.fetchingPromise = null;
    this.fetchingCity = '';
  }
  async loadHistoryCities(): Promise<void> {
    try {
      const cities = await dbModel.getHistoryCities();
      this.historyCities = [...cities].sort((a, b) => {
        return new Date(b.queryTime).getTime() - new Date(a.queryTime).getTime();
      });
    } catch (err) {
      console.error('加载历史记录失败');
    }
  }
  async fetchWeather(city: string): Promise<void> {
    // 情况1：正在请求同一个城市 -> 直接返回已有的Promise，不发起新请求
    if (this.fetchingPromise && this.fetchingCity === city) {
      return this.fetchingPromise;
    }
    // 情况2：正在请求其他城市 -> 等待上一个请求完成（避免同时多个网络调用）
    if (this.fetchingPromise) {
      try {
        await this.fetchingPromise;
      } catch (e) {
        // 忽略上一个请求的错误，继续执行新请求
      }
    }

    // 开始新请求
    this.fetchingCity = city;
    this.fetchingPromise = (async () => {
      if (this.loading) return; // 已有加载状态，防止重复
      this.loading = true;
      this.errorMsg = '';
      try {
        const weather = await getRealTimeWeather(city);
        // 更新UI前再次检查城市是否变化，防止快速切换导致显示错误
        if (this.fetchingCity !== city) return;
        this.currentWeather = weather;
        this.currentCity = city;
        weatherStore.updateWeather(city, weather);
        await dbModel.addHistoryCity(city);
        await this.loadHistoryCities();
      } catch (err) {
        if (this.fetchingCity !== city) return;
        const error = err as Error;
        this.errorMsg = error.message;
        promptAction.showToast({
          message: `获取天气失败: ${error.message}`,
          duration: 2000
        });
      } finally {
        // 只有当前请求与完成时的城市一致才清理标志（防止覆盖新请求）
        if (this.fetchingCity === city) {
          this.loading = false;
          this.fetchingPromise = null;
          this.fetchingCity = '';
        }
      }
    })();
    return this.fetchingPromise;
  }
  async refreshWeather(): Promise<void> {
    if (this.currentCity) {
      await this.fetchWeather(this.currentCity);
    }
  }
  async switchCity(city: string): Promise<void> {
    if (city && city !== this.currentCity) {
      await this.fetchWeather(city);
    }
  }
  async deleteHistoryItem(id: number): Promise<void> {
    try {
      await dbModel.deleteHistoryCity(id);
      this.historyCities = this.historyCities.filter(item => item.id !== id);

      promptAction.showToast({
        message: '删除成功',
        duration: 1000
      });
    } catch (err) {
      console.error('删除历史记录失败');
      promptAction.showToast({
        message: '删除失败',
        duration: 1500
      });
    }
  }
  build() {
    Stack() {
      Image($r('app.media.bg'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .opacity(0.6)

      Column({ space: 0 }) {
        TopBar({
          currentCity: this.currentCity,
          onRefresh: () => { this.refreshWeather(); },
          onSearch: () => {
            router.pushUrl({ url: 'pages/CitySelectPage' });
          }
        })
        Scroll() {
          Column({ space: 20 }) {
            LoadingError({
              loading: this.loading,
              errorMsg: this.errorMsg,
              currentCity: this.currentCity,
              onRetry: () => { this.fetchWeather(this.currentCity); }
            })
            if (!this.loading && !this.errorMsg && this.currentWeather) {
              WeatherCard({
                weatherInfo: this.currentWeather,
                currentCity: this.currentCity,
                onCitySelect: () => {
                  router.pushUrl({ url: 'pages/CitySelectPage' });
                },
                onViewDetail: () => {
                  router.pushUrl({
                    url: 'pages/WeatherDetailPage',
                    params: { city: this.currentCity }
                  });
                }
              })
            }
            HistoryList({
              historyCities: this.historyCities,
              currentCity: this.currentCity,
              onDeleteItem: (id: number) => {
                this.deleteHistoryItem(id);
              },
              onSwitchCity: (city: string) => {
                this.switchCity(city);
              }
            })
            Blank()
              .height(50)
          }
          .width('100%')
          .padding({ top: 10, bottom: 20 })
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)
        .scrollBarColor('#CCCCCC')
        .scrollBarWidth(6)
        .edgeEffect(EdgeEffect.Spring)
        .flexGrow(1)
        .backgroundColor('transparent')
      }
      .width('100%')
      .height('100%')

    }
    .width('100%')
    .height('100%')
    .backgroundColor('#ffe7d7ff')
  }
}
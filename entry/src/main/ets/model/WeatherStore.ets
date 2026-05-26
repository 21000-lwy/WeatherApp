import { WeatherInfo, HistoryCity } from './WeatherModel';

class WeatherStore {
  private static instance: WeatherStore;
  private _currentWeather: WeatherInfo | null = null;
  private _currentCity: string = '北京';
  private _historyCities: HistoryCity[] = [];
  private listeners: Array<(city: string, weather: WeatherInfo | null) => void> = [];

  static getInstance(): WeatherStore {
    if (!WeatherStore.instance) {
      WeatherStore.instance = new WeatherStore();
    }
    return WeatherStore.instance;
  }
  get currentCity(): string {
    return this._currentCity;
  }
  get currentWeather(): WeatherInfo | null {
    return this._currentWeather;
  }
  get historyCities(): HistoryCity[] {
    return this._historyCities;
  }
  updateWeather(city: string, weather: WeatherInfo): void {
    this._currentCity = city;
    this._currentWeather = weather;
    this.listeners.forEach(listener => {
      listener(city, weather);
    });
  }
  updateHistory(history: HistoryCity[]): void {
    this._historyCities = history;
  }
  addListener(listener: (city: string, weather: WeatherInfo | null) => void): void {
    this.listeners.push(listener);
  }
  removeListener(listener: (city: string, weather: WeatherInfo | null) => void): void {
    const index = this.listeners.indexOf(listener);
    if (index > -1) {
      this.listeners.splice(index, 1);
    }
  }
}
export const weatherStore = WeatherStore.getInstance();
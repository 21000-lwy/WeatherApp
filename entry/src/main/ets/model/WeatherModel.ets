export interface WeatherInfo {
  city: string; // 城市名
  temp: string; // 温度
  weather: string; // 天气状况（晴/雨/多云等）
  wind: string; // 风向风力
  humidity: string; // 湿度
  updateTime: string; // 更新时间
}
export interface HistoryCity {
  id: number;          // 主键
  cityName: string;    // 城市名
  queryTime: string;   // 查询时间
}
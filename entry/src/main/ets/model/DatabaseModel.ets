import relationalStore from '@ohos.data.relationalStore';
import { HistoryCity } from './WeatherModel';
import common from '@ohos.app.ability.common';

const DB_NAME = 'weather_db.db';
const TABLE_NAME = 'history_city';
const CREATE_TABLE_SQL = `CREATE TABLE IF NOT EXISTS ${TABLE_NAME} (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  cityName TEXT NOT NULL,
  queryTime TEXT NOT NULL
)`;
export class DatabaseModel {
  private rdbStore: relationalStore.RdbStore | null = null;
  async init(context: common.UIAbilityContext): Promise<void> {
    try {
      const config: relationalStore.StoreConfig = {
        name: DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1
      };
      this.rdbStore = await relationalStore.getRdbStore(context, config);
      await this.rdbStore.executeSql(CREATE_TABLE_SQL);
    } catch (err) {
      console.error('数据库初始化失败');
    }
  }

  async addHistoryCity(cityName: string): Promise<void> {
    if (!this.rdbStore) return;
    try {
      // 1. 删除该城市的所有旧记录
      const deletePredicates = new relationalStore.RdbPredicates(TABLE_NAME);
      deletePredicates.equalTo('cityName', cityName);
      await this.rdbStore.delete(deletePredicates);

      // 2. 插入新记录
      const now = new Date().toLocaleString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        hour12: false
      });
      const valueBucket: relationalStore.ValuesBucket = {
        cityName: cityName,
        queryTime: now
      };
      await this.rdbStore.insert(TABLE_NAME, valueBucket);
    } catch (err) {
      console.error('添加历史城市失败', err);
    }
  }
  async getHistoryCities(): Promise<HistoryCity[]> {
    if (!this.rdbStore) return [];
    try {
      const columns = ['id', 'cityName', 'queryTime'];
      const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
      predicates.orderByDesc('id');
      const resultSet = await this.rdbStore.query(predicates, columns);
      const cities: HistoryCity[] = [];
      while (resultSet.goToNextRow()) {
        cities.push({
          id: resultSet.getLong(resultSet.getColumnIndex('id')),
          cityName: resultSet.getString(resultSet.getColumnIndex('cityName')),
          queryTime: resultSet.getString(resultSet.getColumnIndex('queryTime'))
        });
      }
      resultSet.close();
      return cities;
    } catch (err) {
      console.error('查询历史城市失败');
      return [];
    }
  }
  async deleteHistoryCity(id: number): Promise<void> {
    if (!this.rdbStore) return;
    try {
      const predicates = new relationalStore.RdbPredicates(TABLE_NAME);
      predicates.equalTo('id', id);
      await this.rdbStore.delete(predicates);
    } catch (err) {
      console.error('删除历史城市失败');
    }
  }
}
export const dbModel = new DatabaseModel();
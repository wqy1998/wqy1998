import { common, StartupTask } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';

@Sendable
export default class CreateDB extends StartupTask {
  constructor() {
    super()
  }

  async init(context: common.AbilityStageContext) {
    hilog.info(0x0000, 'testTag', 'CreateDB init.');
    let rdb = this.getRdb(context)
    return "rdb"
  }

  async getRdb(context: common.AbilityStageContext): Promise<relationalStore.RdbStore> {
    hilog.info(0x0000, 'testTag', 'Go to getRdb().');
    const storeConfig: relationalStore.StoreConfig = {
      name: 'bills.db',
      securityLevel: relationalStore.SecurityLevel.S4,
      encrypt: true,
      customDir: 'bill',
      allowRebuild: true
    }
    let rdb = await relationalStore.getRdbStore(context, storeConfig)
    if (rdb) {
      hilog.info(0x0000, 'testTag', 'Succeeded in getting RdbStore.');
    }
    await this.createTable(rdb)
    return rdb
  }

  async createTable(rdbStore?: relationalStore.RdbStore): Promise<void> {
    hilog.info(0x0000, 'testTag', `Go to createTable().`)

    const SQL_CREATE_BILLS =
      'CREATE TABLE IF NOT EXISTS BILLS (ID INTEGER PRIMARY KEY AUTOINCREMENT, COST REAL NOT NULL, PAY_APP TEXT NOT NULL, PAY_ACCOUNT TEXT NOT NULL, CLASSIFICATION TEXT NOT NULL, CREATE_TIME DATETIME NOT NULL, PAY_TIME DATETIME NOT NULL, YEAR INTEGER NOT NULL, MONTH INTEGER NOT NULL, DAY INTEGER NOT NULL, NOTES TEXT);'
    const SQL_CREATE_CLASSIFICATION =
      'CREATE TABLE IF NOT EXISTS CLASSIFICATION (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT UNIQUE NOT NULL);'
    const SQL_CREATE_PAY_APP =
      'CREATE TABLE IF NOT EXISTS PAY_APP (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT UNIQUE NOT NULL);'
    const SQL_CREATE_PAY_ACCOUNT =
      'CREATE TABLE IF NOT EXISTS PAY_ACCOUNT (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT UNIQUE NOT NULL, AMOUNT REAL NOT NULL DEFAULT 0);'
    // 当数据库创建时，数据库默认版本为0
    if (rdbStore && rdbStore.version === 0) {
      hilog.info(0x0000, 'testTag', `go to excuteSql`);
      await rdbStore.executeSql(SQL_CREATE_BILLS);
      await rdbStore.executeSql(SQL_CREATE_CLASSIFICATION); // 创建数据表
      await rdbStore.executeSql(SQL_CREATE_PAY_APP);
      await rdbStore.executeSql(SQL_CREATE_PAY_ACCOUNT);
      // 设置数据库的版本，入参为大于0的整数
      rdbStore.version = 1
    }
    hilog.info(0x0000, 'testTag', `Succeeded in creating tables.`)
  }
}

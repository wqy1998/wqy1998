import { abilityAccessCtrl, AbilityConstant, common, PermissionRequestResult, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppStorageV2, window } from '@kit.ArkUI';
import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { ArrayList } from '@kit.ArkTS';
import PayApp from '../startup/PayApp';
import Bills from '@livingbills/bills/src/main/ets/model/Bills';
import Classification from '../startup/Classification';
import PayAccount from '../startup/PayAccount';

let rdb: relationalStore.RdbStore | undefined = undefined

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    let AtManager = abilityAccessCtrl.createAtManager();
    AtManager.requestPermissionsFromUser(this.context, ['ohos.permission.READ_MEDIA', 'ohos.permission.MEDIA_LOCATION'])
      .then((data: PermissionRequestResult) => {
        hilog.info(0x0000, 'testTag', '%{public}s', 'request permissions from user success' + data);
      })
      .catch((err: Object) => {
        hilog.error(0x0000, 'testTag', 'Failed to request permissions from user. Cause: %{public}s',
          JSON.stringify(err) ?? '');
      });
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    // 检查数据库是否存在，不存在则创建并获取RdbStore，存在则获取RdbStore
    this.getRdb();
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }

  async getRdb(): Promise<void> {
    hilog.info(0x0000, 'testTag', 'get rdb in onCreate.');

    const storeConfig: relationalStore.StoreConfig = {
      name: 'bills.db',
      securityLevel: relationalStore.SecurityLevel.S4,
      encrypt: true,
      customDir: 'bill',
      allowRebuild: true
    }
    rdb = await relationalStore.getRdbStore(this.context.getApplicationContext(), storeConfig);
    AppStorage.setOrCreate('billsRdb', rdb);
    hilog.info(0x0000, 'testTag', `Go to createTable().`);

    const SQL_CREATE_BILLS =
      'CREATE TABLE IF NOT EXISTS BILLS (ID INTEGER PRIMARY KEY AUTOINCREMENT, COST REAL NOT NULL, PAY_APP TEXT NOT NULL, PAY_ACCOUNT TEXT NOT NULL, CLASSIFICATION TEXT NOT NULL, CREATE_TIME DATETIME NOT NULL, PAY_TIME DATETIME NOT NULL, YEAR INTEGER NOT NULL, MONTH INTEGER NOT NULL,DATE INTEGER NOT NULL, DAY INTEGER NOT NULL, NOTES TEXT);';
    const SQL_CREATE_CLASSIFICATION =
      'CREATE TABLE IF NOT EXISTS CLASSIFICATION (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT UNIQUE NOT NULL);';
    const SQL_CREATE_PAY_APP =
      'CREATE TABLE IF NOT EXISTS PAY_APP (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT UNIQUE NOT NULL);';
    const SQL_CREATE_PAY_ACCOUNT =
      'CREATE TABLE IF NOT EXISTS PAY_ACCOUNT (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT UNIQUE NOT NULL, AMOUNT REAL NOT NULL DEFAULT 0);';
    // 当数据库创建时，数据库默认版本为0
    if (rdb && rdb.version === 0) {
      hilog.info(0x0000, 'testTag', `go to excuteSql`);
      // 创建账单表
      await rdb.executeSql(SQL_CREATE_BILLS);
      // 初始化插入账单表
      const first: relationalStore.ValuesBucket = {
        COST: 20.5,
        PAY_APP: '支付宝',
        PAY_ACCOUNT: '123',
        CLASSIFICATION: '456',
        CREATE_TIME: new Date().toDateString(),
        PAY_TIME: new Date().toDateString(),
        YEAR: new Date().getFullYear(),
        MONTH: new Date().getMonth(),
        DATE: new Date().getDate(),
        DAY: new Date().getDay(),
        NOTES: '789'
      }
      rdb.insertSync("BILLS", first)
      // 创建账单分类表
      await rdb.executeSql(SQL_CREATE_CLASSIFICATION);
      // 创建支付APP表
      await rdb.executeSql(SQL_CREATE_PAY_APP);
      // 初始化插入支付APP表
      const ZFB: relationalStore.ValuesBucket = {
        NAME: '支付宝'
      };
      const WeChat: relationalStore.ValuesBucket = {
        NAME: '微信'
      };
      let valueBuckets = new Array(ZFB, WeChat);
      rdb.batchInsertSync("PAY_APP", valueBuckets);
      // 创建支付账户表
      await rdb.executeSql(SQL_CREATE_PAY_ACCOUNT);
      // 设置数据库的版本，入参为大于0的整数
      rdb.version = 1;
    }
    hilog.info(0x0000, 'testTag', `Succeeded in creating tables. version = ${rdb.version}`);

    // 获取当前时间
    let time = new Date();
    AppStorage.setOrCreate('today',time)
    let year = time.getFullYear();
    AppStorage.setOrCreate('year',year)
    let month = time.getMonth();
    AppStorage.setOrCreate('month',month)
    let date = time.getDate();
    AppStorage.setOrCreate('date',date)

    // 查询账单表
    // 创建查询数据的关系谓词
    let billsPredicates = new relationalStore.RdbPredicates("BILLS");
    billsPredicates.equalTo("YEAR", year).equalTo("MONTH", month).equalTo("DATE", date);
    let billsResultSet = rdb.querySync(billsPredicates);
    let billsList: Array<Bills> = new Array()
    while (billsResultSet.goToNextRow()) {
      billsList.push(new Bills(billsResultSet.getLong(billsResultSet.getColumnIndex("ID")),
        billsResultSet.getDouble(billsResultSet.getColumnIndex("COST")),
        billsResultSet.getString(billsResultSet.getColumnIndex("PAY_APP")),
        billsResultSet.getString(billsResultSet.getColumnIndex("PAY_ACCOUNT")),
        billsResultSet.getString(billsResultSet.getColumnIndex("CLASSIFICATION")),
        new Date(billsResultSet.getString(billsResultSet.getColumnIndex("CREATE_TIME"))),
        new Date(billsResultSet.getString(billsResultSet.getColumnIndex("PAY_TIME"))),
        billsResultSet.getLong(billsResultSet.getColumnIndex("YEAR")),
        billsResultSet.getLong(billsResultSet.getColumnIndex("MONTH")),
        billsResultSet.getLong(billsResultSet.getColumnIndex("DATE")),
        billsResultSet.getLong(billsResultSet.getColumnIndex("DAY")),
        billsResultSet.getString(billsResultSet.getColumnIndex("NOTES"))));
      hilog.info(0x0000, 'testTag', `time = ${billsResultSet.getDouble(billsResultSet.getColumnIndex("COST"))}`);
    }
    AppStorage.setOrCreate("billsList", billsList);

    // 查询分类表
    let classificationPredicates = new relationalStore.RdbPredicates("CLASSIFICATION");
    let classificationResultSet = rdb.querySync(classificationPredicates);
    let classificationList: ArrayList<Classification> = new ArrayList()
    while (classificationResultSet.goToNextRow()) {
      classificationList.add(new Classification(classificationResultSet.getLong(classificationResultSet.getColumnIndex("ID")),
        classificationResultSet.getString(classificationResultSet.getColumnIndex("NAME"))))
    }
    AppStorage.setOrCreate("classificationList", classificationList);

    // 查询支付APP表
    let payAppPredicates = new relationalStore.RdbPredicates("PAY_APP");
    let payAppResultSet = rdb.querySync(payAppPredicates);
    hilog.info(0x0000, 'testTag', `payAppResultSet size = ${payAppResultSet.rowCount}`)
    let payAppList: ArrayList<PayApp> = new ArrayList()
    while (payAppResultSet.goToNextRow()) {
      payAppList.add(new PayApp(payAppResultSet.getLong(payAppResultSet.getColumnIndex("ID")),
        payAppResultSet.getString(payAppResultSet.getColumnIndex("NAME"))));
    }
    hilog.info(0x0000, 'testTag', `payAppList size = ${payAppList.length}`);
    AppStorage.setOrCreate("payAppList", payAppList);

    // 查询支付账户表
    let payAccountPredicates = new relationalStore.RdbPredicates("PAY_ACCOUNT");
    let payAccountResultSet = rdb.querySync(payAccountPredicates);
    let payAccountList: ArrayList<PayAccount> = new ArrayList()
    while (payAccountResultSet.goToNextRow()) {
      payAccountList.add(new PayAccount(payAccountResultSet.getLong(payAccountResultSet.getColumnIndex("ID")),
        payAppResultSet.getString(payAccountResultSet.getColumnIndex("NAME")),
        payAppResultSet.getDouble(payAccountResultSet.getColumnIndex("AMOUNT"))))
    }
    AppStorage.setOrCreate("payAccountList", payAccountList);
  }
}

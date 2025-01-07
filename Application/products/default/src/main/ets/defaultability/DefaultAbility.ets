import { abilityAccessCtrl, AbilityConstant, PermissionRequestResult, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { preferences, relationalStore } from '@kit.ArkData';
import { ArrayList, buffer } from '@kit.ArkTS';
import PayApp from '@livingbills/rdbcrud/src/main/ets/model/PayApp';
import Bills from '@livingbills/rdbcrud/src/main/ets/model/Bills';
import Classification from '@livingbills/rdbcrud/src/main/ets/model/Classification';
import PayAccount from '@livingbills/rdbcrud/src/main/ets/model/PayAccount';
import auth from '@hw-agconnect/auth';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    let file = this.context.resourceManager.getRawFileContentSync('agconnect-services.json');
    let json: string = buffer.from(file.buffer).toString();
    auth.init(this.context, json);
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
      PersistentStorage.persistProps([{
        key: 'authCode', defaultValue: undefined
      }, {
        key: 'openID', defaultValue: undefined
      }, {
        key: 'unionID', defaultValue: undefined
      }, {
        key: 'idToken', defaultValue: undefined
      }, {
        key: 'nickName', defaultValue: undefined
      }, {
        key: 'avatarUri', defaultValue: $r('sys.symbol.person_2_fill')
      }])
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
    let rdb = await relationalStore.getRdbStore(this.context, storeConfig)
    hilog.info(0x0000, 'testTag', `Go to createTable().`);

    const SQL_CREATE_BILLS =
      'CREATE TABLE IF NOT EXISTS BILLS (ID INTEGER PRIMARY KEY AUTOINCREMENT, COST REAL NOT NULL, TYPE INTEGER NOT NULL CHECK(TYPE >= 0 AND TYPE <= 2), PAY_APP INTEGER, PAY_ACCOUNT INTEGER, CLASSIFICATION INTEGER, CREATE_TIME DATETIME NOT NULL, PAY_TIME DATETIME NOT NULL, YEAR INTEGER NOT NULL, MONTH INTEGER NOT NULL,DATE INTEGER NOT NULL, DAY INTEGER NOT NULL, NOTES TEXT);'
    const SQL_CREATE_CLASSIFICATION =
      'CREATE TABLE IF NOT EXISTS CLASSIFICATION (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT UNIQUE NOT NULL, CREATE_TIME DATETIME NOT NULL);'
    const SQL_CREATE_PAY_APP =
      'CREATE TABLE IF NOT EXISTS PAY_APP (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT UNIQUE NOT NULL, CREATE_TIME DATETIME NOT NULL);'
    const SQL_CREATE_PAY_ACCOUNT =
      'CREATE TABLE IF NOT EXISTS PAY_ACCOUNT (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT UNIQUE NOT NULL, AMOUNT REAL NOT NULL DEFAULT 0, CREATE_TIME DATETIME NOT NULL);'
    // 当数据库创建时，数据库默认版本为0
    if (rdb && rdb.version === 0) {
      hilog.info(0x0000, 'testTag', `go to excuteSql`);
      // 创建账单表
      await rdb.executeSql(SQL_CREATE_BILLS);
      // 初始化插入账单表
      const firstBill: relationalStore.ValuesBucket = {
        COST: 20.5,
        TYPE: 1,
        PAY_APP: 1,
        PAY_ACCOUNT: 1,
        CLASSIFICATION: 1,
        CREATE_TIME: new Date().toString(),
        PAY_TIME: new Date().toString(),
        YEAR: new Date().getFullYear(),
        MONTH: new Date().getMonth(),
        DATE: new Date().getDate(),
        DAY: new Date().getDay(),
        NOTES: '789'
      }
      rdb.insertSync("BILLS", firstBill)
      // 创建账单分类表
      await rdb.executeSql(SQL_CREATE_CLASSIFICATION);
      // 初始化插入分类表
      const firstClassification1: relationalStore.ValuesBucket = {
        NAME: '早餐',
        CREATE_TIME: new Date().toString()
      }
      const firstClassification2: relationalStore.ValuesBucket = {
        NAME: '午餐',
        CREATE_TIME: new Date().toString()
      }
      const firstClassification3: relationalStore.ValuesBucket = {
        NAME: '晚餐',
        CREATE_TIME: new Date().toString()
      }
      const firstClassification4: relationalStore.ValuesBucket = {
        NAME: '交通',
        CREATE_TIME: new Date().toString()
      }
      const firstClassification5: relationalStore.ValuesBucket = {
        NAME: '平账',
        CREATE_TIME: new Date().toString()
      }
      let claValueBuckets =
        new Array(firstClassification1, firstClassification2, firstClassification3, firstClassification4,
          firstClassification5)
      rdb.batchInsertSync("CLASSIFICATION", claValueBuckets)
      // 创建支付APP表
      await rdb.executeSql(SQL_CREATE_PAY_APP);
      // 初始化插入支付APP表
      const ZFB: relationalStore.ValuesBucket = {
        NAME: '支付宝',
        CREATE_TIME: new Date().toString(),
      };
      const WeChat: relationalStore.ValuesBucket = {
        NAME: '微信',
        CREATE_TIME: new Date().toString(),
      };
      let valueBuckets = new Array(ZFB, WeChat);
      rdb.batchInsertSync("PAY_APP", valueBuckets);
      // 创建支付账户表
      await rdb.executeSql(SQL_CREATE_PAY_ACCOUNT);
      // 初始化插入支付账户表
      const firstPayAccount: relationalStore.ValuesBucket = {
        NAME: '默认账户',
        CREATE_TIME: new Date().toString(),
      }
      rdb.insertSync("PAY_ACCOUNT", firstPayAccount)
      // 设置数据库的版本，入参为大于0的整数
      rdb.version = 1;
    }
    hilog.info(0x0000, 'testTag', `Succeeded in creating tables. version = ${rdb.version}`);

    // 获取当前时间
    let time = new Date();
    AppStorage.setOrCreate('today', time)
    let year = time.getFullYear();
    AppStorage.setOrCreate('year', year)
    let month = time.getMonth();
    AppStorage.setOrCreate('month', month)
    let date = time.getDate();
    AppStorage.setOrCreate('date', date)

    // 查询账单表
    // 创建查询数据的关系谓词
    let billsPredicates = new relationalStore.RdbPredicates("BILLS");
    billsPredicates.equalTo("YEAR", year).equalTo("MONTH", month).orderByDesc("PAY_TIME")
    let billsResultSet = rdb.querySync(billsPredicates);
    let billsList: Array<Bills> = new Array()
    let currentMonthExpense: number = 0
    let currentMonthIncome: number = 0
    let currentDayExpense: number = 0
    let currentDayIncome: number = 0
    while (billsResultSet.goToNextRow()) {
      if (billsResultSet.getLong(billsResultSet.getColumnIndex("YEAR")) == year &&
        billsResultSet.getLong(billsResultSet.getColumnIndex("MONTH")) == month) {
        if (billsResultSet.getLong(billsResultSet.getColumnIndex("TYPE")) == 0) {
          currentMonthExpense = currentMonthExpense + billsResultSet.getDouble(billsResultSet.getColumnIndex("COST"))
        }
        if (billsResultSet.getLong(billsResultSet.getColumnIndex("TYPE")) == 1) {
          currentMonthIncome = currentMonthIncome + billsResultSet.getDouble(billsResultSet.getColumnIndex("COST"))
        }
      }
      if (billsResultSet.getLong(billsResultSet.getColumnIndex("YEAR")) == year &&
        billsResultSet.getLong(billsResultSet.getColumnIndex("MONTH")) == month &&
        billsResultSet.getLong(billsResultSet.getColumnIndex("DATE")) == date) {
        if (billsResultSet.getLong(billsResultSet.getColumnIndex("TYPE")) == 0) {
          currentDayExpense = currentDayExpense + billsResultSet.getDouble(billsResultSet.getColumnIndex("COST"))
        }
        if (billsResultSet.getLong(billsResultSet.getColumnIndex("TYPE")) == 1) {
          currentDayIncome = currentDayIncome + billsResultSet.getDouble(billsResultSet.getColumnIndex("COST"))
        }
      }
      billsList.push(new Bills(billsResultSet.getLong(billsResultSet.getColumnIndex("ID")),
        billsResultSet.getDouble(billsResultSet.getColumnIndex("COST")),
        billsResultSet.getLong(billsResultSet.getColumnIndex("TYPE")),
        billsResultSet.getLong(billsResultSet.getColumnIndex("PAY_APP")),
        billsResultSet.getLong(billsResultSet.getColumnIndex("PAY_ACCOUNT")),
        billsResultSet.getLong(billsResultSet.getColumnIndex("CLASSIFICATION")),
        billsResultSet.getString(billsResultSet.getColumnIndex("CREATE_TIME")),
        billsResultSet.getString(billsResultSet.getColumnIndex("PAY_TIME")),
        billsResultSet.getLong(billsResultSet.getColumnIndex("YEAR")),
        billsResultSet.getLong(billsResultSet.getColumnIndex("MONTH")),
        billsResultSet.getLong(billsResultSet.getColumnIndex("DATE")),
        billsResultSet.getLong(billsResultSet.getColumnIndex("DAY")),
        billsResultSet.getString(billsResultSet.getColumnIndex("NOTES"))));
      hilog.info(0x0000, 'testTag', `time = ${billsResultSet.getDouble(billsResultSet.getColumnIndex("COST"))}`);
    }
    AppStorage.setOrCreate("billsList", billsList)
    AppStorage.setOrCreate("currentMonthExpense", currentMonthExpense)
    AppStorage.setOrCreate("currentMonthIncome", currentMonthIncome)
    AppStorage.setOrCreate("currentDayExpense", currentDayExpense)
    AppStorage.setOrCreate("currentDayIncome", currentDayIncome)

    // 查询分类表
    let classificationPredicates = new relationalStore.RdbPredicates("CLASSIFICATION");
    let classificationResultSet = rdb.querySync(classificationPredicates);
    let classificationList: ArrayList<Classification> = new ArrayList()
    let classificationMap: Map<number, string> = new Map()
    while (classificationResultSet.goToNextRow()) {
      classificationList.add(new Classification(classificationResultSet.getLong(classificationResultSet.getColumnIndex("ID")),
        classificationResultSet.getString(classificationResultSet.getColumnIndex("NAME")),
        classificationResultSet.getString(classificationResultSet.getColumnIndex('CREATE_TIME'))))
      classificationMap.set(classificationResultSet.getLong(classificationResultSet.getColumnIndex("ID")),
        classificationResultSet.getString(classificationResultSet.getColumnIndex("NAME")))
    }
    AppStorage.setOrCreate("classificationList", classificationList)
    AppStorage.setOrCreate("classificationMap", classificationMap)

    // 查询支付APP表
    let payAppPredicates = new relationalStore.RdbPredicates("PAY_APP");
    let payAppResultSet = rdb.querySync(payAppPredicates);
    hilog.info(0x0000, 'testTag', `payAppResultSet size = ${payAppResultSet.rowCount}`)
    let payAppList: ArrayList<PayApp> = new ArrayList()
    let payAppMap: Map<number, string> = new Map()
    while (payAppResultSet.goToNextRow()) {
      payAppList.add(new PayApp(payAppResultSet.getLong(payAppResultSet.getColumnIndex("ID")),
        payAppResultSet.getString(payAppResultSet.getColumnIndex("NAME")),
        payAppResultSet.getString(payAppResultSet.getColumnIndex('CREATE_TIME'))))
      payAppMap.set(payAppResultSet.getLong(payAppResultSet.getColumnIndex("ID")),
        payAppResultSet.getString(payAppResultSet.getColumnIndex("NAME")))
    }
    hilog.info(0x0000, 'testTag', `payAppList size = ${payAppList.length}`);
    AppStorage.setOrCreate("payAppList", payAppList)
    AppStorage.setOrCreate("payAppMap", payAppMap)

    // 查询支付账户表
    let payAccountPredicates = new relationalStore.RdbPredicates("PAY_ACCOUNT");
    let payAccountResultSet = rdb.querySync(payAccountPredicates);
    let payAccountList: ArrayList<PayAccount> = new ArrayList()
    let payAccountMap: Map<number, string[]> = new Map()
    while (payAccountResultSet.goToNextRow()) {
      payAccountList.add(new PayAccount(payAccountResultSet.getLong(payAccountResultSet.getColumnIndex("ID")),
        payAccountResultSet.getString(payAccountResultSet.getColumnIndex("NAME")),
        payAccountResultSet.getDouble(payAccountResultSet.getColumnIndex("AMOUNT")),
        payAccountResultSet.getString(payAccountResultSet.getColumnIndex('CREATE_TIME'))))
      payAccountMap.set(payAccountResultSet.getLong(payAccountResultSet.getColumnIndex("ID")),
        [payAccountResultSet.getString(payAccountResultSet.getColumnIndex("NAME")),
          payAccountResultSet.getDouble(payAccountResultSet.getColumnIndex("AMOUNT")).toString()])
    }
    AppStorage.setOrCreate("payAccountList", payAccountList)
    AppStorage.setOrCreate("payAccountMap", payAccountMap)
  }
}

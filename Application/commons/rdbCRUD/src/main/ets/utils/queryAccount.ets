import { relationalStore } from "@kit.ArkData"
import PayAccount from "../model/PayAccount"

@Concurrent
export async function queryAccount(context: Context) {
  const storeConfig: relationalStore.StoreConfig = {
    name: 'bills.db',
    securityLevel: relationalStore.SecurityLevel.S4,
    encrypt: true,
    customDir: 'bill',
    allowRebuild: true
  }
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, storeConfig)
  let predicate = new relationalStore.RdbPredicates('PAY_ACCOUNT')
  let resultSet: relationalStore.ResultSet = store.querySync(predicate)
  let payAccountList: Array<PayAccount> = new Array()
  let payAccountMap: Map<number, string[]> = new Map()
  while (resultSet.goToNextRow()) {
    payAccountList.push(new PayAccount(resultSet.getLong(resultSet.getColumnIndex("ID")),
      resultSet.getString(resultSet.getColumnIndex("NAME")),
      resultSet.getDouble(resultSet.getColumnIndex("AMOUNT")),
      resultSet.getString(resultSet.getColumnIndex('CREATE_TIME'))))
    payAccountMap.set(resultSet.getLong(resultSet.getColumnIndex("ID")),
      [resultSet.getString(resultSet.getColumnIndex("NAME")),
        resultSet.getDouble(resultSet.getColumnIndex("AMOUNT")).toString()])
  }
  return [payAccountList, payAccountMap]
}
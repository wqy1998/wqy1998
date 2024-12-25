import { relationalStore } from "@kit.ArkData"
import Bills from "../model/Bills"

@Concurrent
export async function queryBill(context: Context, queryYear: number, queryMonth: number) {
  const storeConfig: relationalStore.StoreConfig = {
    name: 'bills.db',
    securityLevel: relationalStore.SecurityLevel.S4,
    encrypt: true,
    customDir: 'bill',
    allowRebuild: true
  }
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, storeConfig)
  let predicate: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('BILLS')
  predicate.equalTo('YEAR', queryYear).equalTo('MONTH', queryMonth).orderByDesc('PAY_TIME')
  let billsResultSet = store.querySync(predicate)
  let billsList: Array<Bills> = new Array()
  while (billsResultSet.goToNextRow()) {
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
      billsResultSet.getString(billsResultSet.getColumnIndex("NOTES"))))
  }
  return billsList
}
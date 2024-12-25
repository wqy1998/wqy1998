import { relationalStore } from "@kit.ArkData"

@Concurrent
export async function insertBill(context: Context, valueBucket: relationalStore.ValuesBucket, newAmount: number) {
  const storeConfig: relationalStore.StoreConfig = {
    name: 'bills.db',
    securityLevel: relationalStore.SecurityLevel.S4,
    encrypt: true,
    customDir: 'bill',
    allowRebuild: true
  }
  let count: number = 0
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, storeConfig)
  count = store.insertSync('BILLS', valueBucket)
  let predicate = new relationalStore.RdbPredicates('PAY_ACCOUNT')
  predicate.equalTo('ID', valueBucket.PAY_ACCOUNT)
  store.updateSync({ AMOUNT: newAmount }, predicate)
  return count
}
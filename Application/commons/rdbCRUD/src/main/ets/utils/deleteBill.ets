import { relationalStore } from "@kit.ArkData"

@Concurrent
export async function deleteBill(context: Context, id: number) {
  const storeConfig: relationalStore.StoreConfig = {
    name: 'bills.db',
    securityLevel: relationalStore.SecurityLevel.S4,
    encrypt: true,
    customDir: 'bill',
    allowRebuild: true
  }
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, storeConfig)
  let predicate: relationalStore.RdbPredicates = new relationalStore.RdbPredicates('BILLS')
  predicate.equalTo('ID',id)
  let count:number = store.deleteSync(predicate)
  return count
}
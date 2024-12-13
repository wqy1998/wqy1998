import { StartupTask, common, startupManager } from "@kit.AbilityKit";
import { relationalStore } from "@kit.ArkData";
import { hilog } from "@kit.PerformanceAnalysisKit";

@Sendable
export default class QueryBills extends StartupTask {
  constructor() {
    super()
  }

  async init(context: common.AbilityStageContext): Promise<void | Object> {
    hilog.info(0x0000, 'testTag', `go to QueryBills init().`)
    let result = startupManager.getStartupTaskResult('CreateDB')
    hilog.info(0x0000, 'testTag', `go to QueryBills init().${result}`)
  }

  async queryTable(rdbStore: relationalStore.RdbStore){
    hilog.info(0x0000, 'testTag', `Go to queryTable.`)
    let time = new Date()
    let year = time.getFullYear()
    let month = time.getMonth()
    let date = time.getDate()
  }
}
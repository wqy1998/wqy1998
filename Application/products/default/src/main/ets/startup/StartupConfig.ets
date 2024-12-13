import { StartupConfig, StartupConfigEntry, StartupListener } from "@kit.AbilityKit";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { BusinessError } from "@kit.BasicServicesKit";

export default class MyStartupConfigEntry extends StartupConfigEntry {
  onConfig(): StartupConfig {
    hilog.info(0x0000, 'testTag', `onConfig`)
    let onCompletedCallback = (error: BusinessError<void>) => {
      hilog.info(0x0000, 'testTag', `onCompletedCallback`)
      if (error) {
        hilog.info(0x0000, 'testTag', `onCompletedCallback: ${error.code}, message: ${error.message}`)
      } else {
        hilog.info(0x0000, 'testTag', `onCompletedCallback: success.`)
      }
    }

    let startupListener: StartupListener = {
      'onCompleted': onCompletedCallback
    }

    let config: StartupConfig = {
      'timeoutMs': 10000,
      'startupListener': startupListener
    }

    return config
  }
}
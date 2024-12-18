import Bills, { BillsValueBucket } from "../model/Bills";
import { SegmentButton, SegmentButtonOptions } from "@ohos.arkui.advanced.SegmentButton";
import { intl } from "@kit.LocalizationKit";
import { promptAction, SymbolGlyphModifier } from "@kit.ArkUI";
import { BusinessError } from "@kit.BasicServicesKit";
import { hilog } from "@kit.PerformanceAnalysisKit";
import Classification from "../model/Classification";
import PayApp from "../model/PayApp";
import PayAccount from "../model/PayAccount";
import { relationalStore } from "@kit.ArkData";
import { taskpool } from "@kit.ArkTS";

@Component
export struct BillsPage {
  @StorageLink("billsList") billsList: Array<Bills> = new Array<Bills>()
  @StorageLink("classificationList") classificationList: Array<Classification> = new Array<Classification>()
  @StorageLink("classificationMap") classificationMap: Map<number, string> = new Map()
  @StorageLink("payAppList") payAppList: Array<PayApp> = new Array<PayApp>()
  @StorageLink("payAppMap") payAppMap: Map<number, string> = new Map()
  @StorageLink("payAccountList") payAccountList: Array<PayAccount> = new Array<PayAccount>()
  @StorageLink("payAccountMap") payAccountMap: Map<number, string[]> = new Map()
  @StorageLink("today") today: Date = new Date()
  @StorageProp("year") searchYear: number = this.today.getFullYear()
  @StorageProp("month") searchMonth: number = this.today.getMonth()
  @StorageProp("date") searchDate: number = this.today.getDate()
  @State showTime: string = new Date().getFullYear().toString()
  @State tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: '日账单' }, { text: '月账单' }],
    backgroundBlurStyle: BlurStyle.COMPONENT_ULTRA_THIN,
    selectedBackgroundColor: $r('sys.color.ohos_id_color_foreground_contrary_disable')
  })
  @State tabSelectedIndexes: number[] = [0]
  @State showBindSheet: boolean = false
  @State insertCost: string = ''
  @State insertType: number = -1
  insertClassification: number = -1
  insertPayApp: number = -1
  insertPayAccount: number = -1
  @State insertTime: Date = new Date()
  @State insertNotes: string = ''
  datefmt = new intl.DateTimeFormat('zh-CN', { dateStyle: 'long' })
  timefmt = new intl.DateTimeFormat('zh-CN', { timeStyle: 'short', hourCycle: 'h24' })
  @State dateString: string = this.datefmt.format(this.insertTime)
  @State timeString: string = this.timefmt.format(this.insertTime)
  @State isPingzhang: boolean = false
  private pathInfos: NavPathStack = new NavPathStack()
  private scroller: ListScroller = new ListScroller()
  private layoutOptions: GridLayoutOptions = {
    regularSize: [1, 1],
  }
  private numbers: string[] = ['7', '8', '9', '4', '5', '6', '1', '2', '3', '0', '.']

  @Builder
  itemEnd() {
    Row() {
      Button({ buttonStyle: ButtonStyleMode.NORMAL }) {
        Text() {
          SymbolSpan($r('sys.symbol.trash'))
        }
        .fontSize(25)
        .fontColor($r('sys.color.ohos_id_color_warning'))
        .padding(5)
      }
      .type(ButtonType.Circle)
      .margin({ right: 5 })

      Button({ buttonStyle: ButtonStyleMode.NORMAL }) {
        Text() {
          SymbolSpan($r('sys.symbol.square_and_pencil'))
        }
        .fontSize(25)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .margin(5)
      }
      .onClick(() => {
        this.scroller.closeAllSwipeActions()
      })
      .type(ButtonType.Circle)
    }
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  build() {
    Navigation(this.pathInfos) {
      List({ scroller: this.scroller, space: 5 }) {
        ForEach(this.billsList, (item: Bills) => {
          ListItem({ style: ListItemStyle.CARD }) {
            Row() {
              if (item.date < 10) {
                Text('0' + item.date.toString())
                  .fontSize(25)
                  .width(30)
                  .margin({ right: 12 })
              } else {
                Text(item.date.toString())
                  .fontSize(25)
                  .width(30)
                  .margin({ right: 12 })
              }
              Divider()
                .vertical(true)
              Column() {
                Row() {
                  if (item.type == 0) {
                    Text('-' + item.cost.toString())
                      .fontSize(20)
                      .fontColor($r('sys.color.multi_color_08'))
                  } else if (item.type == 1) {
                    Text('+' + item.cost.toString())
                      .fontSize(20)
                      .fontColor($r('sys.color.multi_color_04'))
                  } else {
                    Text(item.cost.toString())
                      .fontSize(20)
                      .fontColor($r('sys.color.multi_color_11'))
                  }
                  if (this.payAppMap.has(item.payApp)) {
                    Text('  |  ')
                      .fontColor($r('sys.color.ohos_id_color_text_hint'))
                    Text(this.payAppMap.get(item.payApp))
                      .fontSize($r('sys.float.ohos_id_text_size_body3'))
                      .fontColor($r('sys.color.ohos_id_color_text_hint'))
                  }
                }
                .layoutWeight(3)
                .padding({ left: 5 })
                .height(30)

                Row() {
                  if (item.notes.trim().length > 0 && this.classificationMap.has(item.classification)) {
                    Text(new intl.DateTimeFormat('zh-CN',
                      { timeStyle: 'short', hourCycle: 'h24' }).format(new Date(item.payTime)) + '  |  ' +
                    this.classificationMap.get(item.classification) + '  |  备注：' + item.notes)
                      .fontSize($r('sys.float.ohos_id_text_size_body3'))
                      .fontColor($r('sys.color.ohos_id_color_text_hint'))
                      .layoutWeight(1)
                      .padding({ left: 5 })
                  } else {
                    Text(new intl.DateTimeFormat('zh-CN',
                      { timeStyle: 'short', hourCycle: 'h24' }).format(new Date(item.payTime)) + '  |  ' +
                    item.classification)
                      .fontSize($r('sys.float.ohos_id_text_size_body3'))
                      .fontColor($r('sys.color.ohos_id_color_text_hint'))
                      .padding({ right: 5 })
                  }
                }
              }
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 12, bottom: 3 })
              .width('100%')
            }
            .flexShrink(1)
          }
          .swipeAction({ end: this.itemEnd })
        })
      }
      .width('90%')
      .height('100%')
      .margin({ top: 5 })
      .chainAnimation(true)
    }
    .title({
      main: `${this.searchYear}年${this.searchMonth + 1}月账单`,
      sub: `以日期排序`
    })
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
    .menus([{
      value: '新增记录',
      symbolIcon: new SymbolGlyphModifier($r('sys.symbol.plus')),
      action: () => {
        this.showBindSheet = true
      }
    }])
    .bindSheet($$this.showBindSheet, this.addBill(), {
      title: { title: '增加账单' },
      onWillAppear: () => {
        this.insertCost = ''
        this.insertType = -1
        this.insertPayApp = -1
        this.insertPayAccount = -1
        this.insertClassification = -1
        this.insertTime = new Date()
        this.dateString = this.datefmt.format(this.insertTime)
        this.timeString = this.timefmt.format(this.insertTime)
        this.insertNotes = ''
        this.isPingzhang = false
      }
    })
  }

  @Builder
  addBill() {
    Column() {
      Column() {
        Row() {
          Text('账单分类：')
          Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
            ForEach(this.classificationList, (item: Classification) => {
              Row() {
                Radio({
                  value: item.name,
                  group: "classification"
                })
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.insertClassification = item.id
                    }
                  })
                Text(item.name)
              }
              .margin({ right: 5 })
            })
          }
        }

        Row() {
          Text('收支方式：')
          Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
            ForEach(this.payAppList, (item: PayApp) => {
              Row() {
                Radio({
                  value: item.name,
                  group: "payApp"
                })
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.insertPayApp = item.id
                    }
                  })
                Text(item.name)
              }
              .margin({ right: 5 })
            })
          }
        }

        Row() {
          Text('收支账户：')
          Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
            ForEach(this.payAccountList, (item: PayAccount) => {
              Row() {
                Radio({
                  value: item.name,
                  group: "payAccount"
                })
                  .onChange((isChecked: boolean) => {
                    if (isChecked) {
                      this.insertPayAccount = item.id
                    }
                  })
                Text(item.name + '(' + item.amount + '元)')
              }
              .margin({ right: 5 })
            })
          }
        }

        Row() {
          Text('日期：')
          Button(this.dateString, { buttonStyle: ButtonStyleMode.NORMAL })
            .onClick(() => {
              DatePickerDialog.show({
                selected: this.insertTime,
                onDateAccept: (value: Date) => {
                  this.insertTime = value
                  this.dateString = this.datefmt.format(this.insertTime)
                }
              })
            })
          Text('时间：')
            .padding({ left: 10 })
          Button(this.timeString, { buttonStyle: ButtonStyleMode.NORMAL })
            .onClick(() => {
              TimePickerDialog.show({
                selected: this.insertTime,
                onAccept: (value: TimePickerResult) => {
                  this.insertTime.setHours(value.hour)
                  this.insertTime.setMinutes(value.minute)
                  this.timeString = this.timefmt.format(this.insertTime)
                },
                useMilitaryTime: true
              })
            })
        }
        .width('100%')
        .padding({ top: 5, bottom: 5 })

        Row() {
          TextInput({ placeholder: '请输入备注……', text: $$this.insertNotes })
            .maxLength(32)
            .showCounter(true)
            .cancelButton({})
            .onEditChange(() => {
              try {
                promptAction.showToast({
                  message: this.insertNotes,
                  duration: 2000
                });
              } catch (error) {
                let message = (error as BusinessError).message
                let code = (error as BusinessError).code
                hilog.error(0x0000, 'billsPage', `showToast args error code is ${code}, message is ${message}`)
              }
            })
        }
        .padding({ top: 5, bottom: 5 })
      }
      .height('60%')
      .width('90%')

      Column() {
        TextInput({ text: $$this.insertCost })
          .type(InputType.NUMBER_DECIMAL)
          .margin({ top: 5, bottom: 5 })
          .customKeyboard(this.FakeKeyboard())
          .cancelButton({})
          .fontColor(this.insertType == 0 ? $r('sys.color.multi_color_08') :
            (this.insertType == 1 ? $r('sys.color.multi_color_04') :
              (this.insertType == 2 ? $r('sys.color.multi_color_11') :
              $r('sys.color.ohos_id_color_text_primary'))))
        this.CustomKeyboardBuilder()
      }
      .height('30%')
      .width('90%')
    }
  }

  @Builder
  FakeKeyboard() {
  }

  @Builder
  CustomKeyboardBuilder() {
    Row() {
      Grid() {
        GridItem() {
          // 支付按钮
          Button() {
            Text() {
              SymbolSpan($r('sys.symbol.minus'))
            }
            .fontColor($r('sys.color.multi_color_08'))
            .fontWeight(FontWeight.Bolder)
            .fontSize(25)
          }
          .height('100%')
          .width('100%')
          .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
          .type(ButtonType.Normal)
          .borderRadius(15)
          .onClick(() => {
            this.insertType = 0
            this.isPingzhang = true
          })
        }

        GridItem() {
          // 收入按钮
          Button() {
            Text() {
              SymbolSpan($r('sys.symbol.plus'))
            }
            .fontColor($r('sys.color.multi_color_04'))
            .fontWeight(FontWeight.Bolder)
            .fontSize(25)
          }
          .height('100%')
          .width('100%')
          .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
          .type(ButtonType.Normal)
          .borderRadius(15)
          .onClick(() => {
            this.insertType = 1
            this.isPingzhang = true
          })
        }

        GridItem() {
          Button('平账')
            .height('100%')
            .width('100%')
            .fontColor($r('sys.color.multi_color_11'))
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .fontWeight(FontWeight.Bold)
            .labelStyle({ maxLines: 2, minFontSize: 15, maxFontSize: 20 })
            .type(ButtonType.Normal)
            .borderRadius(15)
            .enabled(this.isPingzhang)
            .onClick(() => {
              this.insertType = 2
            })
        }
      }
      .rowsTemplate('2fr 2fr 1fr')
      .rowsGap(8)
      .layoutWeight(1)

      Grid(this.scroller, this.layoutOptions) {
        ForEach(this.numbers, (item: string) => {
          GridItem() {
            Button(item, { type: ButtonType.Circle, buttonStyle: ButtonStyleMode.NORMAL })
              .type(ButtonType.Normal)
              .borderRadius(15)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .height('100%')
              .width('100%')
              .onClick(() => {
                if (this.insertCost.startsWith('0') && this.insertCost.length == 1) {
                  if (item != '0' && item != '.') {
                    this.insertCost = item
                  } else if (item == '.') {
                    this.insertCost = this.insertCost + '.'
                  }
                } else {
                  if (this.insertCost.includes('.')) {
                    if (item != '.') {
                      let decimal: string = this.insertCost.split('.')[1]
                      if (decimal.length < 2) {
                        this.insertCost = this.insertCost + item
                      }
                    }
                  } else if (this.insertCost.length == 0 && item == '.') {
                    this.insertCost = '0.'
                  } else if (this.insertCost.length < 9 && item != '.') {
                    this.insertCost = this.insertCost + item
                  } else if (this.insertCost.length <= 9 && item == '.') {
                    this.insertCost = this.insertCost + item
                  }
                }
              })
          }
        }, (item: string) => item)
        // 删除按钮
        GridItem() {
          Button({ type: ButtonType.Circle, buttonStyle: ButtonStyleMode.TEXTUAL }) {
            Text() {
              SymbolSpan($r('sys.symbol.delete_left_fill'))
            }
            .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
            .fontSize(25)
            .fontWeight(FontWeight.Bold)
          }
          .type(ButtonType.Normal)
          .borderRadius(15)
          .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
          .height('100%')
          .width('100%')
          .onClick(() => {
            this.insertCost = this.insertCost.substring(0, this.insertCost.length - 1)
          })
        }
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap(5)
      .rowsGap(8)
      .layoutWeight(3)
      .margin({ left: 5 })

      Grid() {
        GridItem() {
          Button('确定')
            .height('100%')
            .width('100%')
            .fontWeight(FontWeight.Bold)
            .labelStyle({ maxLines: 2, minFontSize: 25, maxFontSize: 30 })
            .type(ButtonType.Normal)
            .borderRadius(15)
            .onClick(async () => {
              if (this.insertCost.length <= 0) {
                promptAction.showToast({
                  message: '请输入金额',
                  duration: 2000
                })
              } else if (this.insertType < 0) {
                promptAction.showToast({
                  message: '请选择收支类型',
                  duration: 2000
                })
              } else {
                let bill: Bills =
                  new Bills(0, parseFloat(this.insertCost), this.insertType, this.insertPayApp, this.insertPayAccount,
                    this.insertClassification, new Date().toString(), this.insertTime.toString(),
                    this.insertTime.getFullYear(), this.insertTime.getMonth(), this.insertTime.getDate(),
                    this.insertTime.getDay(), this.insertNotes)
                let valuesBucket: BillsValueBucket = {
                  COST: bill.cost,
                  TYPE: bill.type,
                  PAY_APP: bill.payApp,
                  PAY_ACCOUNT: bill.payAccount,
                  CLASSIFICATION: bill.classification,
                  CREATE_TIME: bill.createTime,
                  PAY_TIME: bill.payTime,
                  YEAR: bill.year,
                  MONTH: bill.month,
                  DATE: bill.date,
                  DAY: bill.day,
                  NOTES: bill.notes
                }
                let count = await taskpool.execute(insertBill, getContext(this), valuesBucket)
                this.billsList =
                  await taskpool.execute(queryBill, getContext(this), this.searchYear, this.searchMonth) as Array<Bills>
                promptAction.showToast({
                  message: (count as number) == -1 ? '增加账单项失败' : '增加账单项成功',
                  duration: 2000
                })
                this.showBindSheet = false
              }
            })
        }
      }
      .margin({ left: 5 })
      .layoutWeight(1)
    }
  }
}

@Concurrent
async function insertBill(context: Context, valueBucket: BillsValueBucket) {
  const storeConfig: relationalStore.StoreConfig = {
    name: 'bills.db',
    securityLevel: relationalStore.SecurityLevel.S4,
    encrypt: true,
    customDir: 'bill',
    allowRebuild: true
  }
  let count: number = 0
  let store: relationalStore.RdbStore = await relationalStore.getRdbStore(context, storeConfig)
  hilog.info(0x0000, 'billsPage', 'get insert rdb success')
  count = store.insertSync('BILLS', valueBucket)
  return count
}

@Concurrent
async function queryBill(context: Context, queryYear: number, queryMonth: number) {
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
      billsResultSet.getString(billsResultSet.getColumnIndex("NOTES"))));
    hilog.info(0x0000, 'testTag', `time = ${billsResultSet.getDouble(billsResultSet.getColumnIndex("COST"))}`);
  }
  return billsList
}

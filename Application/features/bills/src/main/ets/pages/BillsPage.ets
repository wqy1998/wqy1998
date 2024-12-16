import Bills from "../model/Bills";
import { SegmentButton, SegmentButtonOptions } from "@ohos.arkui.advanced.SegmentButton";
import { intl } from "@kit.LocalizationKit";
import { promptAction, SymbolGlyphModifier } from "@kit.ArkUI";
import { BusinessError } from "@kit.BasicServicesKit";
import { hilog } from "@kit.PerformanceAnalysisKit";
import Classification from "../model/Classification";
import PayApp from "../model/PayApp";
import PayAccount from "../model/PayAccount";
import { relationalStore } from "@kit.ArkData";

@Component
export struct BillsPage {
  @StorageLink("billsList") billsList: Array<Bills> = new Array<Bills>()
  @StorageLink("classificationList") classificationList: Array<Classification> = new Array<Classification>()
  @StorageLink("payAppList") payAppList: Array<PayApp> = new Array<PayApp>()
  @StorageLink("payAccountList") payAccountList: Array<PayAccount> = new Array<PayAccount>()
  @StorageLink("today") today: Date = new Date()
  @StorageProp("year") searchYear: number = this.today.getFullYear()
  @StorageProp("month") searchMonth: number = this.today.getMonth()
  @StorageProp("date") searchDate: number = this.today.getDate()
  @StorageProp("billsRdb") billsRdb: relationalStore.RdbStore | undefined = undefined
  @State showTime: string = new Date().getFullYear().toString()
  @State tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: '日账单' }, { text: '月账单' }],
    backgroundBlurStyle: BlurStyle.COMPONENT_ULTRA_THIN,
    selectedBackgroundColor: $r('sys.color.ohos_id_color_foreground_contrary_disable')
  })
  @State tabSelectedIndexes: number[] = [0]
  @State showBindSheet: boolean = false
  @State amount: string = ''
  @State insertType: number = -1
  insertClassification: string = ''
  insertPayApp: string = ''
  insertPayAccount: string = ''
  insertTime: Date = new Date()
  @State insertNotes: string = ''
  datefmt = new intl.DateTimeFormat('zh-CN', { dateStyle: 'long' })
  timefmt = new intl.DateTimeFormat('zh-CN', { timeStyle: 'short', hourCycle: 'h24' })
  @State dateString: string = this.datefmt.format(this.insertTime)
  @State timeString: string = this.timefmt.format(this.insertTime)
  @State isPingzhang: boolean = false
  private pathInfos: NavPathStack = new NavPathStack()
  private scroller: Scroller = new Scroller()
  private layoutOptions: GridLayoutOptions = {
    regularSize: [1, 1],
  }
  private numbers: string[] = ['7', '8', '9', '4', '5', '6', '1', '2', '3', '0', '.']

  build() {
    Navigation(this.pathInfos) {
      SegmentButton({
        options: this.tabOptions,
        selectedIndexes: $tabSelectedIndexes
      })
      List() {
        ListItemGroup({ style: ListItemGroupStyle.CARD }) {
          ForEach(this.billsList, (item: Bills, index: number) => {
            ListItem({ style: ListItemStyle.CARD }) {
              Row() {
                Text('支')
                  .fontSize(30)
                  .fontColor($r('sys.color.multi_color_08'))
                Column() {
                  Text(item.cost.toString())
                  Text(new intl.DateTimeFormat('zh-CN',
                    { dateStyle: 'long', timeStyle: 'short', hourCycle: 'h24' }).format(item.payTime))
                    .fontSize($r('sys.float.ohos_id_text_size_body3'))
                    .fontColor($r('sys.color.ohos_id_color_text_hint'))
                }

                Text(item.notes)
              }
            }
          })
        }
      }
      .chainAnimation(true)
    }
    .title({
      main: '账单',
      sub: `${this.searchYear}年${this.searchMonth + 1}月${this.searchDate}日`
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
      onDisappear: () => {
        this.amount = ''
        this.insertNotes = ''
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
                      this.insertClassification = item.name
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
                      this.insertClassification = item.name
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
                      this.insertPayAccount = item.name + '(' + item.amount + '元)'
                    }
                  })
                Text(item.name)
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
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Top)
      }
      .height('60%')
      .width('90%')

      Column() {
        TextInput({ text: $$this.amount })
          .type(InputType.NUMBER_DECIMAL)
          .margin({ top: 5, bottom: 5 })
          .customKeyboard(this.FakeKeyboard())
          .cancelButton({})
          .fontColor(this.insertType == 0 ? $r('sys.color.multi_color_08') :
            (this.insertType == 1 ? $r('sys.color.multi_color_04') :
              (this.insertType == 2 ? $r('sys.color.multi_color_11') :
              $r('sys.color.ohos_id_color_text_primary_dark'))))
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
      // .columnsTemplate('1fr')
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
                if (this.amount.startsWith('0') && this.amount.length == 1) {
                  if (item != '0' && item != '.') {
                    this.amount = item
                  } else if (item == '.') {
                    this.amount = this.amount + '.'
                  }
                } else {
                  if (this.amount.includes('.')) {
                    if (item != '.') {
                      let decimal: string = this.amount.split('.')[1]
                      if (decimal.length < 2) {
                        this.amount = this.amount + item
                      }
                    }
                  } else if (this.amount.length == 0 && item == '.') {
                    this.amount = '0.'
                  } else if (this.amount.length < 9 && item != '.') {
                    this.amount = this.amount + item
                  } else if (this.amount.length <= 9 && item == '.') {
                    this.amount = this.amount + item
                  }
                }
                try {
                  promptAction.showToast({
                    message: this.amount,
                    duration: 2000
                  })
                } catch (error) {
                  let message = (error as BusinessError).message
                  let code = (error as BusinessError).code
                  hilog.error(0x0000, 'billsPage', `showToast args error code is ${code}, message is ${message}`)
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
            this.amount = this.amount.substring(0, this.amount.length - 1)
            try {
              promptAction.showToast({
                message: this.amount,
                duration: 2000
              });
            } catch (error) {
              let message = (error as BusinessError).message
              let code = (error as BusinessError).code
              hilog.error(0x0000, 'billsPage', `showToast args error code is ${code}, message is ${message}`)
            }
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
            .onClick(()=>{
              let insertBill: Bills = new Bills(0,parseFloat(this.amount),this.insertType,this.insertPayApp,this.insertPayAccount,this.insertClassification,new Date(),this.insertTime,this.insertTime.getFullYear(),this.insertTime.getMonth(),this.insertTime.getDate(),this.insertTime.getDay(),this.insertNotes)
              let valuesBucket: relationalStore.ValuesBucket = {
                COST: insertBill.cost,
                TYPE: insertBill.type,
                PAY_APP: insertBill.payApp,
                PAY_ACCOUNT: insertBill.payAccount,
                CLASSIFICATION: insertBill.classification,
                CREATE_TIME: insertBill.createTime.toDateString(),
                PAY_TIME: insertBill.payTime.toDateString(),
                YEAR: insertBill.year,
                MONTH: insertBill.month,
                DATE: insertBill.date,
                DAY: insertBill.day,
                NOTES: insertBill.notes
              }
              // this.billsRdb?.insertSync('BILLS',valuesBucket)
              this.showBindSheet = false
            })
        }
      }
      .margin({ left: 5 })
      .layoutWeight(1)
    }
  }
}

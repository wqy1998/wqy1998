import Bills from "../model/Bills";
import { SegmentButton, SegmentButtonOptions } from "@ohos.arkui.advanced.SegmentButton";
import { intl } from "@kit.LocalizationKit";
import { SymbolGlyphModifier } from "@kit.ArkUI";

@Component
export struct BillsPage {
  @StorageLink("billsList") billsList: Array<Bills> = new Array<Bills>()
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
  @State amount: string = ''
  private pathInfos: NavPathStack = new NavPathStack()
  private scroller: Scroller = new Scroller()
  private layoutOptions: GridLayoutOptions = {
    regularSize: [1, 1],
  }
  private numbers: string[] = ['7', '8', '9', '4', '5', '6', '1', '2', '3', '0', '.']
  private textInputController: TextInputController = new TextInputController()

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
      title: { title: '增加账单' }
    })
  }

  @Builder
  addBill() {
    Column() {
      Column() {
        Text('123456')
      }
      .height('60%')

      Column() {
        TextInput({ text: $$this.amount, controller: this.textInputController })
          .type(InputType.NUMBER_DECIMAL)
          .margin({ top: 5, bottom: 5 })
          .customKeyboard(this.FakeKeyboard())
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
          Button('收入')
            .height('100%')
            .fontColor($r('sys.color.multi_color_04'))
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .fontWeight(FontWeight.Bold)
            .labelStyle({ maxLines: 2, minFontSize: 25, maxFontSize: 30 })
        }

        GridItem() {
          Button('支出')
            .height('100%')
            .fontColor($r('sys.color.multi_color_08'))
            .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
            .fontWeight(FontWeight.Bold)
            .labelStyle({ maxLines: 2, minFontSize: 25, maxFontSize: 30 })
        }
      }
      .columnsTemplate('1fr')
      .rowsTemplate('1fr 1fr')
      .rowsGap(5)
      .layoutWeight(1)

      Grid(this.scroller, this.layoutOptions) {
        ForEach(this.numbers, (item: string) => {
          GridItem() {
            Button(item, { type: ButtonType.Circle, buttonStyle: ButtonStyleMode.NORMAL })
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .height('100%')
              .onClick(() => {
                if (this.amount.includes('.')) {
                  let decimal: string = this.amount.split('.')[1]
                  if (decimal.length < 2) {
                    this.amount = this.amount + item
                  }
                } else {
                  this.amount = this.amount + item
                }
              })
          }
        }, (item: string) => item)
        GridItem() {
          Button({ type: ButtonType.Circle, buttonStyle: ButtonStyleMode.TEXTUAL }) {
            Text() {
              SymbolSpan($r('sys.symbol.delete_left_fill'))
            }
            .fontColor($r('sys.color.ohos_id_color_text_primary_activated'))
            .fontSize(25)
            .fontWeight(FontWeight.Bold)
          }
          .backgroundColor($r('sys.color.ohos_id_color_card_bg'))
          .height('100%')
          .width('100%')
        }
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr 1fr')
      .columnsGap(5)
      .rowsGap(8)
      .layoutWeight(3)

      Grid() {
        GridItem() {
          Button('确定')
            .height('100%')
            .fontWeight(FontWeight.Bold)
            .labelStyle({ maxLines: 2, minFontSize: 25, maxFontSize: 30 })
        }
      }
      .columnsGap(5)
      .layoutWeight(1)
    }
  }
}

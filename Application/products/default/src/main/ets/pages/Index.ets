import { router } from '@kit.ArkUI';
import { SymbolGlyphModifier } from '@kit.ArkUI';
import { BillsPage } from '@livingbills/bills';
import { MinePage } from '@livingbills/mine';

@Entry
@Component
struct Index {
  @Builder
  homeButton(title: Resource, description: Resource, routeName: string) {
    Button({ type: ButtonType.Normal, stateEffect: true }) {
      Column() {
        Text(title)
          .fontSize($r('app.float.body_font_size'))
          .margin({ bottom: 5, top: 5 })
          .fontWeight(FontWeight.Bold)
        Text(description)
          .textAlign(TextAlign.Center)
          .fontSize($r('app.float.body_font_size'))
          .margin({ bottom: 5 })
      }
      .width('100%')
    }
    .borderRadius(4)
    .margin(10)
    .borderWidth(1)
    .borderColor($r('app.color.body_color'))
    .fontColor($r('app.color.body_color'))
    .backgroundColor($r('app.color.start_window_background'))
    .width('96%')
    .onClick(async () => {
      let params: Record<string, Resource> = { 'title': title }
      router.pushUrl({ url: routeName, params });
    })
  }

  build() {
    Tabs({ barPosition: BarPosition.End }) {
      TabContent() {
        BillsPage()
      }
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
      .tabBar(new BottomTabBarStyle({
        normal: new SymbolGlyphModifier($r('sys.symbol.yuansign_coupon_fill'))
      }, '账单'))
      .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP])

      TabContent() {
        MinePage()
      }
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
      .tabBar(new BottomTabBarStyle({
        normal: new SymbolGlyphModifier($r('sys.symbol.person_crop_circle_fill_1'))
      }, '我的'))
      .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP])
    }
    .barBackgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THIN)
    .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP])
  }
}
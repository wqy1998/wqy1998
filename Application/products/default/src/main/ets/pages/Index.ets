import { SymbolGlyphModifier } from '@kit.ArkUI';
import { BillsPage } from '@livingbills/bills';
import { MinePage } from '@livingbills/mine';

@Entry
@Component
struct Index {
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
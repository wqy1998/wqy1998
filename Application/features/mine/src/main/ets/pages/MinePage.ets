import { FunctionalButton, functionalButtonComponentManager } from "@kit.ScenarioFusionKit";
import { hilog } from "@kit.PerformanceAnalysisKit";
import PayAccount from "../model/PayAccount";
import { loginComponentManager, LoginWithHuaweiIDButton } from "@kit.AccountKit";
import { BusinessError } from "@kit.BasicServicesKit";

@Component
export struct MinePage {
  @State isLogin: boolean = false
  @State userName: string = '登录 / 注册';
  @State url: ResourceStr = $r('app.media.person_crop_circle_fill_1')
  @StorageLink("payAccountList") payAccountList: Array<PayAccount> = new Array<PayAccount>()
  @StorageLink("payAccountMap") payAccountMap: Map<number, string[]> = new Map()
  // 构造LoginWithHuaweiIDButton组件的控制器
  controller: loginComponentManager.LoginWithHuaweiIDButtonController =
    new loginComponentManager.LoginWithHuaweiIDButtonController()
      .onClickLoginWithHuaweiIDButton((error: BusinessError, response: loginComponentManager.HuaweiIDCredential) => {
        if (error) {
          hilog.error(0x0000, 'testTag',
            `Failed to onClickLoginWithHuaweiIDButton. Code: ${error.code}, message: ${error.message}`);
          return;
        }

        if (response) {
          hilog.info(0x0000, 'testTag', 'Succeeded in getting response.');
          const authCode = response.authorizationCode;
          const openID = response.openID;
          const unionID = response.unionID;
          const idToken = response.idToken;
          // 开发者处理authCode、openID、unionID、idToken
        }
      });

  build() {
    Navigation() {
      List({ space: 10 }) {
        ListItemGroup({ style: ListItemGroupStyle.CARD }) {
          ListItem({ style: ListItemStyle.CARD }) {
            Row() {
              this.avatar()
              Text(this.userName)
            }
            .justifyContent(FlexAlign.Start)
            .width('100%')
          }
          ListItem() {
            this.login()
          }
        }

        ListItemGroup({ style: ListItemGroupStyle.CARD, header: this.header('资产') }) {
          ForEach(this.payAccountList, (item: PayAccount) => {
            ListItem({ style: ListItemStyle.CARD }) {
              Row() {
                Text(item.name + '：')
                  .fontSize(16)
                Text(item.amount.toString() + '元')
                  .fontSize(16)
                Blank()
                Button({ buttonStyle: ButtonStyleMode.TEXTUAL }) {
                  Text() {
                    SymbolSpan($r('sys.symbol.chevron_right'))
                  }
                  .fontSize(16)
                }
                .stateEffect(false)
              }
              .width('100%')
            }
          })
        }
        .divider({ strokeWidth: 1 })
      }
      .width('100%')
      .height('100%')
    }
    .title({
      main: '我的',
      sub: ''
    })
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
  }

  @Builder
  login() {
    Column() {
      Column() {
        Column() {
          LoginWithHuaweiIDButton({
            params: {
              // LoginWithHuaweiIDButton支持的样式
              style: loginComponentManager.Style.BUTTON_RED,
              // 账号登录按钮在登录过程中展示加载态
              extraStyle: {
                buttonStyle: new loginComponentManager.ButtonStyle().loadingStyle({
                  show: true
                })
              },
              // LoginWithHuaweiIDButton的边框圆角半径
              borderRadius: 24,
              // LoginWithHuaweiIDButton支持的登录类型
              loginType: loginComponentManager.LoginType.ID,
              // LoginWithHuaweiIDButton支持按钮的样式跟随系统深浅色模式切换
              supportDarkMode: true,
              // verifyPhoneNumber：如果华为账号用户在过去90天内未进行短信验证，是否拉起Account Kit提供的短信验证码页面
              verifyPhoneNumber: true
            },
            controller: this.controller
          })
        }
        .height(40)
      }.width('100%')
    }
    .justifyContent(FlexAlign.Center)
    // .constraintSize({ minHeight: '100%' })
    .margin({
      left: 16,
      right: 16
    })
  }

  @Builder
  header(name: string) {
    Row() {
      Text(name)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
      Blank()
      Button({ buttonStyle: ButtonStyleMode.NORMAL,type:ButtonType.Circle}) {
        Text() {
          SymbolSpan($r('sys.symbol.plus'))
        }
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontSize(16)
        .padding(5)
      }
    }
    .width('100%')
    .padding({ left: 8, right: 8, top: 5 })
  }

  @Builder
  avatar() {
    // 声明FunctionalButton
    FunctionalButton({
      params: {
        // OpenType.CHOOSE_AVATAR表示Button为选择头像类型
        openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
        label: '',
        // 调整Button样式
        styleOption: {
          styleConfig: new functionalButtonComponentManager.ButtonConfig()
            .type(ButtonType.Circle)
            .stateEffect(false)
            .backgroundImage(this.url)
            .backgroundImageSize(ImageSize.Cover)
            .width(40)
            .height(40)
            .backgroundColor($r('sys.color.comp_background_list_card'))
            .margin({ right: 10 })
        }
      },
      // OpenType为“CHOOSE_AVATAR”时，回调必须选择“onChooseAvatar”
      controller: new functionalButtonComponentManager.FunctionalButtonController().onChooseAvatar((err, data) => {
        if (err) {
          // 错误日志处理
          hilog.error(0x0000, "testTag", "error： %{public}d %{public}s", err.code, err.message);
          return;
        }
        // 成功日志处理
        hilog.info(0x0000, "testTag", "succeeded in choosing avatar");
        this.url = data.avatarUri!;
      })
    })
  }
}
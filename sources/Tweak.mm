#import <UIKit/UIKit.h>
#import "../esp/drawing_view/esp.h"

// ============================================================================
// PassThroughWindow
// ----------------------------------------------------------------------------
// ФИКС: оверлей-окно не должно съедать тачи мимо интерактивных элементов.
//
// БЫЛО: окно -> vc.view (обычный UIView на весь экран) -> ESP_View
// ESP_View.hitTest корректно возвращал nil вне меню, но дефолтный hitTest
// vc.view, не найдя обработчика среди сабвью, возвращал САМ СЕБЯ (return self).
// В итоге все тачи вне меню доставались vc.view, а окно игры ничего
// не получало — игра «не тыкалась», при этом меню работало.
//
// СТАЛО:
//   1) espView назначается корневым view контроллера (лишний обычный
//      контейнер vc.view убран — ему больше нечем съедать тачи);
//   2) само окно не возвращает себя из hitTest — если ниже по иерархии
//      никто не обработал тач, он уходит в окно ИГРЫ.
// ============================================================================
@interface PassThroughWindow : UIWindow
@end

@implementation PassThroughWindow

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hit = [super hitTest:point withEvent:event];
    // Если бы тач достался самому окну — пропускаем его в окно игры ниже.
    return (hit == self) ? nil : hit;
}

@end

static UIWindow *overlayWindow = nil;
static ESP_View *espView = nil;

static void initOverlay(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (overlayWindow) return;

        CGRect bounds = [UIScreen mainScreen].bounds;
        overlayWindow = [[PassThroughWindow alloc] initWithFrame:bounds];
        overlayWindow.windowLevel = UIWindowLevelStatusBar + 1000.0;
        overlayWindow.backgroundColor = [UIColor clearColor];
        overlayWindow.userInteractionEnabled = YES;

        espView = [[ESP_View alloc] initWithFrame:bounds];
        espView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        espView.userInteractionEnabled = YES;

        // ВАЖНО: espView ставим корневым view вместо промежуточного
        // UIView-контейнера. ESP_View.hitTest уже умеет возвращать nil
        // вне меню — теперь этому ничто не мешает.
        UIViewController *vc = [[UIViewController alloc] init];
        vc.view = espView;
        overlayWindow.rootViewController = vc;

        [overlayWindow setHidden:NO];
        // ВАЖНО: НЕ вызываем makeKeyAndVisible.
        // Окно и так получает тачи по hit-тесту, а key window остаётся
        // у игры (иначе в Unity могут сломаться клавиатура/чат/иной ввод).
    });
}

__attribute__((constructor))
static void entry(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplication *app = [UIApplication sharedApplication];
        if (app && (app.keyWindow || app.windows.count > 0)) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                initOverlay();
            });
        } else {
            [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification
                                                             object:nil
                                                              queue:[NSOperationQueue mainQueue]
                                                         usingBlock:^(NSNotification * _Nonnull note) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    initOverlay();
                });
            }];
        }
    });
}

import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    let remaining = Set(URLContexts.filter { !AppDelegate.handleKBZPayURL($0.url) })
    if !remaining.isEmpty {
      super.scene(scene, openURLContexts: remaining)
    }
  }
}

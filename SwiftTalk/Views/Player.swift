import SwiftUI
import AVKit

final class PlayerCoordinator<Overlay: View> {
  var observer: NSKeyValueObservation?
  var hostingViewController: UIHostingController<Overlay>?
}

struct Player<Overlay: View>: UIViewControllerRepresentable {
  let url: URL
  let overlay: Overlay?

  @Binding var isPlaying: Bool

  func makeCoordinator() -> PlayerCoordinator<Overlay?> {
    PlayerCoordinator()
  }

  func makeUIViewController(context: Context) -> AVPlayerViewController {
    let player = AVPlayer(url: url)

    context.coordinator.observer = player.observe(\.rate, options: [.new]) { _, change in
      self.isPlaying = (change.newValue ?? 0) > 0
    }

    let playerVC = AVPlayerViewController()
    playerVC.player = player

    let hostingVC = UIHostingController(rootView: overlay)
    playerVC.addChild(hostingVC)
    playerVC.contentOverlayView?.addSubview(hostingVC.view)
    hostingVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    hostingVC.didMove(toParent: playerVC)
    context.coordinator.hostingViewController = hostingVC

    return playerVC
  }

  func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<Player>) {
    guard let hostingVC = context.coordinator.hostingViewController else { return }
    hostingVC.rootView = overlay
    hostingVC.view.isHidden = overlay == nil
  }
}

struct Player_Previews: PreviewProvider {
    static var previews: some View {
      let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv.example_fmp4/master.m3u8")!
      Player(url: url, overlay: Text("over the lay"), isPlaying: .constant(false))
    }
}

import SwiftUI
import AVKit

final class PlayerCoordinator<Overlay: View> {
  var observer: NSKeyValueObservation?
  var hostingViewController: UIHostingController<Overlay>?
  var timeObserver: Any?
  var lastObservedPosition: TimeInterval?
}

struct Player<Overlay: View>: UIViewControllerRepresentable {
  let url: URL
  let overlay: Overlay?

  @Binding var isPlaying: Bool
  @Binding var playPosition: TimeInterval

  func makeCoordinator() -> PlayerCoordinator<Overlay?> {
    PlayerCoordinator()
  }

  func makeUIViewController(context: Context) -> AVPlayerViewController {
    let player = AVPlayer(url: url)

    context.coordinator.observer = player.observe(\.rate, options: [.new]) { _, change in
      self.isPlaying = (change.newValue ?? 0) > 0
    }

    context.coordinator.timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { time in
      let position = time.seconds
      self.playPosition = position
      context.coordinator.lastObservedPosition = position
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
    if context.coordinator.lastObservedPosition != playPosition {
      uiViewController.player?.seek(to: CMTime(seconds: playPosition, preferredTimescale: 1))
    }

    guard let hostingVC = context.coordinator.hostingViewController else { return }
    hostingVC.rootView = overlay
    hostingVC.view.isHidden = overlay == nil
  }

  static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: PlayerCoordinator<Overlay?>) {
    guard let observer = coordinator.timeObserver else { return }
    uiViewController.player?.removeTimeObserver(observer)
  }
}

struct Player_Previews: PreviewProvider {
    static var previews: some View {
      let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv.example_fmp4/master.m3u8")!
      Player(
        url: url,
        overlay: Text("over the lay"),
        isPlaying: .constant(false),
        playPosition: .constant(0)
      )
    }
}

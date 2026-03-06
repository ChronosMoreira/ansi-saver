import AppKit
import QuartzCore

enum TransitionMode: Int {
    case scrollUp = 0
    case scrollDown = 1
    case crossfade = 2
}

class Animator {

    private weak var containerLayer: CALayer?
    private var imageLayerA: CALayer?
    private var imageLayerB: CALayer?
    private var useLayerA = true
    private var animating = false

    var onAnimationComplete: (() -> Void)?

    init(containerLayer: CALayer) {
        self.containerLayer = containerLayer
        containerLayer.masksToBounds = true
    }

    var isAnimating: Bool { animating }

    func display(image: NSImage, transition: TransitionMode, speed: Double, viewSize: NSSize) {
        guard let container = containerLayer else { return }

        let imageSize = image.size
        let scaleX = viewSize.width / imageSize.width
        let fitWidth = imageSize.width * scaleX
        let fitHeight = imageSize.height * scaleX

        let newLayer = CALayer()
        newLayer.contents = image
        newLayer.contentsGravity = .top
        newLayer.frame = CGRect(
            x: (viewSize.width - fitWidth) / 2,
            y: 0,
            width: fitWidth,
            height: fitHeight
        )

        switch transition {
        case .scrollUp:
            animateScroll(newLayer: newLayer, container: container,
                          fitHeight: fitHeight, viewHeight: viewSize.height,
                          speed: speed, direction: .up)
        case .scrollDown:
            animateScroll(newLayer: newLayer, container: container,
                          fitHeight: fitHeight, viewHeight: viewSize.height,
                          speed: speed, direction: .down)
        case .crossfade:
            animateCrossfade(newLayer: newLayer, container: container, speed: speed)
        }
    }

    private enum ScrollDirection { case up, down }

    private func animateScroll(newLayer: CALayer, container: CALayer,
                                fitHeight: CGFloat, viewHeight: CGFloat,
                                speed: Double, direction: ScrollDirection) {
        animating = true

        let oldLayer = useLayerA ? imageLayerA : imageLayerB

        if direction == .up {
            newLayer.anchorPoint = CGPoint(x: 0.5, y: 0)
            newLayer.position = CGPoint(x: newLayer.frame.midX, y: 0)
        } else {
            newLayer.anchorPoint = CGPoint(x: 0.5, y: 1)
            newLayer.position = CGPoint(x: newLayer.frame.midX, y: viewHeight)
        }

        container.addSublayer(newLayer)

        let totalScroll = max(fitHeight - viewHeight, 0)
        guard totalScroll > 0 else {
            oldLayer?.removeFromSuperlayer()
            storeLayer(newLayer)
            animating = false
            onAnimationComplete?()
            return
        }

        let duration = totalScroll / CGFloat(max(speed, 1))

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.commit()

        let startDelay: CFTimeInterval = 2.0
        let endPause: CFTimeInterval = 2.0

        let animation = CABasicAnimation(keyPath: "position.y")
        if direction == .up {
            animation.fromValue = newLayer.position.y
            animation.toValue = newLayer.position.y + totalScroll
        } else {
            animation.fromValue = newLayer.position.y
            animation.toValue = newLayer.position.y - totalScroll
        }
        animation.duration = CFTimeInterval(duration)
        animation.beginTime = CACurrentMediaTime() + startDelay
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false

        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + endPause) {
                oldLayer?.removeFromSuperlayer()
                self?.animating = false
                self?.onAnimationComplete?()
            }
        }
        newLayer.add(animation, forKey: "scroll")
        CATransaction.commit()

        oldLayer?.removeFromSuperlayer()
        storeLayer(newLayer)
    }

    private func animateCrossfade(newLayer: CALayer, container: CALayer, speed: Double) {
        animating = true

        let oldLayer = useLayerA ? imageLayerA : imageLayerB
        newLayer.opacity = 0

        container.addSublayer(newLayer)

        let fadeDuration: CFTimeInterval = 2.0
        let displayDuration = max(5.0, 20.0 - speed / 10.0)

        let fadeIn = CABasicAnimation(keyPath: "opacity")
        fadeIn.fromValue = 0
        fadeIn.toValue = 1
        fadeIn.duration = fadeDuration

        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            oldLayer?.removeFromSuperlayer()

            DispatchQueue.main.asyncAfter(deadline: .now() + displayDuration) {
                self?.animating = false
                self?.onAnimationComplete?()
            }
        }
        newLayer.add(fadeIn, forKey: "fadeIn")
        newLayer.opacity = 1
        CATransaction.commit()

        storeLayer(newLayer)
    }

    private func storeLayer(_ layer: CALayer) {
        if useLayerA {
            imageLayerA = layer
        } else {
            imageLayerB = layer
        }
        useLayerA.toggle()
    }

    func stopAnimations() {
        imageLayerA?.removeAllAnimations()
        imageLayerB?.removeAllAnimations()
        imageLayerA?.removeFromSuperlayer()
        imageLayerB?.removeFromSuperlayer()
        imageLayerA = nil
        imageLayerB = nil
        animating = false
    }

    static func scrollDuration(imageHeight: CGFloat, viewHeight: CGFloat, speed: Double) -> CFTimeInterval {
        let totalScroll = max(imageHeight - viewHeight, 0)
        return CFTimeInterval(totalScroll / CGFloat(max(speed, 1)))
    }
}

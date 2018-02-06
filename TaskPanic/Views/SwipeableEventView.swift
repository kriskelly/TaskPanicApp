//
//  SwipeableEventView.swift
//  TaskPanic
//
//  Created by Kris Kelly on 5/16/16.
//  Copyright © 2016 Kris Kelly. All rights reserved.
//

import UIKit
import CalendarLib

protocol EventViewDelegate: class {
    func eventDidSwipe(event: DisplayableEvent)
    func eventDidStartSwiping(event: DisplayableEvent)
    func eventWillRelease(event: DisplayableEvent)
    func eventDidCompleteRelease(event: DisplayableEvent)
    func eventDidChangeState(event: DisplayableEvent)
    func eventSwipeActivatedAction(event: DisplayableEvent, action: EventActionType)
}

enum EventActionType: Int {
    case Accepted = 0
    case Rejected = 1
}

public enum SwipeCellType: Int {
    case SwipeThrough = 0 // swipes with finger and animates through
    case SpringRelease // resists pulling and bounces back
    case SlidingDoor // swipe to a stopping position where underlying buttons can be revealed
}

public enum SwipeCellRevealDirection {
    case None
    case Both
    case Right
    case Left
}

public enum SwipeCellState {
    case Normal
    case PastThresholdLeft
    case PastThresholdRight
}

class SwipeableEventView: UIView, UIGestureRecognizerDelegate {

    var event: DisplayableEvent!

    weak var delegate: EventViewDelegate?

    var contentView: UIView!
    var backgroundView: UIView!
    var eventContentView: MGCStandardEventView!

    var title: String? {
        get {
            return eventContentView.title
        }
        set(title) {
            eventContentView.title = title
        }
    }
    var color: UIColor? {
        get {
            return eventContentView.color
        }
        set(color) {
            eventContentView.color = color
        }
    }
    var font: UIFont? {
        get {
            return eventContentView.font
        }
        set(font) {
            eventContentView.font = font
        }
    }
    var style: MGCStandardEventViewStyle? {
        get {
            return eventContentView.style
        }
        set(style) {
            eventContentView.style = style!
        }
    }

    // MARK: - Properties from BWSwipeCell

    // The interaction type for this table cell
    var type:SwipeCellType = .SpringRelease

    // The allowable swipe direction(s)
    var revealDirection: SwipeCellRevealDirection = .Both

    // The current state of the cell (either normal or past a threshold)
    var state: SwipeCellState = .Normal

    // The point at which pan elasticity starts, and `state` changes. Defaults to the height of the `UITableViewCell` (i.e. when it form a perfect square)
    lazy var threshold: CGFloat = {
        return self.frame.height
    }()

    // A number between 0 and 1 to indicate progress toward reaching threshold in the current swiping direction. Useful for changing UI gradually as the user swipes.
    var progress: CGFloat {
        get {
            let progress = abs(self.contentView.frame.origin.x) / self.threshold
            return (progress > 1) ? 1 : progress
        }
    }

    // Should we allow the cell to be pulled past the threshold at all? (.SwipeThrough cells will ignore this)
    var shouldExceedThreshold: Bool = true

    // Control how much elastic resistance there is past threshold, if it can be exceeded. Default is `0.7` and `1.0` would mean no elastic resistance
    var panElasticityFactor: CGFloat = 0.7

    // Length of the animation on release
    var animationDuration: Double = 0.2

    lazy var releaseCompletionBlock:((Bool) -> Void)? = {
        return {
            [weak self] (finished: Bool) in

            guard let this = self else { return }

            this.delegate?.eventDidCompleteRelease(event: this.event)
            this.cleanUp()
        }
    }()

    // MARK: - Properties from BWSwipeRevealCell

    var backViewbackgroundColor: UIColor = UIColor(white: 0.92, alpha: 1)
    var _backView: UIView?
    var backView: UIView? {
        if _backView == nil {
            _backView = UIView(frame: self.contentView.bounds)
            _backView!.backgroundColor = self.backViewbackgroundColor
        }
        return _backView
    }
    var shouldCleanUpBackView = true

    var bgViewInactiveColor: UIColor = UIColor.gray
    var bgViewLeftColor: UIColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1)
    var bgViewRightColor: UIColor = UIColor(red: 0, green: 1.0, blue: 0, alpha: 1)

    var bgViewLeftImage: UIImage?
    var bgViewRightImage: UIImage?

    var _leftBackButton: UIButton?
    var leftBackButton:UIButton? {
        if _leftBackButton == nil {
            _leftBackButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.height))
            _leftBackButton!.setImage(self.bgViewLeftImage, for: .normal)
            _leftBackButton!.addTarget(self, action: #selector(self.leftButtonTapped), for: .touchUpInside)
            _leftBackButton!.tintColor = UIColor.white
            _leftBackButton!.contentMode = .center
            self.backView!.addSubview(_leftBackButton!)
        }
        return _leftBackButton
    }

    var _rightBackButton: UIButton?
    var rightBackButton:UIButton? {
        if _rightBackButton == nil {
            _rightBackButton = UIButton(frame: CGRect(x: self.contentView.frame.maxX, y: 0, width: self.frame.height, height: self.frame.height))
            _rightBackButton!.setImage(self.bgViewRightImage, for: .normal)
            _rightBackButton!.addTarget(self, action: #selector(self.rightButtonTapped), for: .touchUpInside)
            _rightBackButton!.tintColor = UIColor.white
            _rightBackButton!.contentMode = .center
            self.backView!.addSubview(_rightBackButton!)
        }
        return _rightBackButton
    }

    // MARK: - Regular methods

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView = UIView(frame: self.frame)
        self.eventContentView = MGCStandardEventView(frame: self.frame)
        self.backgroundView = UIView(frame: self.frame)
        addSubview(backgroundView)
        addSubview(contentView)
        contentView.addSubview(eventContentView)
        setupSwipeGesture()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = self.frame
        backgroundView.frame = self.frame
        eventContentView.frame = self.frame
    }

    private func setupSwipeGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handleSwipe))
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
    }
}


// MARK: - BWSwipeCell adaptation
extension SwipeableEventView {
    @objc func handleSwipe(panGestureRecognizer: UIPanGestureRecognizer) {
        let translation: CGPoint = panGestureRecognizer.translation(in: panGestureRecognizer.view)
        var panOffset: CGFloat = translation.x

        // If we have elasticity to consider, do some extra calculations for panOffset
        if self.type != .SwipeThrough && abs(translation.x) > self.threshold {
            if self.shouldExceedThreshold {
                let offset: CGFloat = abs(translation.x)
                panOffset = offset - ((offset - self.threshold) * self.panElasticityFactor)
                panOffset *= translation.x < 0 ? -1.0 : 1.0
            } else {
                // If we don't allow exceeding the threshold
                panOffset = translation.x < 0 ? -self.threshold : self.threshold
            }
        }

        // Start, continue or complete the swipe gesture
        let actualTranslation: CGPoint = CGPoint(x: panOffset, y: translation.y)
        if panGestureRecognizer.state == .began && panGestureRecognizer.numberOfTouches > 0 {
            let newTranslation = CGPoint(x: self.contentView.frame.origin.x, y: 0)
            panGestureRecognizer.setTranslation(newTranslation, in: panGestureRecognizer.view)
            didStartSwiping()
            self.animateContentViewForPoint(point: newTranslation)
        }
        else {
            if panGestureRecognizer.state == .changed && panGestureRecognizer.numberOfTouches > 0 {
                self.animateContentViewForPoint(point: actualTranslation)
            }
            else {
                self.resetCellPosition()
            }
        }
    }

    func didChangeSwipeState() {
        if state == .PastThresholdLeft {
            delegate?.eventSwipeActivatedAction(event: event, action: .Rejected)
        } else if state == .PastThresholdRight {
            delegate?.eventSwipeActivatedAction(event: event, action: .Accepted)
        }
        self.delegate?.eventDidChangeState(event: event)
    }

    func didStartSwiping() {
        // From BWSwipeCell
        self.delegate?.eventDidStartSwiping(event: event)

        // From BWSwipeRevealCell
        self.backgroundView!.addSubview(self.backView!)
    }

    func animateContentViewForPoint(point: CGPoint) {
        if (point.x > 0 && self.revealDirection == .Left) || (point.x < 0 && self.revealDirection == .Right) || self.revealDirection == .Both {
            self.contentView.frame = self.contentView.bounds.offsetBy(dx: point.x, dy: 0)
            let previousState = state
            if point.x >= self.threshold {
                self.state = .PastThresholdLeft
            }
            else if point.x < -self.threshold {
                self.state = .PastThresholdRight
            }
            else {
                self.state = .Normal
            }

            if self.state != previousState {
                didChangeSwipeState()
            }
            self.delegate?.eventDidSwipe(event: event!)
        }
        else {
            if (point.x > 0 && self.revealDirection == .Right) || (point.x < 0 && self.revealDirection == .Left) {
                self.contentView.frame = self.contentView.bounds.offsetBy(dx: 0, dy: 0)
            }
        }

        // From BWSwipeRevealCell
        if point.x > 0 {
            let frame = self.leftBackButton!.frame
            let minX = getBackgroundViewImagesMaxX(x: point.x)
            let minY = frame.minY
            self.leftBackButton!.frame = CGRect(x: minX, y: minY, width: frame.width, height: frame.height)
            self.leftBackButton?.alpha = self.progress
            UIView.transition(with: _leftBackButton!, duration: 0.13, options: .transitionCrossDissolve, animations: {
                if point.x >= self.frame.height {
                    self.backView?.backgroundColor = self.bgViewLeftColor
                }
                else {
                    self.backView?.backgroundColor = self.bgViewInactiveColor
                }
                }, completion: nil)
        } else if point.x < 0 {
            let frame = self.rightBackButton!.frame
            let maxX = getBackgroundViewImagesMaxX(x: point.x)
            let minY = frame.minY
            self.rightBackButton!.frame = (CGRect(x: maxX, y: minY, width: frame.width, height: frame.height))
            self.rightBackButton?.alpha = self.progress
            UIView.transition(with: _rightBackButton!, duration: 0.13, options: .transitionCrossDissolve, animations: {
                if -point.x >= self.frame.height {
                    self.backView?.backgroundColor = self.bgViewRightColor
                } else {
                    self.backView?.backgroundColor = self.bgViewInactiveColor
                }
                }, completion: nil)
        }

    }


    func resetCellPosition() {
        self.delegate?.eventWillRelease(event: event!)
        self.animateCellSpringRelease()
        // FIXME: Enable different types of swipe?

        //        if self.type == .SpringRelease || self.state == .Normal {
        //        } else if self.type == .SlidingDoor {
        //            self.animateCellSlidingDoor()
        //        } else {
        //            self.animateCellSwipeThrough()
        //        }
    }

    func animateCellSpringRelease() {
        UIView.animate(withDuration: self.animationDuration,
                                   delay: 0,
                                   options: .curveEaseOut,
                                   animations: {
                                    self.contentView.frame = self.contentView.bounds
            },
                                   completion: self.releaseCompletionBlock)

        // From BWSwipeRevealCell
        // FIXME: Can one of these be removed?
        let pointX = self.contentView.frame.origin.x
        UIView.animate(withDuration: self.animationDuration,
                                   delay: 0,
                                   options: .curveLinear,
                                   animations: {
                                    if pointX > 0 {
                                        self.leftBackButton!.frame.origin.x = -self.threshold
                                    } else if pointX < 0 {
                                        self.rightBackButton!.frame.origin.x = self.frame.maxX
                                    }
            }, completion: nil)
    }

    func cleanUp() {
        self.state = .Normal

        // From BWSwipeRevealCell
        if self.shouldCleanUpBackView {
            _leftBackButton?.removeFromSuperview()
            _leftBackButton = nil
            _rightBackButton?.removeFromSuperview()
            _rightBackButton = nil
            _backView?.removeFromSuperview()
            _backView = nil
        }
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer && self.revealDirection != .none {
            let pan:UIPanGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
            let translation: CGPoint = pan.translation(in: self.superview)
            return (fabs(translation.x) / fabs(translation.y) > 1) ? true : false
        }
        return false
    }

    // MARK: - Reveal Cell

    func getBackgroundViewImagesMaxX(x:CGFloat) -> CGFloat {
        if x > 0 {
            let frame = self.leftBackButton!.frame
            if self.type == .SwipeThrough {
                return self.contentView.frame.origin.x - frame.width
            } else {
                return min(self.contentView.frame.minX - frame.width, 0)
            }
        } else {
            let frame = self.rightBackButton!.frame
            if self.type == .SwipeThrough {
                return self.contentView.frame.maxX
            } else {
                return max(self.frame.maxX - frame.width, self.contentView.frame.maxX)
            }
        }
    }

    @objc func leftButtonTapped () {
        self.shouldCleanUpBackView = true
        self.animateCellSpringRelease()
        delegate?.eventSwipeActivatedAction(event: event, action: .Rejected)
    }
    
    @objc func rightButtonTapped () {
        self.shouldCleanUpBackView = true
        self.animateCellSpringRelease()
        delegate?.eventSwipeActivatedAction(event: event, action: .Accepted)
    }
}


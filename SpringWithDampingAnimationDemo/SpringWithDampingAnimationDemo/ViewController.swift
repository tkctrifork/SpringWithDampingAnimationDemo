//
//  ViewController.swift
//  SpringWithDampingAnimationDemo
//
//  Created by Thomas Kalhøj Clemensen on 25/08/2017.
//  Copyright © 2017 Trifork A/S. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var circleViewCenterXConsraint: NSLayoutConstraint!
    @IBOutlet weak var circleViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var movingSpaceView: UIView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var springLabel: UILabel!
    @IBOutlet weak var initalLabel: UILabel!
    
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var springSlider: UISlider!
    @IBOutlet weak var initialSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.circleView.layer.cornerRadius = self.circleView.bounds.width/2.0
        self.circleView.backgroundColor = UIColor.orange
        
        let pinch: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(ViewController.pinch(_:)))
        self.movingSpaceView.addGestureRecognizer(pinch)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.tap(_:)))
        self.movingSpaceView.addGestureRecognizer(tap)
        
        self.updateLabel(forSlider: self.durationSlider)
        self.updateLabel(forSlider:self.springSlider)
        self.updateLabel(forSlider: self.initialSlider)
        
    }
    
    private func performSpring(animation: @escaping (() -> Void), reset: @escaping (() -> Void)) {
        UIView.animate(withDuration: TimeInterval(self.durationSlider.value/1000.0), delay: 1.0, usingSpringWithDamping: CGFloat(self.springSlider.value), initialSpringVelocity: CGFloat(self.initialSlider.value), options: [.curveEaseOut], animations: {
            animation()
        }) { (finished: Bool) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1), execute: {
                reset()
            })
        }
    }
    
    private func updateLabel(forSlider slider: UISlider) {
        switch slider {
        case self.durationSlider:
            self.durationLabel.text = "\(Int(slider.value)) ms"
        case self.springSlider:
            self.springLabel.text = String(format: "%.02f", slider.value)
        case self.initialSlider:
            self.initalLabel.text = String(format: "%.02f", slider.value)
        default:
            break
        }
    }
    
    //MARK: - 
    func pinch(_ sender: UIPinchGestureRecognizer) {
        let scale: CGFloat = sender.scale
        
        switch sender.state {
        case .changed:
            self.circleView.transform = CGAffineTransform(scaleX: scale, y: scale)
        case .ended, .cancelled:
            self.circleView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            
            self.performSpring(animation: { 
                self.circleView.transform = CGAffineTransform(scaleX: scale, y: scale)
            }, reset: { 
                self.circleView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            })
            
        default:
            break;
        }
    }
    
    func tap(_ sender: UITapGestureRecognizer) {
        let point: CGPoint = sender.location(in: self.movingSpaceView)
        self.performSpring(animation: { 
            self.circleViewCenterXConsraint.constant = point.x - self.movingSpaceView.bounds.width/2.0
            self.circleViewCenterYConstraint.constant = point.y - self.movingSpaceView.bounds.height/2.0
            self.movingSpaceView.layoutIfNeeded()
        }, reset: {
            self.circleViewCenterXConsraint.constant = 0
            self.circleViewCenterYConstraint.constant = 0
            self.movingSpaceView.layoutIfNeeded()
        })
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        self.updateLabel(forSlider: sender)
    }
}


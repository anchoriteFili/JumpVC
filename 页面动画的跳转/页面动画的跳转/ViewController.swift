//
//  ViewController.swift
//  页面动画的跳转
//
//  Created by 赵宏亚 on 16/5/5.
//  Copyright © 2016年 赵宏亚. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UINavigationControllerDelegate,UIViewControllerAnimatedTransitioning,UIViewControllerInteractiveTransitioning {
    
    /**
     UINavigationControllerOperation 表示navigation的过度效果，是一个枚举值
     push 推送效果 pop 效果 none 没有效果
     */
    var navigationOperation: UINavigationControllerOperation? //过度效果
    
    weak var transitionContext: UIViewControllerContextTransitioning?
    weak var transitingView: UIView?
    var isTransiting: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
//        transitionContext?.presentationStyle()
        
        self.navigationController?.delegate = self
        self.navigationController?.view.backgroundColor = UIColor.whiteColor()
        
        //添加了手势？
        let popRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(ViewController.handlePopRecognizer(_:)))
        popRecognizer.edges = UIRectEdge.Left
        self.navigationController?.view.addGestureRecognizer(popRecognizer)
        
    }
    
    /**
     手势方法
     - parameter popRecognizer: 手势
     */
    func handlePopRecognizer(popRecognizer: UIScreenEdgePanGestureRecognizer) {
        
        var progress = popRecognizer.translationInView(navigationController?.view).x/(navigationController?.view.bounds.size.width)!
        progress = min(1.0, max(0.0, progress))
        
        if popRecognizer.state == UIGestureRecognizerState.Began {
            self.navigationController?.popViewControllerAnimated(true)
        } else if popRecognizer.state == UIGestureRecognizerState.Changed {
            updateWithPercent(progress)
            print("change")
        } else if popRecognizer.state == UIGestureRecognizerState.Ended || popRecognizer.state == UIGestureRecognizerState.Cancelled {
            
            finishBy(progress < 0.5)
            print("Ended || Cancelled")
            isTransiting = false
        }
    }
    
    /**
     根据数据转换
     - parameter percent: pi
     */
    func updateWithPercent(percent: CGFloat) {
        let scale = CGFloat(fabsf(Float(percent - CGFloat(1.0))))
        transitingView?.transform = CGAffineTransformMakeScale(scale, scale)
        transitionContext?.updateInteractiveTransition(percent)
    }
    
    func finishBy(cancelled: Bool) {
        if cancelled {
            UIView.animateWithDuration(0.4, animations: { 
                self.transitingView?.transform = CGAffineTransformIdentity
                }, completion: { (completed) in
                    self.transitionContext?.cancelInteractiveTransition()
                    self.transitionContext?.completeTransition(false)
            })
        } else {
            
            UIView.animateWithDuration(0.4, animations: { 
                print(self.transitingView)
                self.transitingView?.transform = CGAffineTransformMakeScale(0, 0)
                print(self.transitingView)
                }, completion: { (completed) in
                    self.transitionContext?.finishInteractiveTransition()
                    self.transitionContext?.completeTransition(true)
            })
        }
    }
    
    
    func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        let containerView = transitionContext.containerView()
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        containerView?.insertSubview((toViewController?.view)!, belowSubview: (fromViewController?.view)!)
        self.transitingView = fromViewController?.view
    }
    
    // UINavigationControllerDelegate
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        navigationOperation = operation
        return self
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if !self.isTransiting {
            return nil
        }
        return self
    }
    
    //UIViewControllerTransitioningDelegate 设置过渡时间
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    // 动画都在这里？
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView()
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        var destView: UIView!
        var destTransform: CGAffineTransform! //。。。矩阵
        
        //推得时候的动画推送效果
        if navigationOperation == UINavigationControllerOperation.Push {
            containerView?.insertSubview(toViewController!.view, aboveSubview: fromViewController!.view)
            destView = toViewController!.view
            destView.transform = CGAffineTransformMakeScale(1, 0.1)
            destTransform = CGAffineTransformMakeScale(1, 1)
            
        } else if navigationOperation == UINavigationControllerOperation.Pop {
            
            containerView!.insertSubview(toViewController!.view, belowSubview: fromViewController!.view)
            
            destView = fromViewController!.view
//            destTransform = CGAffineTransformMakeScale(0.1, 1)
            destTransform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            destTransform = CGAffineTransformScale(destTransform, 0.1, 1)
//            destTransform = CGAffineTransformRotate(destTransform, CGFloat(M_PI))
        }
        
        
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
            destView.transform = destTransform
            }, completion: ({completed in
                if transitionContext.transitionWasCancelled() {
                    //                    destView.removeFromSuperview()
                }
                //告诉系统你的动画过程已经结束，这是非常重要的方法，必须调用。
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            }))
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


//
//  WTipManagerVC.swift
//  Fender
//
//  Created by Arseniy Nikulchenko on 2017-01-03.
//  Copyright © 2017 Fender Technologies Inc. All rights reserved.
//

import UIKit

class WTipManagerVC: UIPageViewController {

    weak var tipDelegate: TipPageViewControllerDelegate?
    var orderedViewControllers: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Help and Tips"
        self.navigationItem.leftBarButtonItem = WAppUtils.leftBarButton("menuBar", controller: self)
        
        dataSource = self
        delegate = self
        
        if let initialViewController = orderedViewControllers.first {
            scrollToViewController(viewController: initialViewController)
        }
        
        tipDelegate?.tipManagerVC(tipManagerVC: self, didUpdatePageCount: orderedViewControllers.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc   func leftBarButtonAction(_ button : UIButton) {
        let drawerController = navigationController?.parent as! KYDrawerController
        drawerController.setDrawerState(.opened, animated: true)
    }
    
    /**
     Scrolls to the next view controller.
     */
    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first,
            let nextViewController = pageViewController(self, viewControllerAfter: visibleViewController) {
            scrollToViewController(viewController: nextViewController)
        }
    }
    
    /**
     Scrolls to the view controller at the given index. Automatically calculates
     the direction.
     
     - parameter newIndex: the new index to scroll to
     */
    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first,
            let currentIndex = orderedViewControllers.index(of: firstViewController) {
            let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[newIndex]
            scrollToViewController(viewController: nextViewController, direction: direction)
        }
    }
    
    /**
     Scrolls to the given 'viewController' page.
     
     - parameter viewController: the view controller to show.
     */
    private func scrollToViewController(viewController: UIViewController,
                                        direction: UIPageViewControllerNavigationDirection = .forward) {
        setViewControllers([viewController],
                           direction: direction,
                           animated: true,
                           completion: { (finished) -> Void in
                            // Setting the view controller programmatically does not fire
                            // any delegate methods, so we have to manually notify the
                            // 'tutorialDelegate' of the new index.
                            self.notifyTipDelegateOfNewIndex()
        })
    }
    
    /**
     Notifies '_tutorialDelegate' that the current page index was updated.
     */
    public func notifyTipDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            tipDelegate?.tipManagerVC(tipManagerVC: self, didUpdatePageIndex: index)
        }
    }
}

// MARK: UIPageViewControllerDataSource

extension WTipManagerVC: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to the last view controller.
        guard previousIndex >= 0 else {
            //return orderedViewControllers.last
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            //return orderedViewControllers.first
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
    
}

extension WTipManagerVC: UIPageViewControllerDelegate {
    
    func pageViewController(pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        notifyTipDelegateOfNewIndex()
    }
}

protocol TipPageViewControllerDelegate: class {
    
    /**
     Called when the number of pages is updated.
     
     - parameter tipManagerVC: the WTipManagerVC instance
     - parameter count: the total number of pages.
     */
    func tipManagerVC(tipManagerVC: WTipManagerVC, didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter tipManagerVC: the WTipManagerVC instance
     - parameter index: the index of the currently visible page.
     */
    func tipManagerVC(tipManagerVC: WTipManagerVC, didUpdatePageIndex index: Int)
    
}

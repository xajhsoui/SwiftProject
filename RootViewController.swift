//
//  RootViewController.swift
//  SouIMusicPlayer
//
//  Created by cao on 2018/05/13.
//  Copyright © 2018年 com.soui. All rights reserved.
//

import UIKit
import AVFoundation

class RootViewController: UIViewController, UIPageViewControllerDelegate, AVAudioPlayerDelegate {
    
    var pageViewController: UIPageViewController?

    var modelController: ModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _modelController == nil {
            _modelController = ModelController()
        }
        return _modelController!
    }
    
    var _modelController: ModelController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Configure the page view controller and add it as a child view controller.
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController!.delegate = self
        
        // 初期化 MyMusic ViewController
        let myMusicViewController: DataViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        let allViewControllers = [myMusicViewController]
        self.pageViewController!.setViewControllers(allViewControllers, direction: .forward, animated: false, completion: {done in })
        
        self.pageViewController!.dataSource = self.modelController
        
        self.addChild(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //告诉系统接受远程响应事件，并注册成为第一响应者
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


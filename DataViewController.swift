//
//  DataViewController.swift
//  SouIMusicPlayer
//
//  Created by cao on 2018/05/13.
//  Copyright © 2018年 com.soui. All rights reserved.
//

import UIKit
import AVFoundation

class DataViewController: UIViewController, AVAudioPlayerDelegate, UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet weak var dataLabel: UILabel!
    var titleObject: String = ""
    
    var audioPlayer:AVAudioPlayer!
    
    enum Enum_PlayMode:Int{
        case mode1_random = 1
        case mode2_repeat
        case mode3_direction
    }
    
    // ボタンのインスタンス生成
    let allPlayBtn = UIButton()
    let randomPlayBtn = UIButton()
//    var isRandomPlay:Bool?
    
    var playMode = Enum_PlayMode.mode1_random
    
    // show music nameラベルのインスタンス生成
    let musicNamelabel = UILabel()
    // show music time
    let musicStartTimelabel = UILabel()
    let musicEndTimelabel = UILabel()
    
    var timer:Timer?
    var playbackSlider: UISlider!
    
    var table:UITableView!
    
    // All music file
    var musicFiles: [ModelMusic] = []
    //    var dictMusic:[Int:ModelMusic] = [:] // Key: Int Value: String
    var playIndex = 0;

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if titleObject.contains("My Music") {
            // スクリーンの横縦幅
            let screenWidth:CGFloat =  self.view.frame.width
            let screenHeight:CGFloat = self.view.frame.height
            
            let imageLine1 = UIImageView()
            imageLine1.frame = CGRect(x:25, y:screenHeight-140, width:screenWidth-45, height:20)
            imageLine1.image = UIImage(named: "background_04")
            self.view.addSubview(imageLine1)
            
            let imageLine2 = UIImageView()
            imageLine2.frame = CGRect(x:20, y:screenHeight-45, width:screenWidth-40, height:30)
            imageLine2.image = UIImage(named: "background_01")
            self.view.addSubview(imageLine2)
            
            // Music Time start
            musicStartTimelabel.frame = CGRect(x:50, y:screenHeight-125, width:40, height:10);
            // ラベルの文字を設定
            musicStartTimelabel.text = "00:00"
            // 文字を中央にalignする
            musicStartTimelabel.textAlignment = NSTextAlignment.left
            // ラベルのフォントサイズ
            musicStartTimelabel.font = UIFont.systemFont(ofSize: 13)
            self.view.addSubview(musicStartTimelabel)
            
            // Music Time end
            musicEndTimelabel.frame = CGRect(x:screenWidth-85, y:screenHeight-125, width:40, height:10);
            // ラベルの文字を設定
            musicEndTimelabel.text = "00:00"
            // 文字を中央にalignする
            musicEndTimelabel.textAlignment = NSTextAlignment.left
            // ラベルのフォントサイズ
            musicEndTimelabel.font = UIFont.systemFont(ofSize: 13)
            self.view.addSubview(musicEndTimelabel)
            
            // ボタンの位置とサイズを設定
            allPlayBtn.frame = CGRect(x:30, y:screenHeight-100, width:40, height:40)
            
            allPlayBtn.setImage(UIImage(named: "all_play_01"), for: .normal)
            // タップされたときのaction
            allPlayBtn.addTarget(self,
                                 action: #selector(allPlayButtonTapped(sender:)),
                                 for: .touchUpInside)
            
            self.view.addSubview(allPlayBtn)
            
            // Music Nameラベルのサイズを設定
            musicNamelabel.frame = CGRect(x:80, y:screenHeight-100, width:screenWidth-allPlayBtn.frame.width - randomPlayBtn.frame.width-40-40-30, height:40);
            // ラベルの文字を設定
            musicNamelabel.text = "..."
            musicNamelabel.textColor = UIColor.black
            // 文字を中央にalignする
            musicNamelabel.textAlignment = NSTextAlignment.left
            //        musicNamelabel.numberOfLines=0
            //        musicNamelabel.lineBreakMode = NSLineBreakMode.byWordWrapping//按照单词分割换行，保证换行时的单词完整。
            //        musicNamelabel.backgroundColor = UIColor.orange
            // ラベルのフォントサイズ
            musicNamelabel.font = UIFont.systemFont(ofSize: 13)
            // テキストの影、色とオフセット
            musicNamelabel.shadowColor = UIColor.yellow
            musicNamelabel.shadowOffset = CGSize(width: 2, height: 2)
            self.view.addSubview(musicNamelabel)
            
            randomPlayBtn.frame = CGRect(x:screenWidth-65, y:screenHeight-90, width:25, height:25)
            randomPlayBtn.setImage(UIImage(named: "random_play_01"), for: .normal) // direction_play_01
            // タップされたときのaction
            randomPlayBtn.addTarget(self,
                                    action: #selector(randomButtonTapped(sender:)),
                                    for: .touchUpInside)
            self.view.addSubview(randomPlayBtn)
            
            // Ready all music file
            // 再生する audio ファイルを取得
            musicFiles = ModelMusic.getALL()
            
            //        let rect = self.pageViewController!.view.frame
            //        let rect = CGRect(x:screenWidth/4, y:50, width:screenWidth/2, height:400);
            let rect = CGRect(x:20, y:55, width:screenWidth-40, height:screenHeight-200);
            self.table = UITableView(frame: rect)
            //设置数据源
            self.table.dataSource = self
            //设置代理
            self.table.delegate = self
            self.view.addSubview(table)
            
            //注册UITableView，cellID为重复使用cell的Identifier
            //        table.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
            table.register(UINib(nibName: "MusicTableViewCell", bundle: nil), forCellReuseIdentifier: "MusicCell")
            table.rowHeight = 50
            //        table.estimatedRowHeight = 80
            //        table.rowHeight = UITableViewAutomaticDimension
            
            //遍历数组的下标和值 enumerated 枚举的意思
            //        for (index , item) in musicFiles.enumerated()
            //        {
            ////            print("下标\(index) 值为\(item)")
            //            dictMusic[index] = item
            //        }
            
            
            // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
            var pageViewRect = self.view.bounds
            if UIDevice.current.userInterfaceIdiom == .pad {
                pageViewRect = pageViewRect.insetBy(dx: 40.0, dy: 40.0)
            }
            self.view.frame = pageViewRect
            
            self.didMove(toParent: self)
            
            // background play
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
                try AVAudioSession.sharedInstance().setActive(true)
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            } catch {
                
            }
            
            // Music play mode controller
//            isRandomPlay = true
        }
        else
        {
            
        }

        
        // Lock screen play
        
        //让viewcontroller支持摇动
        UIApplication.shared.applicationSupportsShakeToEdit = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dataLabel!.text = titleObject
//        NotificationCenter.default.addObserver(self, selector: #selector(self.onOrientationChange(notification:)),name: NSNotification.Name.UIDevice.orientationDidChangeNotification, object: nil)
        //告诉系统接受远程响应事件，并注册成为第一响应者
//        UIApplication.shared.beginReceivingRemoteControlEvents()
//        self.becomeFirstResponder()
    }
    
    // 向きが変わったらframeをセットしなおして再描画
    @objc func onOrientationChange(notification: NSNotification){
        let cgheight:CGFloat!
        if self.view.frame.height > 400 {
            cgheight = self.view.frame.height-200
        } else {
            cgheight = self.view.frame.height-80
        }
        self.table.frame.size = CGSize(width:self.view.frame.width-40, height:cgheight)
        self.table.setNeedsDisplay()
        self.table.reloadData()
    }
    
    /*
     @ MARK: - UITableViewDelegate delegate methods
     @注意：我们前边的ViewController继承了UITableViewDataSource
     @和 UITableViewDelegate。如果我们不注册下面的三个方法XCode就会报错！！！
     */
    //设置cell的数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicFiles.count
    }
    
    //设置section的数量
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //设置tableview的cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MusicTableViewCell = (table.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath)) as! MusicTableViewCell
        
        cell.setCell(music: musicFiles[indexPath.row])
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // auido を再生するプレイヤーを作成する
        let audioUrl = musicFiles[indexPath.row].musicURL
        var audioError:NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl!)
        } catch let error as NSError {
            audioError = error
            audioPlayer = nil
        }
        // Set music property
        musicNamelabel.numberOfLines = 2
        musicNamelabel.font = UIFont.systemFont(ofSize: 13.0)
        // テキストの影、色とオフセット
        musicNamelabel.shadowColor = UIColor.yellow
        musicNamelabel.shadowOffset = CGSize(width: 2, height: 2)
        musicNamelabel.text = musicFiles[indexPath.row].musicName
        let endTime = MusicFunctions.getMMSSFromSS(totalTime: musicFiles[indexPath.row].musicTime!)
        musicEndTimelabel.text =  endTime
        musicStartTimelabel.text = "00:00"
        timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(onUpdate), userInfo: nil, repeats: true)
        
        // エラーが起きたとき
        if let error = audioError {
            print("Error \(error.localizedDescription)")
        }
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        
        // Play music
        audioPlayer.play()
        allPlayBtn.setImage(UIImage(named: "all_pause_01"), for: .normal)
        // set play index
        playIndex = indexPath.row
    }
    
    // MARK: - AVAudioPlayer delegate methods
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        if playMode == Enum_PlayMode.mode1_random {
            playIndex = Int(arc4random_uniform(UInt32(musicFiles.count-1)))
        }
        else if playMode == Enum_PlayMode.mode2_repeat {
            playIndex = playIndex + 0
        }
        else {
            if playIndex == musicFiles.count - 1 {
                playIndex = 0
            }
            else {
                playIndex = playIndex + 1
            }
        }
        // auido を再生するプレイヤーを作成する
        let audioUrl = musicFiles[playIndex].musicURL
        var audioError:NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl!)
        } catch let error as NSError {
            audioError = error
            audioPlayer = nil
        }
        // Set music name
        musicNamelabel.text = musicFiles[playIndex].musicName
        let endTime = MusicFunctions.getMMSSFromSS(totalTime: musicFiles[playIndex].musicTime!)
        musicEndTimelabel.text =  endTime
        
        // エラーが起きたとき
        if let error = audioError {
            print("Error \(error.localizedDescription)")
        }
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
        
        // Play music
        if audioPlayer.isPlaying {
            audioPlayer.stop()
            allPlayBtn.setImage(UIImage(named: "all_play_01"), for: .normal)
        }
        else {
            audioPlayer.play()
            allPlayBtn.setImage(UIImage(named: "all_pause_01"), for: .normal)
        }
    }
    
    @objc func allPlayButtonTapped(sender : AnyObject) {
        //        count += 1
        //        if(count%2 == 0){
        //            label.text = "Playing..."
        //        }
        //        else{
        //            label.text = "Stopping..."
        //        }
        
        //        label.text = audioPlayer
        
        if  audioPlayer == nil  {
            // auido を再生するプレイヤーを作成する
            playIndex = 0
            if playMode == Enum_PlayMode.mode1_random {
                playIndex = Int(arc4random_uniform(UInt32(musicFiles.count-1)))
            }
            else if playMode == Enum_PlayMode.mode2_repeat {
                playIndex = playIndex + 0
            }
            let audioUrl = musicFiles[playIndex].musicURL
            var audioError:NSError?
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioUrl!)
            } catch let error as NSError {
                audioError = error
                audioPlayer = nil
            }
            // Set music property
            musicNamelabel.numberOfLines = 2
            musicNamelabel.font = UIFont.systemFont(ofSize: 13.0)
            // テキストの影、色とオフセット
            musicNamelabel.shadowColor = UIColor.yellow
            musicNamelabel.shadowOffset = CGSize(width: 2, height: 2)
            // Set music property
            musicNamelabel.text = musicFiles[playIndex].musicName
            let endTime = MusicFunctions.getMMSSFromSS(totalTime: musicFiles[playIndex].musicTime!)
            musicEndTimelabel.text =  endTime
            musicStartTimelabel.text = "00:00"
            timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(onUpdate), userInfo: nil, repeats: true)
            
            // エラーが起きたとき
            if let error = audioError {
                print("Error \(error.localizedDescription)")
            }
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            allPlayBtn.setImage(UIImage(named: "all_pause_01"), for: .normal)
        }
        else {
            // Play music
            if audioPlayer.isPlaying  {
                audioPlayer.stop()
                allPlayBtn.setImage(UIImage(named: "all_play_01"), for: .normal)
            }
            else {
                audioPlayer.play()
                allPlayBtn.setImage(UIImage(named: "all_pause_01"), for: .normal)
            }
        }
    }
    
    @objc func randomButtonTapped(sender : AnyObject) {
//        if isRandomPlay! {
//            isRandomPlay = false
//            randomPlayBtn.setImage(UIImage(named: "direction_play_01"), for: .normal) // random_play_01
//
//        }
//        else {
//            isRandomPlay = true
//            randomPlayBtn.setImage(UIImage(named: "random_play_01"), for: .normal)
//        }
        
        if playMode == Enum_PlayMode.mode1_random {
            playMode = Enum_PlayMode.mode2_repeat
            randomPlayBtn.setImage(UIImage(named: "repeat_play_01"), for: .normal)
        }
        else if playMode == Enum_PlayMode.mode2_repeat {
            playMode = Enum_PlayMode.mode3_direction
            randomPlayBtn.setImage(UIImage(named: "direction_play_01"), for: .normal)
        }
        else {
            playMode = Enum_PlayMode.mode1_random
            randomPlayBtn.setImage(UIImage(named: "random_play_01"), for: .normal)
        }
    }
    
    //计时器更新方法
    @objc func onUpdate(){
        //返回播放器当前的播放时间
        let c = audioPlayer.currentTime
        if c > 0.0 {
            //歌曲的总时间
            //            let t = audioPlayer.duration
            //歌曲播放的百分比
            //            let p:CFloat=CFloat(c/t)
            //通过百分比设置进度条
            //            progressView!.setProgress(p, animated: true)
            
            //一个小算法，来实现00：00这种格式的播放时间
            let all:Int = Int(c)
            let m:Int = all % 60
            let f:Int = Int(all/60)
            var time:String = ""
            if f < 10 {
                time = "0\(f):"
            } else {
                time = "\(f)"
            }
            if m < 10 {
                time += "0\(m)"
            } else {
                time += "\(m)"
            }
            //更新播放时间
            musicStartTimelabel.text = time
        }
    }


    // --- MARK Shake
    //开始摇晃
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
//        print("shaking")
        
        if playMode == Enum_PlayMode.mode1_random {
            playIndex = Int(arc4random_uniform(UInt32(musicFiles.count-1)))
        }
        else if playMode == Enum_PlayMode.mode2_repeat {
            playIndex = playIndex + 0
        }
        else {
            if playIndex == musicFiles.count - 1 {
                playIndex = 0
            }
            else {
                playIndex = playIndex + 1
            }
        }
        // auido を再生するプレイヤーを作成する
        let audioUrl = musicFiles[playIndex].musicURL
        var audioError:NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl!)
        } catch let error as NSError {
            audioError = error
            audioPlayer = nil
        }
        // Set music name
        musicNamelabel.text = musicFiles[playIndex].musicName
        let endTime = MusicFunctions.getMMSSFromSS(totalTime: musicFiles[playIndex].musicTime!)
        musicEndTimelabel.text =  endTime
        timer = Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(onUpdate), userInfo: nil, repeats: true)

        // エラーが起きたとき
        if let error = audioError {
            print("Error \(error.localizedDescription)")
        }
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()

        // Play music
        audioPlayer.play()
        allPlayBtn.setImage(UIImage(named: "all_pause_01"), for: .normal)
    }
    
    //摇晃结束
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        //        print("shaked")
    }
    
    //摇晃被意外终止
    override func motionCancelled(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        //        print("shaked interrupt")
    }
}


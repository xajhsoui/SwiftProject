//
//  MusicModel.swift
//  SampleMusicPlayer01
//
//  Created by cao on 2018/05/06.
//  Copyright © 2018年 com.soui. All rights reserved.
//

import UIKit
import AVFoundation

class ModelMusic: NSObject {
    
    var musicName :String?
    var musicURL :URL?
    var musicimg :Data?
    var musicAuthor :String?
    var musicAlbum :String?
    var musicNum:Int?
    var musicTime:Int?
    var isActive:Bool=false
    private static var musicArry:Array<ModelMusic>? = nil
    //    init(title:String,artist:String,album:String,file:String) {
    //        self.musicName = title
    //        self.musicAuthor = artist
    //        self.musicAlbum = album
    //        self.musicURL = file
    //    }
    static func getALL()->Array<ModelMusic>{
        if musicArry == nil {
            var musicArryList=Array<ModelMusic>()
            var fileArry:[String]?
            var num:Int=0;
            let path=Bundle.main.path(forResource:"MyMusic", ofType: nil)
            do{
                try fileArry=FileManager.default.contentsOfDirectory(atPath: path!)
            }
            catch{
                print("error")
            }
            for nFile in fileArry! {
                let singlePath = path! + "/" + nFile
//                let avURLAsset = AVURLAsset(url: URL.init(fileURLWithPath: singlePath))
                let musicModel:ModelMusic = ModelMusic()
                
//                for i in avURLAsset.availableMetadataFormats {
//
//                    for j in avURLAsset.metadata(forFormat: i) {
//                        //歌曲名
//                        if j.commonKey!.rawValue == "title"{
//                            musicModel.musicName = j.value as? String
//
//                        }//封面图片
//                        if j.commonKey!.rawValue == "artwork"{
//                            musicModel.musicimg=j.value as? Data// 这里是个坑坑T T
//                        }//专辑名
//                        if j.commonKey!.rawValue == "albumName"{
//                            musicModel.musicAlbum=j.value as? String
//                        }
//                        //歌手
//                        if j.commonKey!.rawValue == "artist"{
//                            musicModel.musicAuthor=j.value as? String
//                        }
//                    }
//
//                }
                
                musicModel.musicName = nFile
                musicModel.musicURL=URL.init(fileURLWithPath: singlePath)
                
                var playerItem:AVPlayerItem?
                playerItem = AVPlayerItem(url: URL.init(fileURLWithPath: singlePath))
                let duration : CMTime = playerItem!.asset.duration
                let seconds : Float64 = CMTimeGetSeconds(duration)
                musicModel.musicTime = Int(seconds)
                num += 1
                musicModel.musicNum=num;
                musicArryList.append(musicModel)
            }
            musicArry=musicArryList
            return musicArry!
            
        }else{
            return musicArry!
        }
    }
}


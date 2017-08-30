//
//  MainViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/08/30.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import UIKit
import MediaPlayer

class MainViewController: UIViewController {

    fileprivate let audioPlayer = AVAudioPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onTapButton(_ sender: Any) {
        let pickerViewController = MPMediaPickerController(mediaTypes: .music)
        pickerViewController.delegate = self
        pickerViewController.allowsPickingMultipleItems = false
        present(pickerViewController, animated: true, completion: nil)
    }
}

// MARK: - MPMediaPickerControllerDelegate

extension MainViewController : MPMediaPickerControllerDelegate {

    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
    }

    func MainViewController(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
}

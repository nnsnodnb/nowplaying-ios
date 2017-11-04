//
//  AlbumViewController.swift
//  NowPlaying
//
//  Created by Oka Yuya on 2017/08/30.
//  Copyright © 2017年 Oka Yuya. All rights reserved.
//

import UIKit
import MediaPlayer

class AlbumViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    fileprivate var albums = [MPMediaItemCollection]()

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "アルバム一覧"
        createAlbums()
        setupTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Private method

    fileprivate func createAlbums() {
        MPMediaLibrary.requestAuthorization { [unowned self] (status) in
            switch status {
            case .authorized:
                if let collections = MPMediaQuery.albums().collections {
                    self.albums = collections
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            case .denied:
                self.showRequestDeniedAlert()
            case .notDetermined, .restricted:
                break
            }
        }
    }

    fileprivate func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 97
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "AlbumTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "AlbumCell")
    }

    fileprivate func showRequestDeniedAlert() {
        let alert = UIAlertController(title: "アプリを使用するには\n許可が必要です", message: "設定しますか？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        let okAction = UIAlertAction(title: "設定画面へ", style: .default, handler: { _ in
            let url = URL(string: UIApplicationOpenSettingsURLString)!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        })
        alert.addAction(okAction)
        alert.preferredAction = okAction
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension AlbumViewController : UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as! AlbumTableViewCell
        cell.setConfigure(album: albums[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension AlbumViewController : UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let albumDetailViewController = AlbumDetailViewController()
        albumDetailViewController.album = albums[indexPath.row]
        navigationController?.pushViewController(albumDetailViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

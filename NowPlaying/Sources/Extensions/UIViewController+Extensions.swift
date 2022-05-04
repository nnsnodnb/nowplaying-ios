//
//  UIViewController+Extensions.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2021/12/31.
//

import SafariServices
import SnapKit
import UIKit

extension UIViewController {
    func addContainerViewController(_ viewController: UIViewController, to targetView: UIView) {
        guard !children.contains(viewController) else { return }
        addChild(viewController)
        targetView.addSubview(viewController.view)
        viewController.view.snp.makeConstraints { $0.edges.equalToSuperview() }
        viewController.didMove(toParent: self)
        targetView.layoutIfNeeded()
    }

    func removeFromSuperContainerView() {
        view.layer.removeAllAnimations()
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

extension UIViewController {
    func presentSafariViewController(url: URL) {
        if url.scheme == "https" || url.scheme == "http" {
            let safari = SFSafariViewController(url: url)
            safari.dismissButtonStyle = .close
            present(safari, animated: true)
            return
        }
        UIApplication.shared.open(url)
    }
}

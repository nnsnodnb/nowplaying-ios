//
//  AlertConfigurations.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/09/15.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import UIKit

struct AlertConfigurations {

    let title: String?
    let message: String?
    let preferredStyle: UIAlertController.Style
    let actions: [Action]

    struct Action {
        let title: String
        let style: UIAlertAction.Style
        let isPreferredAction: Bool
        let handler: ((UIAlertAction) -> Void)?

        init(title: String, style: UIAlertAction.Style, isPreferredAction: Bool = false, handler: ((UIAlertAction) -> Void)? = nil) {
            self.title = title
            self.style = style
            self.isPreferredAction = isPreferredAction
            self.handler = handler
        }
    }

    func make() -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        actions.forEach {
            let action = UIAlertAction(title: $0.title, style: $0.style, handler: $0.handler)
            alert.addAction(action)
            if $0.isPreferredAction {
                alert.preferredAction = action
            }
        }
        return alert
    }
}

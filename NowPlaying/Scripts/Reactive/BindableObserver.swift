//
//  BindableObserver.swift
//  NowPlaying
//
//  Created by Yuya Oka on 2019/06/06.
//  Copyright © 2019 Oka Yuya. All rights reserved.
//

import Foundation
import RxSwift

final class BindableObserver<ContainerType, ValueType>: ObserverType {

    private var _container: ContainerType?

    private let _binding: (ContainerType, ValueType) -> Void

    init(container: ContainerType, binding: @escaping (ContainerType, ValueType) -> Void) {
        self._container = container
        self._binding = binding
    }

    func on(_ event: Event<ValueType>) {
        switch event {
        case .next(let element):
            guard let container = _container else {
                fatalError("No _container in BindableObserver at time of a .Next event")
            }
            self._binding(container, element)
        case .error:
            self._container = nil
        case .completed:
            self._container = nil
        }
    }

    deinit {
        self._container = nil
    }
}

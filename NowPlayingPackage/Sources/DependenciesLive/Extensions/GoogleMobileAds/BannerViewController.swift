//
//  BannerViewController.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/10/08.
//

import Dependencies
import GoogleMobileAds
import UIKit

public final class BannerViewController: UIViewController {
  // MARK: - Properties
  private let bannerView = BannerView()
  private let adUnitID: String
  private let fixedHeight: CGFloat
  private var currentWidth: CGFloat?

  // MARK: - Dependency
  @Dependency(\.crashlytics)
  private var crashlytics

  // MARK: - Initialize
  public init(adUnitID: String, fixedHeight: CGFloat) {
    self.adUnitID = adUnitID
    self.fixedHeight = fixedHeight
    super.init(nibName: nil, bundle: nil)

    preferredContentSize = CGSize(width: UIView.noIntrinsicMetric, height: fixedHeight)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("Please use init(adUnitID:fixedHeight:)")
  }

  // MARK: - Life Cycle
  override public func viewDidLoad() {
    super.viewDidLoad()

    bannerView.adUnitID = adUnitID
    bannerView.rootViewController = self
    bannerView.delegate = self
    bannerView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(bannerView)

    NSLayoutConstraint.activate([
      bannerView.topAnchor.constraint(equalTo: view.topAnchor),
      bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      bannerView.heightAnchor.constraint(equalToConstant: fixedHeight),
    ])
  }

  override public func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    updateBannerIfNeeded()
  }

  override public func viewWillTransition(
    to size: CGSize,
    with coordinator: UIViewControllerTransitionCoordinator
  ) {
    super.viewWillTransition(to: size, with: coordinator)

    coordinator.animate(
      alongsideTransition: { [weak self] _ in
        self?.updateBanner(for: size.width)
      },
    )
  }

  private func updateBannerIfNeeded() {
    updateBanner(for: view.bounds.width)
  }

  private func updateBanner(for width: CGFloat) {
    let side = floor(width)
    guard side > 0, side != currentWidth else { return }

    currentWidth = side
    bannerView.adSize = largeLandscapeAnchoredAdaptiveBanner(width: side)
    bannerView.load(Request())
  }
}

// MARK: - BannerViewDelegate
extension BannerViewController: BannerViewDelegate {
  public func bannerViewDidReceiveAd(_ bannerView: BannerView) {
  }

  public func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: any Error) {
    try? crashlytics.recordAdBannerLoadError(bannerView.responseInfo, error)
  }
}

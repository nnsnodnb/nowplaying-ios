//
//  LicenseDetailPage.swift
//  NowPlayingPackage
//
//  Created by Yuya Oka on 2026/03/06.
//

import SwiftUI

public struct LicenseDetailPage: View {
  // MARK: - Properties
  public let license: LicensesPlugin.License

  // MARK: - Body
  public var body: some View {
    form
      .navigationTitle(license.name)
  }

  private var form: some View {
    Form {
      if let licenseText = license.licenseText {
        ScrollView {
          Text(licenseText)
            .font(.system(size: 14))
            .foregroundStyle(.secondary)
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
      }
    }
    .formStyle(.columns)
  }
}

#Preview {
  LicenseDetailPage(
    license: .init(
      id: "dummy",
      name: "Dummy",
      licenseText: "Dummy license text",
    ),
  )
}

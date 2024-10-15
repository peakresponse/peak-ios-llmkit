//
//  ModelsViewController.swift
//  LLMKit
//
//  Created by Francis Li on 10/13/2024.
//  Copyright (c) 2024 Francis Li. All rights reserved.
//

import SwiftUI
import UIKit

class ModelsViewController: UIHostingController<ModelsView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: ModelsView())
    }
}

//
//  Instrument.swift
//  ImmersiveMusicARKit
//
//  Created by Dustin Freeman on 2017-12-09.
//  Copyright © 2017 Dustin Freeman. All rights reserved.
//

import SceneKit

class Instrument : SCNNode {
    public var audioSource: SCNAudioSource!
    
    init(audioSource: SCNAudioSource) {
        super.init()
        self.audioSource = audioSource
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  Extensions.swift
//  ImmersiveMusicARKit
//
//  Created by Dustin Freeman on 2017-12-09.
//  Copyright © 2017 Dustin Freeman. All rights reserved.
//

import SceneKit

extension SCNVector3 {
    static func -(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x - right.x, left.y - right.y, left.z - right.z)
    }
    
    static func *(left: SCNVector3, right: Float) -> SCNVector3 {
        return SCNVector3(left.x * right, left.y * right, left.z * right)
    }
}

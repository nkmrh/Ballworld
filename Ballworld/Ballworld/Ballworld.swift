import UIKit
import Metal

class Ballworld: Node {
    
    override var pointSpriteMode: Bool {
        get { return true }
        set { super.pointSpriteMode = newValue }
    }
    
    init(device: MTLDevice) {
        var verticesArray: [Vertex] = []
        let line = 10
        let row = 10
        let depth = 1000

//        for kk in (depth / -2)..<(depth / 2) {
//            for ii in (line / -2)..<(line / 2) {
//                for jj in (row / -2)..<(row / 2) {
//
//                    let k = (Double(kk) * 0.1)
//                    let i = (Double(ii) * 0.1)
//                    let j = (Double(jj) * 0.1)
//
////                    let x2 = Float(j * j)
////                    let y2 = Float(i * i)
////                    let z2 = Float(k * k)
////
////                    let x4 = (y2 * z2) / 3.0
////                    let y4 = (z2 * x2) / 3.0
////                    let z4 = (x2 * y2) / 3.0
////
////                    let x3 = 1.0 - (y2 * 0.5) - (z2 * 0.5) + x4
////                    let y3 = 1.0 - (z2 * 0.5) - (x2 * 0.5) + y4
////                    let z3 = 1.0 - (x2 * 0.5) - (y2 * 0.5) + z4
////
////                    let sx = sqrt(x3)
////                    let sy = sqrt(y3)
////                    let sz = sqrt(z3)
////
////                    let x = Float(j) * sx
////                    let y = Float(i) * sy
////                    let z = Float(k) * sz
//
////                    let x = j * sqrt(1.0 - (i * i / 2))
////                    let y = i * sqrt(1.0 - (j * j / 2))
////                    let z = k
//
//                    // (cos(φ)sin(θ), sin(φ)sin(θ), cos(θ))T
//                    let x = cos(1) * sin(k)
//                    let y = sin(1) * sin(k)
//                    let z = cos(k)
//                    verticesArray.append(Vertex(x: Float(x), y: Float(y), z: Float(z), r: 1.0, g: 0.0, b: 1.0, a: 1.0))
//                }
//            }
//        }

//        xyz = ( double * ) malloc ( 3 * ng * sizeof ( double ) );

        let ng = 100
        let r8_pi = 3.141592653589793
        let r8_phi = (1.0 + sqrt(5.0)) / 2.0
        let ng_r8 = Double(ng)
        for j in 0..<ng {
            let i_r8 = Double(-ng + 1 + 2 * j)
            let theta = 2.0 * r8_pi * i_r8 / r8_phi
            let sphi = i_r8 / ng_r8
            let cphi = sqrt((ng_r8 + i_r8) * (ng_r8 - i_r8)) / ng_r8
            let x = cphi * sin (theta)
            let y = cphi * cos (theta)
            let z = sphi
            verticesArray.append(Vertex(x: Float(x), y: Float(y), z: Float(z), r: 1.0, g: 0.0, b: 1.0, a: 1.0))
        }

        super.init(name: "Ballworld", vertices: verticesArray, device: device)
    }
    
    override func updateWithDelta(delta: CFTimeInterval) {
        super.updateWithDelta(delta: delta)
        
        let secsPerMove: Float = 6.0
        rotationY = sinf(Float(time) * 2.0 * Float.pi / secsPerMove)
        rotationX = sinf(Float(time) * 2.0 * Float.pi / secsPerMove)
    }
}

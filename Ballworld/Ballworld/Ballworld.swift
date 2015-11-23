import UIKit
import Metal

class Ballworld: Node {
    
    override var pointSpriteMode: Bool {
        get { return true }
        set { super.pointSpriteMode = newValue }
    }
    
    init(device: MTLDevice) {
        var verticesArray: [Vertex] = []
        let line = 1.0
        let row = 1.0
        let depth = 1.0

        for var k = depth / -2; k < depth / 2; k+=0.1 {
            for var i = line / -2; i < line / 2; i+=0.1 {
                for var j = row / -2; j < row / 2; j+=0.1 {
                    
//                    let x2 = Float(j * j)
//                    let y2 = Float(i * i)
//                    let z2 = Float(k * k)
//                    
//                    let x4 = (y2 * z2) / 3.0
//                    let y4 = (z2 * x2) / 3.0
//                    let z4 = (x2 * y2) / 3.0
//                    
//                    let x3 = 1.0 - (y2 * 0.5) - (z2 * 0.5) + x4
//                    let y3 = 1.0 - (z2 * 0.5) - (x2 * 0.5) + y4
//                    let z3 = 1.0 - (x2 * 0.5) - (y2 * 0.5) + z4
//                    
//                    let sx = sqrt(x3)
//                    let sy = sqrt(y3)
//                    let sz = sqrt(z3)
//                    
//                    let x = Float(j) * sx
//                    let y = Float(i) * sy
//                    let z = Float(k) * sz
                    
                    let x = j * sqrt(1.0 - (i * i / 2))
                    let y = i * sqrt(1.0 - (j * j / 2))
                    let z = k
                    verticesArray.append(Vertex(x: Float(x), y: Float(y), z: Float(z), r: 1.0, g: 0.0, b: 1.0, a: 1.0))
                }
            }
        }
        
        super.init(name: "Ballworld", vertices: verticesArray, device: device)
    }
    
    override func updateWithDelta(delta: CFTimeInterval) {
        super.updateWithDelta(delta)
        
        let secsPerMove: Float = 6.0
        rotationY = sinf(Float(time) * 2.0 * Float(M_PI) / secsPerMove)
        rotationX = sinf(Float(time) * 2.0 * Float(M_PI) / secsPerMove)
    }
}

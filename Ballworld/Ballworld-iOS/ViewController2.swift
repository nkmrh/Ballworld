import UIKit
import Metal
import QuartzCore

class ViewController2: UIViewController {
    
    var device: MTLDevice! = nil
    var metalLayer: CAMetalLayer! = nil
    
    var particleCount: Int = 0
    var vertexBuffer: MTLBuffer! = nil
    var uniformBuffer: MTLBuffer! = nil
    
    let ptmRatio: Float = 32.0
    let particleRadius: Float = 9
    
    var pipelineState: MTLRenderPipelineState! = nil
    var commandQueue: MTLCommandQueue! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createMetalLayer()
        refreshVertexBuffer()
        refreshUniformBuffer()
        buildRenderPipeline()
        render()
    }
    
    func createMetalLayer() {
        device = MTLCreateSystemDefaultDevice()
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .BGRA8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
    }
    
    func refreshVertexBuffer() {
        particleCount = 1
        let positions = [0.0, 0.0]
        let bufferSize = sizeof(Float) * particleCount * 2
        vertexBuffer = device.newBufferWithBytes(positions, length: bufferSize, options: MTLResourceOptions.CPUCacheModeDefaultCache)
    }
    
    func refreshUniformBuffer() {
        let screenSize: CGSize = UIScreen.mainScreen().bounds.size
        let screenWidth = Float(screenSize.width)
        let screenHeight = Float(screenSize.height)
        let ndcMatrix = makeOrthographicMatrix(0, right: screenWidth, bottom: 0, top: screenHeight, near: -1, far: 1)
        var radius = particleRadius
        var ratio = ptmRatio
        
        let floatSize = sizeof(Float)
        let float4x4ByteAlignment = floatSize * 4
        let float4x4Size = floatSize * 16
        let paddingBytesSize = float4x4ByteAlignment - floatSize * 2
        let uniformsStructSize = float4x4Size + floatSize * 2 + paddingBytesSize
        
        uniformBuffer = device.newBufferWithLength(uniformsStructSize, options: MTLResourceOptions.CPUCacheModeDefaultCache)
        let bufferPointer = uniformBuffer.contents()
        memcpy(bufferPointer, ndcMatrix, float4x4Size)
        memcpy(bufferPointer + float4x4Size, &ratio, floatSize)
        memcpy(bufferPointer + float4x4Size + floatSize, &radius, floatSize)
    }
    
    func makeOrthographicMatrix(left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float) -> [Float] {
        let ral = right + left
        let rsl = right - left
        let tab = top + bottom
        let tsb = top - bottom
        let fan = far + near
        let fsn = far - near
        
        return [2.0 / rsl, 0.0, 0.0, 0.0,
            0.0, 2.0 / tsb, 0.0, 0.0,
            0.0, 0.0, -2.0 / fsn, 0.0,
            -ral / rsl, -tab / tsb, -fan / fsn, 1.0]
    }
    
    func buildRenderPipeline() {
        let defaultLibrary = device.newDefaultLibrary()
        let fragmentProgram = defaultLibrary?.newFunctionWithName("basic_fragment")
        let vertexProgram = defaultLibrary?.newFunctionWithName("particle_vertex")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexProgram
        pipelineDescriptor.fragmentFunction = fragmentProgram
        pipelineDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        
        do {
            try pipelineState = device.newRenderPipelineStateWithDescriptor(pipelineDescriptor)
        } catch {
            print("An error occurred \(error)")
            assert(false);
        }
        
        commandQueue = device.newCommandQueue()
    }
    
    func render() {
        let drawable = metalLayer.nextDrawable()
        
        let renderPassDescriptr = MTLRenderPassDescriptor()
        renderPassDescriptr.colorAttachments[0].texture = drawable?.texture
        renderPassDescriptr.colorAttachments[0].loadAction = .Clear
        renderPassDescriptr.colorAttachments[0].storeAction = .Store
        renderPassDescriptr.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
        
        let commandBuffer = commandQueue.commandBuffer()
        
        let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptr)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, atIndex: 1)
        
        renderEncoder.drawPrimitives(.Point, vertexStart: 0, vertexCount: particleCount, instanceCount: 1)
        renderEncoder.endEncoding()
        
        commandBuffer.presentDrawable(drawable!)
        commandBuffer.commit()
    }
}

// Theme/StarfieldView.swift
import UIKit

class StarfieldView: UIView {
    private var emitterLayer: CAEmitterLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        isUserInteractionEnabled = false
        setupEmitter()
    }
    
    private func setupEmitter() {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
        emitter.emitterSize = bounds.size
        emitter.emitterShape = .rectangle
        emitter.emitterMode = .volume
        
        let cell = CAEmitterCell()
        cell.contents = UIImage(systemName: "circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal).cgImage
        cell.birthRate = 2
        cell.lifetime = 40
        cell.velocity = 5
        cell.velocityRange = 10
        cell.scale = 0.003
        cell.scaleRange = 0.004
        cell.alphaSpeed = -0.01
        
        emitter.emitterCells = [cell]
        layer.addSublayer(emitter)
        emitterLayer = emitter
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        emitterLayer?.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
        emitterLayer?.emitterSize = bounds.size
    }
}

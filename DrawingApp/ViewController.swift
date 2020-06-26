//
//  ViewController.swift
//  DrawingApp
//
//  Created by Gleb Zadonskiy on 26.06.2020.
//  Copyright © 2020 Gleb Zadonskiy. All rights reserved.
//  https://www.youtube.com/watch?v=3d1HNBpqvuM

import UIKit
import PencilKit
import PhotosUI

class ViewController: UIViewController, PKCanvasViewDelegate, PKToolPickerObserver {
    
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var pencilFingerButton: UIBarButtonItem!
    
    let canvasWidth: CGFloat = 768
    let caanvasOverscrollHight: CGFloat = 500
    
    var drawing = PKDrawing()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView.delegate = self
        canvasView.drawing = drawing
        
        canvasView.alwaysBounceVertical = true
        canvasView.allowsFingerDrawing = true
        
        if let window = parent?.view.window,
            let toolPicker = PKToolPicker.shared(for: window){
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            canvasView.becomeFirstResponder()
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let canvasScale = canvasView.bounds.width / canvasWidth
        canvasView.minimumZoomScale = canvasScale
        canvasView.maximumZoomScale = canvasScale
        canvasView.zoomScale = canvasScale
        
        updateContentSizeForDrawinf()
        canvasView.contentOffset = CGPoint(x: 0, y: -canvasView.adjustedContentInset.top)
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool{
        return true
    }

    @IBAction func toogleFingerOrPencol(_ sender: Any){
        canvasView.allowsFingerDrawing.toggle()
        pencilFingerButton.title = canvasView.allowsFingerDrawing ? "Finger" : "Pencil"
    }
    
    
    @IBAction func saveDrawingToCameraRoll(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(canvasView.bounds.size, false, UIScreen.main.scale)
        
        canvasView.drawHierarchy(in: canvasView.bounds, afterScreenUpdates: true)
    }
    
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateContentSizeForDrawinf()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if image != nil {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image!)
            }, completionHandler: {success, error in
                // deal with success or error
            })
        }
    }
    
    func updateContentSizeForDrawinf() {
        let drawing = canvasView.drawing
        let contentHeigth: CGFloat
        
        if !drawing.bounds.isNull {
            contentHeigth = max(canvasView.bounds.height, (drawing.bounds.maxY + self.caanvasOverscrollHight) * canvasView.zoomScale)
        }else{
            contentHeigth = canvasView.bounds.height
        }
        
        canvasView.contentSize = CGSize(width: canvasWidth * canvasView.zoomScale, height: contentHeigth)
        
    }
    
    
}


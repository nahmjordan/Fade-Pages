//
//  DrawViewController.swift
//  Fade Pages
//
//  Created by Jordan Nahm on 2021-03-07.
//  Copyright © 2021 Jordan Nahm. All rights reserved.
//

import UIKit

class Canvas: UIView {
    
    var lines = [[CGPoint]]()
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func saveImageToDocumentDirectory(image: UIImage ) {
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let docURL = URL(string: documentsDirectory)!
        let dataPath = docURL.appendingPathComponent("fadepages")
        print("datapath: " +  dataPath.path)
        
        //check if directory needs to be created
        if !FileManager.default.fileExists(atPath: dataPath.path) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        
//        let dirContents = try? FileManager.default.contentsOfDirectory(atPath: dataPath.path)
//        let imgCount = dirContents!.count
        let format = DateFormatter()
        format.dateFormat = "dd.MM.yyyy"
        let imgDate = Int(Date().timeIntervalSince1970) //seconds
//        let imgDateString = format.string(from: imgDate)
//        print(imgDateString)
        print("save file as \(imgDate)img.png")
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let fileName = "\(imgDate)img.png" // name of the image to be saved
        let folderURL = documentsDir.appendingPathComponent("fadepages")
        let filePath = folderURL.appendingPathComponent(fileName)
        if let data = image.pngData(),!FileManager.default.fileExists(atPath: filePath.path){
            do {
                try data.write(to: filePath)
                print("file saved")
                print("filePath:" + filePath.path)
                let appDel = UIApplication.shared.delegate as! AppDelegate
                appDel.didDraw = true
            } catch {
                print("error saving file:", error)
            }
        }
    }

    
    func undo() {
        let _ = lines.popLast()
        setNeedsDisplay()
    }

    func clear() {
        lines.removeAll()
        setNeedsDisplay()
    }
    
    func done() {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        appDel.tempImg = UIImage()
        let img: UIImage = asImage()
        saveImageToDocumentDirectory(image: img)
        appDel.loadPrevImgCount = 0
//        if let data = img.pngData() {
//            let filename = getDocumentsDirectory().appendingPathComponent("copy.png")
//            try? data.write(to: filename)
//            print("okay?")
//
//            appDel.didDraw = true
//        }
        
        
        //ViewController.collectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: MyCollectionViewCell.identifier)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else {return}
        
        context.setLineWidth(5)
        context.setLineCap(.round)
        
        lines.forEach { (line) in
            for (i,p) in line.enumerated() {
                if i == 0 {
                    context.move(to: p)
                } else {
                    context.addLine(to: p)
                }
            }
        }
        
        context.strokePath()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lines.append([CGPoint]())
        
    }
    
    //track finger
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let point = touches.first?.location(in: nil) else { return }
        //print(point)
        
        //line.append(point)
        guard var lastLine = lines.popLast() else {return}
        lastLine.append(point)
        lines.append(lastLine)
//        var lastLine = lines.last
//        lastLine?.append(point)
        setNeedsDisplay()
    }
    
}

class DrawViewController: UIViewController {
   
    //UI UI UI UI UI UI UI UI UI UI UI UI UI UI
    
    let canvas = Canvas()
    
    let undoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("undo", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(handleUndo), for: .touchUpInside)
        return btn
    }()
    
    let clearButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("clear", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(handleClear), for: .touchUpInside)
        return btn
    }()
    
    let doneButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("done", for: .normal)
        btn.addTarget(self, action: #selector(handleDone), for: .touchUpInside)
        return btn
    }()
    
    @objc fileprivate func handleUndo() {
        print("undo line draw")
        canvas.undo()
    }

    @objc fileprivate func handleClear() {
        print("canvas clear")
        canvas.clear()
    }
    
    @objc fileprivate func handleDone() {
        print("all done :)")
        canvas.done()
    }
    
    
    // FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS FUNCTIONS
    
    override func loadView() {
        self.view = canvas
    }
    
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.viewWillAppear(false)
        self.canvas.addBackground()
        self.canvas.translatesAutoresizingMaskIntoConstraints = true
        //self.canvas.backgroundColor = UIColor.white //removed for dynamism, applies only to new canvas
        self.canvas.isUserInteractionEnabled = true
        //self.canvas.frame = self.frame
        //self.view.addSubview(canvas)
        setupLayout()
       
    }
    
    private func setupLayout() {
        let stackView = UIStackView(arrangedSubviews: [undoButton, clearButton])
        let done = UIStackView(arrangedSubviews: [doneButton])
        stackView.distribution = .fillEqually
        //done.distributon = .fillEqually
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        view.addSubview(done)
        done.translatesAutoresizingMaskIntoConstraints = false
        //done.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        done.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        done.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        doneButton.addTarget(self, action: #selector(doneDrawing), for: .touchUpInside)


    }
    
    @objc func doneDrawing() {
        dismiss(animated: true, completion: nil)
    }

}

//for saving
extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}

extension UIView {
    func addBackground() {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        // screen width and height:
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height

        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        imageViewBackground.image = appDel.tempImg

        // you can change the content mode:
        imageViewBackground.contentMode = UIView.ContentMode.scaleAspectFill

        self.addSubview(imageViewBackground)
        self.sendSubviewToBack(imageViewBackground)
    }
    
}


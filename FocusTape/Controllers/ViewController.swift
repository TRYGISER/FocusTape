//
//  ViewController.swift
//  FocusTape
//
//  Created by Artem Pechenkin on 9/18/20.
//  Sounds: Fire, Thunder, Rain, Crickets, Wind, Stream, Waves, Forest, Birds, Singing Bowl, Meditation
// TODO: Change sounds where white nose is - DONE
// TODO: Correct turn on/off all sounds - DONE
// TODO: Correct autolayouts for old iPhone versions

import UIKit
import AVFoundation
import SVGKit

let reuseIdentifier = "ReusableCell"
var cells: [CollectionViewCell] = []
class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        
        return 3;
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        
        return 4;
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sounds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        cell.soundName = sounds.keys[sounds.index(sounds.startIndex, offsetBy: indexPath.row)] //get short name ex. "wind"
        let image = SVGKImage(named: cell.soundName)
        image?.fillColor(color: colors["yellow"]!, opacity: 1.0)
        cell.buttonImage.setBackgroundImage(image?.uiImage, for: .normal)
        cell.buttonImage.setTitle(cell.soundName, for: .normal) //set short name ex. "wind" like passing variable
        cells.append(cell)
        return cell
    }
    
    @IBOutlet var onSwitch: UISwitch!
    @IBAction func switchToggled(_ sender: UISwitch) {
        if !sender.isOn {
            sender.onTintColor = colors["yellow"]
            cells.forEach {cell in
                if cell.playing {
                    cell.afterPause = true
                    cell.soundSlider.isHidden = true
                    cell.playing = false
                    cell.currentSound?.pause()
                    let image = SVGKImage(named: cell.soundName)
                    image?.fillColor(color: colors["yellow"]!, opacity: 1.0)
                    cell.buttonImage.setBackgroundImage(image?.uiImage, for: .normal)
                }
            }
        } else {
            cells.forEach { cell in
                if (cell.afterPause) {
                    cell.playing = true
                    cell.currentSound?.resume()
                    let image = SVGKImage(named: cell.soundName)
                    image?.fillColor(color: colors["green"]!, opacity: 1.0)
                    cell.buttonImage.setBackgroundImage(image?.uiImage, for: .normal)
                    cell.soundSlider.isHidden = false
                    cell.afterPause = false
                }
            }
        }
    }
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        Sound.enabled = true
    }
    
}
// MARK:- SVGKit module extension
extension SVGKImage {
    
    // MARK:- Private Method(s)
    private func fillColorForSubLayer(layer: CALayer, color: UIColor, opacity: Float) {
        if layer is CAShapeLayer {
            let shapeLayer = layer as! CAShapeLayer
            shapeLayer.fillColor = color.cgColor
            shapeLayer.opacity = opacity
        }

        if let sublayers = layer.sublayers {
            for subLayer in sublayers {
                fillColorForSubLayer(layer: subLayer, color: color, opacity: opacity)
            }
        }
    }

    private func fillColorForOutter(layer: CALayer, color: UIColor, opacity: Float) {
        if let shapeLayer = layer.sublayers?.first as? CAShapeLayer {
            shapeLayer.fillColor = color.cgColor
            shapeLayer.opacity = opacity
        }
    }

    // MARK:- Public Method(s)
    func fillColor(color: UIColor, opacity: Float) {
        if let layer = caLayerTree {
            fillColorForSubLayer(layer: layer, color: color, opacity: opacity)
        }
    }

    func fillOutterLayerColor(color: UIColor, opacity: Float) {
        if let layer = caLayerTree {
            fillColorForOutter(layer: layer, color: color, opacity: opacity)
        }
    }
    
    static func getImage(imageName: String, fontSize size: CGSize, fillColor color: UIColor?, opacity: Float = 1.0) -> UIImage? {
        let svgImage: SVGKImage = SVGKImage(named: imageName)
        svgImage.size = size
        if let colorToFill = color {
           svgImage.fillColor(color: colorToFill, opacity: opacity)
        }

       return svgImage.uiImage
    }
    
}

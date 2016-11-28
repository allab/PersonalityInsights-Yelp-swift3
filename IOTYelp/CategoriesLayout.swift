//
//  CategoriesLayout.swift
//  IOTYelp
//
//  Created by Alla Bondarenko on 2016-11-23.
//  Copyright © 2016 Alla Bondarenko. All rights reserved.
//

import UIKit

protocol CategoriesLayoutDelegate {
    func collectionView(collectionView: UICollectionView,
                        widthForAnnotationAtIndexPath indexPath: IndexPath, withHeight width: CGFloat) -> CGFloat
}

class CategoriesLayout: UICollectionViewLayout {
    
    var delegate: CategoriesLayoutDelegate!
    
    var cellPadding: CGFloat = 10.0
    private var contentWidth: CGFloat = 0.0
    private var contentHeight: CGFloat = 22.0
    
    private var cache = [UICollectionViewLayoutAttributes]()
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    //MARK: Styling collection view cell
    
    override func prepare() {
        if cache.isEmpty {
            var xOffset = CGFloat()
            var yOffset = CGFloat()
            
            for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                
                let collectionViewWidth = collectionView!.bounds.width
                
                let fontSize = CGFloat(21)
                let height = cellPadding  + fontSize + cellPadding
                let annotationWidth = delegate.collectionView(collectionView: collectionView!,
                                                              widthForAnnotationAtIndexPath: indexPath, withHeight: height)
                
                let width = cellPadding + annotationWidth + cellPadding
                
                if (xOffset + width >= collectionViewWidth) {
                    xOffset = 0.0
                    yOffset += contentHeight
                }
                
                let frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
                let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = insetFrame
                cache.append(attributes)
                
                
                contentWidth = max(contentWidth, frame.maxX)
                xOffset = xOffset + width
            }
        }
    }
    
    
}

//
//  WinterView.swift
//  Runway
//
//  Created by Jelle Vandebeeck on 21/11/15.
//  Copyright © 2015 Soaring Book. All rights reserved.
//

import UIKit

protocol WinterViewDelegate {
    func winterView(view: WinterView, didSelectRegistration registration: Registration, atIndexPath indexPath: NSIndexPath)
    func winterViewWillStartRegistration(view: WinterView, fromView subview: UIView)
    
    func winterViewDidStartSync(view: WinterView)
    func winterViewDidCancelSync(view: WinterView)
}

class WinterView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var syncButton: SyncButton!
    @IBOutlet var titleLabel: UILabel!
    
    var delegate: WinterViewDelegate?
    
    var registrations: [Registration] = [Registration]()
    
    // MARK: - Init
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.text = NSLocalizedString("work_labels_title", comment: "").uppercaseString
        
        collectionView.registerNib(UINib(nibName: "NamedImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        collectionView.registerNib(UINib(nibName: "IconCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Add")
        setupLayout()
        
        NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "updateTimer", userInfo: nil, repeats: true)
    }
    
    func setupLayout() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsetsMake(0.0, 20.0, 20.0, 20.0)
        }
    }
    
    // MARK: - Data
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    func removeRegistration(atIndexPath indexPath: NSIndexPath) {
        registrations.removeAtIndex(rowForRegistration(atIndexPath: indexPath))
        collectionView.deleteItemsAtIndexPaths([indexPath])
    }
    
    // MARK: - Sync
    
    func startSyncing() {
        syncButton.startAnimating()
    }
    
    func stopSyncing() {
        syncButton.stopAnimating()
    }
    
    func toggleBadge(show: Bool) {
        if show {
            syncButton.showBadge()
        } else {
            syncButton.hideBadge()
        }
    }
    
    // MARK: - Timer
    
    func updateTimer() {
        for cell in collectionView.visibleCells() {
            if let indexPath = collectionView.indexPathForCell(cell) {
                if let cell = cell as? NamedImageCollectionViewCell {
                    let registration = registrations[rowForRegistration(atIndexPath: indexPath)]
                    cell.update(time: registration.startedAt)
                }
            }
        }
    }
    
    // MARK: - CollectionView
    
    func updateCollectionView() {
        collectionView.performBatchUpdates({ () -> Void in
            // We reload all the cells just to make sure they are resized.
            self.collectionView.reloadItemsAtIndexPaths(self.collectionView.indexPathsForVisibleItems())
        }, completion: nil)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let padding = 10.0
        let numberOfRows = UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) ? 3.0 : 4.0
        let height = floor((collectionView.frame.size.height - CGFloat(numberOfRows * padding) - CGFloat(40)) / CGFloat(numberOfRows))
        return CGSizeMake(height, height)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
                delegate?.winterViewWillStartRegistration(self, fromView: cell)
            }
        } else {
            let registration = registrations[rowForRegistration(atIndexPath: indexPath)]
            delegate?.winterView(self, didSelectRegistration: registration, atIndexPath: indexPath)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Add an extra add cell.
        return registrations.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            return addCell(forIndexPath: indexPath)
        } else {
            return registrationCell(forIndexPath: indexPath)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func sync(sender: AnyObject) {
        if syncButton.animating {
            delegate?.winterViewDidCancelSync(self)
        } else {
            delegate?.winterViewDidStartSync(self)
        }
    }
    
    // MARK: - Hit
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        guard syncButton.animating else {
            return super.hitTest(point, withEvent: event)
        }
        
        if super.hitTest(point, withEvent: event) == syncButton {
            return syncButton
        } else {
            shake()
            return nil
        }
    }
    
    // MARK: - Cells
    
    private func addCell(forIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Add", forIndexPath: indexPath) as! IconCollectionViewCell
        cell.configure()
        return cell
    }
    
    private func registrationCell(forIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! NamedImageCollectionViewCell
        let item = registrations[rowForRegistration(atIndexPath: indexPath)]
        cell.configureTime(item: item.pilot!)
        return cell
    }
    
    // MARK: - Index path
    
    private func rowForRegistration(atIndexPath indexPath: NSIndexPath) -> Int {
        return indexPath.item - 1
    }
}
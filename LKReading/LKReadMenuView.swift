//
//  LKReadMenuView.swift
//  LKReading
//
//  Created by klike on 2018/5/31.
//  Copyright © 2018年 kLike. All rights reserved.
//

import UIKit
import RealmSwift

protocol LKReadMenuViewDelegate {
    func exitReading()
    func choosedChapter(chapterId: String)
    func changeReadBackground()
    func changeReadFont()
    func nextChapter()
    func lastChapter()
    func pageChange(value: Float)
    func transitionStyleChange(style: LKTransitionStyle)
}


class LKReadMenuView: UIView {
    
    var delegate: LKReadMenuViewDelegate?
    var titlesArr: [LKReadChapterModel]? {
        didSet {
            titleTabView.reloadData()
        }
    }

    @IBOutlet weak var pageBtn1: UIButton!
    @IBOutlet weak var pageBtn2: UIButton!
    @IBOutlet weak var pageBtn3: UIButton!
    @IBOutlet weak var fontLab: UILabel!

    @IBOutlet weak var back1: UIButton!
    @IBOutlet weak var back2: UIButton!
    @IBOutlet weak var back3: UIButton!
    @IBOutlet weak var back4: UIButton!

    @IBOutlet weak var pageSlider: UISlider!
    @IBOutlet weak var lightSlider: UISlider!
    @IBOutlet weak var pageStack: UIStackView!
    
    @IBOutlet weak var navViewH: NSLayoutConstraint!
    @IBOutlet weak var setViewH: NSLayoutConstraint!
    @IBOutlet weak var chapterViewH: NSLayoutConstraint!
    @IBOutlet weak var directoriesViewW: NSLayoutConstraint!
    @IBOutlet weak var bookNameLabTop: NSLayoutConstraint!
    
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var setView: UIView!
    @IBOutlet weak var chapterView: UIView!
    @IBOutlet weak var directoriesView: UIView!
    @IBOutlet weak var titleTabView: UITableView!
    @IBOutlet weak var bookNameLab: UILabel!
    
    var showing: Bool = false
    
    override func awakeFromNib() {
        titleTabView.delegate = self
        titleTabView.dataSource = self
        directoriesViewW.constant = kScreenW * 0.8
        bookNameLabTop.constant = kStatusBarH
        isUserInteractionEnabled = true
        
        titleTabView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dissmiss))
        dismissTap.delegate = self
        addGestureRecognizer(dismissTap)
        
        navView.transform = CGAffineTransform(translationX: 0, y: -navViewH.constant)
        setView.transform = CGAffineTransform(translationX: 0, y: setViewH.constant)
        chapterView.transform = CGAffineTransform(translationX: 0, y: chapterViewH.constant)
        directoriesView.transform = CGAffineTransform(translationX: -directoriesViewW.constant, y: 0)
        
        lightSlider.setThumbImage(UIImage(named: "bookRead_jindutiao"), for: .normal)
        [back1, back2, back3, back4].enumerated().forEach { (index, btn) in
            btn?.setImage(UIImage(named: "bookRead_color\(index + 1)\(index + 1)"), for: .selected)
            btn?.isSelected = LKReadTheme.share.backImgIndex == index
        }

        [pageBtn1, pageBtn2, pageBtn3].enumerated().forEach { (index, btn) in
            if index == LKReadTheme.share.transitionStyleIndex {
                btn?.backgroundColor = UIColor.colorFromHex(0x46BD81)
                btn?.layer.borderWidth = 0.5
                btn?.layer.borderColor = UIColor.clear.cgColor
                btn?.setTitleColor(UIColor.white, for: .normal)
            } else {
                btn?.backgroundColor = UIColor.clear
                btn?.layer.borderWidth = 0.5
                btn?.layer.borderColor = UIColor.colorFromHex(0x999999).cgColor
                btn?.setTitleColor(UIColor.colorFromHex(0x999999), for: .normal)
            }
        }
        
        fontLab.text = "\(Int(LKReadTheme.share.fontSize))"
    }
    
    func show() {
        showing = true
        isHidden = false
        backgroundColor = UIColor.clear
        UIView.animate(withDuration: 0.3) {
            self.navView.transform = CGAffineTransform(translationX: 0, y: 0)
            self.chapterView.transform = CGAffineTransform(translationX: 0, y: 0)
        }
    }
    
    @objc func dissmiss() {
        showing = false
        UIView.animate(withDuration: 0.3, animations: {
            self.navView.transform = CGAffineTransform(translationX: 0, y: -self.navViewH.constant)
            self.setView.transform = CGAffineTransform(translationX: 0, y: self.setViewH.constant)
            self.chapterView.transform = CGAffineTransform(translationX: 0, y: self.chapterViewH.constant)
            self.directoriesView.transform = CGAffineTransform(translationX: -self.directoriesViewW.constant, y: 0)
        }) { (_) in
            self.isHidden = true
        }
    }
    
    func scrollToReadingChapter(chapterId: String) {
        if let index = titlesArr?.index(where: { $0.id == chapterId }) {
            titleTabView.selectRow(at: IndexPath.init(row: index, section: 0), animated: false, scrollPosition: .middle)
            titleTabView.scrollToRow(at: IndexPath.init(row: index, section: 0), at: .middle, animated: false)
        }
    }
    
    @IBAction func setViewShow(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.setView.transform = CGAffineTransform(translationX: 0, y: 0)
            self.chapterView.transform = CGAffineTransform(translationX: 0, y: self.chapterViewH.constant)
        }
    }
    
    @IBAction func directoriesViewShow(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3) {
            self.navView.transform = CGAffineTransform(translationX: 0, y: -self.navViewH.constant)
            self.setView.transform = CGAffineTransform(translationX: 0, y: self.setViewH.constant)
            self.chapterView.transform = CGAffineTransform(translationX: 0, y: self.chapterViewH.constant)
            self.directoriesView.transform = CGAffineTransform(translationX: 0, y: 0)
            self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }
    }
    
    @IBAction func fontDown(_ sender: UIButton) {
        LKReadTheme.share.fontSize -= 1
        fontLab.text = "\(Int(LKReadTheme.share.fontSize))"
        delegate?.changeReadFont()
    }
    
    @IBAction func fontAdd(_ sender: UIButton) {
        LKReadTheme.share.fontSize += 1
        fontLab.text = "\(Int(LKReadTheme.share.fontSize))"
        delegate?.changeReadFont()
    }
    
    @IBAction func backgroundChange(_ sender: UIButton) {
        [back1, back2, back3, back4].enumerated().forEach { (index, btn) in
            if sender == btn {
                LKReadTheme.share.backImgIndex = index
            }
            btn?.isSelected = sender == btn
        }
        delegate?.changeReadBackground()
    }
    
    @IBAction func pageChange(_ sender: UIButton) {
        var styleArr: [LKTransitionStyle] = [.pageCurl, .scroll, .none]
        [pageBtn1, pageBtn2, pageBtn3].enumerated().forEach { (index, btn) in
            if sender == btn {
                btn?.backgroundColor = UIColor.colorFromHex(0x46BD81)
                btn?.layer.borderWidth = 0.5
                btn?.layer.borderColor = UIColor.clear.cgColor
                btn?.setTitleColor(UIColor.white, for: .normal)
                delegate?.transitionStyleChange(style: styleArr[index])
                LKReadTheme.share.transitionStyleIndex = index
            } else {
                btn?.backgroundColor = UIColor.clear
                btn?.layer.borderWidth = 0.5
                btn?.layer.borderColor = UIColor.colorFromHex(0x999999).cgColor
                btn?.setTitleColor(UIColor.colorFromHex(0x999999), for: .normal)
            }
        }
    }
    
    @IBAction func exitClick(_ sender: UIButton) {
        delegate?.exitReading()
    }
    
    @IBAction func lightChange(_ sender: UISlider) {
        UIScreen.main.brightness = CGFloat(sender.value)
    }
    
    @IBAction func lastChapter(_ sender: UIButton) {
        delegate?.lastChapter()
        pageSlider.value = 0
    }
    
    @IBAction func nextChapter(_ sender: UIButton) {
        delegate?.nextChapter()
        pageSlider.value = 0
    }
    
    @IBAction func pageSilderChange(_ sender: UISlider) {
        delegate?.pageChange(value: sender.value)
    }
    
}


extension LKReadMenuView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titlesArr?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!
        cell.textLabel?.text = titlesArr?[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dissmiss()
        if let chapterId = titlesArr?[indexPath.row].id {
            delegate?.choosedChapter(chapterId: chapterId)
        }
    }
    
}


extension LKReadMenuView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view {
            if touchView.isDescendant(of: chapterView) || touchView.isDescendant(of: setView) || touchView.isDescendant(of: directoriesView) || touchView.isDescendant(of: navView) || touchView.isDescendant(of: titleTabView) {
                return false
            }
        }
        return true
    }
    
}


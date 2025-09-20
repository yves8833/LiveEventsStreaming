    //
    //  AssociatedKeys.swift
    //  LiveEventsStreaming
    //
    //  Created by Yves on 2025/9/20.
    //


import UIKit
import Combine

import UIKit
import Combine
import ObjectiveC.runtime

extension UIViewController {
        // MARK: - Public Publishers
    var viewWillAppearPublisher: AnyPublisher<Void, Never> {
        _ensureSwizzled()
        let subject: PassthroughSubject<Void, Never> = _associatedSubject(forKey: &AssociatedKeys.viewWillAppearKey)
        return subject.eraseToAnyPublisher()
    }
    
    var viewWillDisappearPublisher: AnyPublisher<Void, Never> {
        _ensureSwizzled()
        let subject: PassthroughSubject<Void, Never> = _associatedSubject(forKey: &AssociatedKeys.viewWillDisappearKey)
        return subject.eraseToAnyPublisher()
    }
    
        // MARK: - Swizzled Implementations
    @objc private func combine_viewWillAppear(_ animated: Bool) {
        combine_viewWillAppear(animated)
        
        if let subject = objc_getAssociatedObject(self, &AssociatedKeys.viewWillAppearKey) as? PassthroughSubject<Void, Never> {
            subject.send(())
        }
    }
    
    @objc private func combine_viewWillDisappear(_ animated: Bool) {
        combine_viewWillDisappear(animated)
        
        if let subject = objc_getAssociatedObject(self, &AssociatedKeys.viewWillDisappearKey) as? PassthroughSubject<Void, Never> {
            subject.send(())
        }
    }
}

    // MARK: - Private helpers
private extension UIViewController {
    struct AssociatedKeys {
        static var viewWillAppearKey: UInt8 = 0
        static var viewWillDisappearKey: UInt8 = 1
        static var didSwizzleOnce: Bool = false
    }
    
        /// 取得或建立與某 key 綁定的 subject
    func _associatedSubject<T>(forKey key: UnsafeRawPointer) -> T where T: AnyObject {
        if let existing = objc_getAssociatedObject(self, key) as? T {
            return existing
        }
            // 這裡我們只會用到 PassthroughSubject<Bool, Never>
        let subject = PassthroughSubject<Void, Never>() as AnyObject
        objc_setAssociatedObject(self, key, subject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return subject as! T
    }
    
        /// 確保只 swizzle 一次，且一次交換兩個方法
    func _ensureSwizzled() {
            // Quick path
        if AssociatedKeys.didSwizzleOnce { return }
        
            // Thread-safe 防重入
        objc_sync_enter(UIViewController.self)
        defer { objc_sync_exit(UIViewController.self) }
        
        guard !AssociatedKeys.didSwizzleOnce else { return }
        AssociatedKeys.didSwizzleOnce = true
        
        let cls: AnyClass = UIViewController.self
        
        _swizzle(cls,
                 original: #selector(UIViewController.viewWillAppear(_:)),
                 swizzled: #selector(UIViewController.combine_viewWillAppear(_:)))
        
        _swizzle(cls,
                 original: #selector(UIViewController.viewWillDisappear(_:)),
                 swizzled: #selector(UIViewController.combine_viewWillDisappear(_:)))
    }
    
    func _swizzle(_ cls: AnyClass, original: Selector, swizzled: Selector) {
        guard
            let originalMethod = class_getInstanceMethod(cls, original),
            let swizzledMethod = class_getInstanceMethod(cls, swizzled)
        else { return }
        
        let added = class_addMethod(cls,
                                    original,
                                    method_getImplementation(swizzledMethod),
                                    method_getTypeEncoding(swizzledMethod))
        
        if added {
            class_replaceMethod(cls,
                                swizzled,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
}


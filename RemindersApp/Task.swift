//
//  Task.swift
//  RemindersApp
//
//  Created by Pratheeksha Ravindra Naik on 2018-10-26.
//  Copyright © 2018. All rights reserved.
//

import UIKit

class Task {
    
    //Mark: Properties
    
    var title: String
    var photo: UIImage?
    var currentDate: String
    var dueDate: String
    var priority: String
    var notes: String
    
    //mark: initalization
    
    init(title: String, photo: UIImage?, currentDate: String, dueDate: String, priority: String, notes: String) {
    
        self.currentDate = currentDate
        self.dueDate = dueDate
        self.notes = notes
        self.photo = photo
        self.title = title
        self.priority = priority
    }
    
    
}

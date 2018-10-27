//
//  TaskViewController.swift
//  
//
//  Created by Pratheeksha on 2018-10-19.
//  Copyright © 2018. All rights reserved.
//

import os.log
import UIKit

class TaskViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var desc: UITextField!
    @IBOutlet weak var reminderNameText: UITextField!
    @IBOutlet weak var currentDateAndTime: UITextField!
    @IBOutlet weak var reminderName: UILabel!
    @IBOutlet weak var dueDateAndTime: UITextField!
    @IBOutlet weak var priorityTextField: UITextField!
    @IBOutlet weak var reminderImage: UIImageView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    private var datePicker: UIDatePicker?
    var priority = ["High", "Medium", "Low"];
    var picker = UIPickerView();
    
    var task: Task?
    
    //MARK: Navigation
    
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let title = reminderNameText.text ?? ""
        let photo = reminderImage.image
        let currentDate = currentDateAndTime.text ?? ""
        let dueDate = dueDateAndTime.text ?? ""
        let priority = priorityTextField.text ?? ""
        let notes = desc.text ?? ""
        
        task = Task(title: title, photo: photo, currentDate: currentDate, dueDate: dueDate, priority: priority, notes: notes)
    }
    
    //MARK: Actions
    @IBAction func chooseImage(_ sender: Any) {
        let imagePickerController = UIImagePickerController();
        imagePickerController.delegate = self;
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet);
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action : UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
            else{
                print("Cannot use camera");
            }
            
            
        }));
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {(action : UIAlertAction) in imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }));
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil));
        self.present(actionSheet, animated: true, completion: nil);
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage;
        reminderImage.image = image;
        
        picker.dismiss(animated: true, completion: nil);
    }
    

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil);
    }
    override func viewDidLoad() {
        super.viewDidLoad();
        // Do any additional setup after loading the view, typically from a nib.
        reminderNameText.delegate = self;
        printCurrentDateAndTime();
        setDateAndTime();
        showPriority();
       
        
        // Set up views if editing an existing Meal.
        if let task = task {
            reminderNameText.text = task.title
            navigationItem.title = task.title
            currentDateAndTime.text = task.currentDate
            dueDateAndTime.text = task.dueDate
            desc.text = task.notes
            priorityTextField.text = task.priority
            reminderImage.image = task.photo
        }
        
         updateSaveButtonState()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
         return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    private func textFieldShouldBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    
    private func updateSaveButtonState()
    {
        // Disable the Save button if the text field is empty.
        let text = reminderNameText.text ?? ""
        saveButton.isEnabled = !text.isEmpty
        
    }
    func printCurrentDateAndTime(){
        
        let formatter = DateFormatter();
        formatter.dateStyle = .long;
        formatter.timeStyle = .medium;
        let str = formatter.string(from: Date());
        currentDateAndTime.text = str;
    }
    
    
    func setDateAndTime(){
        let datePicker = UIDatePicker();
        datePicker.datePickerMode = .dateAndTime;
        datePicker.addTarget(self, action: #selector(TaskViewController.dateChanged(datePicker:)), for: .valueChanged)
        dueDateAndTime.inputView = datePicker;
        
    }
    
    @objc func  dateChanged(datePicker: UIDatePicker) {
        let formatter = DateFormatter();
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TaskViewController.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture);
        formatter.dateStyle = .long;
        formatter.timeStyle = .medium;
        let str = formatter.string(from: datePicker.date);
        dueDateAndTime.text = str;
        view.endEditing(true);
        
    }
    
    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer){
        view.endEditing(true);
    }
    
  
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return priority.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        priorityTextField.text = priority[row];
        view.endEditing(true);
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return priority[row];
    }
    
    func showPriority() {
        picker.delegate = self;
        picker.dataSource = self;
        priorityTextField.inputView = picker;
        view.endEditing(true);

    }
}


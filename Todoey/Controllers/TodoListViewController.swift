//
//  ViewController.swift
//  Todoey
//
//  Created by Timothy J. Prunty on 7/7/18.
//  Copyright © 2018 Timco Collaborations Inc. LLC. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
 
    var itemArray = [Item]()
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    
        
       // if let items = defaults.array(forKey: "TodoListArray") as? [Item] {
       //    itemArray = items
       // }
        
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        // Ternary operator ==>
        // value = condition ? valueIfTrue : valueIfFalse
        
        cell.accessoryType = item.done ? .checkmark : .none //This 1 line replaces the 5 lines of code below.
        
        //if item.done == true {
        //        cell.accessoryType = .checkmark
        //} else {
        //    cell.accessoryType = .none
        //}
        
        return cell
        
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  //      print(itemArray[indexPath.row])
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done  // The "!" means set to opposite BOOL value.
        
        // Below lines of code commented out, was used to show hoe to DELETE rows in Core Data DB.
        
                                                    // * Order of below command lines is important.
//        context.delete(itemArray[indexPath.row])    // 1st remove from temporary context storage.
//        itemArray.remove(at: indexPath.row)         // 2nd remove from itemArray.
        
        
        saveItems()                                 // 3rd Save permanently.
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add New Items
    
   
    @IBAction func addButton2Pressed(_ sender: UIBarButtonItem) {

        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            //what will hapen once the user clicks the Add Itembutton on our UIAlert.
            
            
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            
            //self.defaults.set(self.itemArray, forKey: "TodoListArray")
            
            self.saveItems()
        }
            
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            }
        
            alert.addAction(action)
            
            present(alert, animated: true, completion: nil)
            
        }



    //MARK: Model Manipulation Methods
    
    func saveItems() {
        
        do {
           try context.save()
        } catch {
            print("Error saving context \(error)")
           
        }
        
        //Refreshes tableView after new item appended.
        tableView.reloadData()
    }
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
     let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
 
            do {
                itemArray = try context.fetch(request)
            } catch {
                print("Error fetching data from context \(error)")
            }

    }
}
//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        print(searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)
       
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
}

        


    



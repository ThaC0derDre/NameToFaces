//
//  ViewController.swift
//  NameToFaces
//
//  Created by Andres Gutierrez on 2/6/22.
//

import UIKit

class ViewController: UICollectionViewController {
    
    let defaults    = UserDefaults.standard
    var people      = [Person]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem    = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        
        if let savedPeople  = defaults.object(forKey: "people") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                people      = try jsonDecoder.decode([Person].self, from: savedPeople)
            } catch {
                print("Error retrieving Data")
            }
        }
        
    }
        
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Error, could not make cell a PersonCell")
        }
        let person                          = people[indexPath.item]
        cell.name.text                      = person.name
        
        let path                            = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image                = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor    = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth    = 2
        cell.imageView.layer.cornerRadius   = 3
        cell.layer.cornerRadius             = 7
        
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person  = people[indexPath.item]
        
        let ac      = UIAlertController(title: "What's this person's name?", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self, weak ac ] _ in
            guard let self      = self else { return }
            guard let newName   = ac?.textFields?[0].text else { return }
            person.name         = newName
            self.save()
            self.collectionView.reloadData()
            
        })
        
        let aCon    = UIAlertController(title: "Edit person", message: "What do you want to do?", preferredStyle: .alert)
        aCon.addAction(UIAlertAction(title: "Edit name", style: .default){ [weak self] _ in
            guard let self  = self else { return }
            self.present(ac, animated: true)
        })
        aCon.addAction(UIAlertAction(title: "Delete Person", style: .destructive){[ weak self ] _ in
            guard let self = self else { return }
            self.deleteCell(indexPath: indexPath)
        })
        present(aCon, animated: true)
    }
    
    
    @objc func addNewPerson() {
        let picker              = UIImagePickerController()
        picker.allowsEditing    = true
        picker.delegate         = self
        present(picker, animated: true)
    }
    
    func deleteCell(indexPath: IndexPath) {
        people.remove(at: indexPath.item)
        save()
        collectionView.reloadData()
    }
}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image     = info[.editedImage] as? UIImage else { return }
        
        let imageName       = UUID().uuidString
        let imagePath       = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData     = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        let person          = Person(name: "Unknown", image: imageName)
        people.append(person)
        save()
        collectionView.reloadData()
        dismiss(animated: true)
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    
    func save() {
        let jsonEncoder     = JSONEncoder()
        
        if let savedData    = try? jsonEncoder.encode(people){
        defaults.set(savedData, forKey: "people")
        }else {
            print("Failed to save people")
        }
    }
    
}


//
//  ViewController.swift
//  NameToFaces
//
//  Created by Andres Gutierrez on 2/6/22.
//

import UIKit

class ViewController: UICollectionViewController {
    
    var people  = [Person]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem    = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Error, could not make cell a PersonCell")
        }
        let person  = people[indexPath.item]
        cell.name.text   = person.name
        
        let path         = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image    = UIImage(contentsOfFile: path.path)
        cell.imageView.layer.borderColor    = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth    = 2
        cell.imageView.layer.cornerRadius   = 3
        cell.layer.cornerRadius             = 7
        
        return cell
    }
    
    
    
    
    
    @objc func addNewPerson() {
        let picker              = UIImagePickerController()
        picker.allowsEditing    = true
        picker.delegate         = self
        present(picker, animated: true)
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
        collectionView.reloadData()
        dismiss(animated: true)
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}


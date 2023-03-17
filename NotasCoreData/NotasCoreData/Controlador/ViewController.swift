//
//  ViewController.swift
//  NotasCoreData
//
//  Created by Ziutzel grajales on 12/12/22.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    //Creamos el arreglo para guardar las listas que creeará el usuario, entre cochetes nos vamos a referir al nombre de la entidad que le pusimos en el core data, pero no olvidemos importar core data aqui para que agarre
    
    //Ahora tenemos que hacer una conexion a la base de datos
    let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var listaTareas : [Tarea] = []
    
    
    @IBOutlet weak var tablaTareas: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Para mostrar información en nuestra tabla
        tablaTareas.delegate = self
        tablaTareas.dataSource = self
        
        leerBaseDatos()
        
    }
    
    @IBAction func addNotaButtonItem(_ sender: UIBarButtonItem) {
        
        var titulo = UITextField()
        
        let alerta = UIAlertController(title: "Agregar", message: "Nueva tarea", preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "Aceptar", style: .default) { _ in
            //Dentro de este clousure realizamos la accion cuando el usuario pulse el boton aceptar
            //Creamos un objeto del tipo Tarea y recibe como parametro el contexto
            let nuevaTarea = Tarea(context : self.contexto)
            nuevaTarea.titulo = titulo.text
            nuevaTarea.realizada = false
            
            //Agregar esa nueva tarea (objeto) al arreglo de tareas , que va a actualizar nuestra vista de patalla
            self.listaTareas.append(nuevaTarea)
            
            //Guardar en la base de datos
            self.guardar()
        }
        
        alerta.addTextField { textFieldAlerta in
            
            textFieldAlerta.placeholder = "Escribe tu nota aqui"
            titulo = textFieldAlerta
            
        }
        alerta.addAction(accionAceptar)
        present(alerta, animated: true)
    }
    
    
    //Antes de agregarle codigo al clousure, debemos crear una funcion para guardar informacion en la base de datos utilizando un try catch para que no nos marque error
    
    
    func guardar() {  //CREATE
        do {
            try self.contexto.save()
            print("Debug : Se guardo en la Base de datos")
        }catch {
            print("Debug : error \(error.localizedDescription)")
        }
        self.tablaTareas.reloadData()
    }
    
    func leerBaseDatos() {  //REED
        
        let solicitud : NSFetchRequest <Tarea> = Tarea.fetchRequest()
        
        do{
            listaTareas = try contexto.fetch(solicitud)
        } catch {
            print ("Debug : error \(error.localizedDescription)")
        }
        
    }
    //Funciones del protocolo
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //retornaremos el total de celdas que este en nuestro array listaTareas
        
        return listaTareas.count
    }
    
    //Recordemos que en esta funcion para retornar una celda debemos crearla
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let celda = tablaTareas.dequeueReusableCell(withIdentifier: "celda" , for: indexPath)
        
        celda.textLabel?.text = listaTareas[indexPath.row].titulo
        
        //Validar si la tarea ya se realizó
        
        let tarea = listaTareas[indexPath.row] //primero extraemos las tareas para poder verificar si se hizo o no con una condicional y ayuda del subtitulo
        
        
        celda.detailTextLabel?.text = tarea.realizada ? "Realizada" : "Por realizar"
        
        //Ahora para la palomita
        celda.accessoryType = tarea.realizada ? .checkmark : .none
        
        return celda
    }
    
    //Seleccionar un elemento de la tabla en el main
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Si esta con el checkmark, quitarselo
        if tablaTareas.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tablaTareas.cellForRow(at: indexPath)?.accessoryType = .none
        }else {
            tablaTareas.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        //Editar en la base de datos si la propiedad de tarea es boolean, (false = verdadero ) o ( verdadero = falso)
        //el ! nos ayudará a invertir los valores de verdadero a falso
        
        listaTareas[indexPath.row].realizada = !listaTareas[indexPath.row].realizada
        self.guardar()
        
    }
        
        
    //Eliminar un elemento seleccionado de nuestra base de datos
        func tableView(_ tableView : UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let accionEliminar = UIContextualAction(style: .normal, title: "" ) { _, _ , _ in
                print ("Eliminar nota")
                //paso 1 eliminar del contex to el obj seleccionado
                
                self.contexto.delete(self.listaTareas[indexPath.row])
                
                //paso 2 eliminar visualmente el elemento
                self.listaTareas.remove(at: indexPath.row)
                
                //paso 3 actualizar tabla y  base de datos
                self.guardar()
                
            }
            accionEliminar.image = UIImage(systemName: "trash")
            accionEliminar.backgroundColor = .red
            return UISwipeActionsConfiguration(actions: [accionEliminar])
        }
        
        //Funcion de eliminar deslizando de izquierda  a derecha
        
        func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let accionEliminar = UIContextualAction(style: .normal, title: "borrar") { _, _, _ in
                print("Eliminar nota")
                //  //1.- Elimina del contexto el obj seleccionadoa
                self.contexto.delete(self.listaTareas[indexPath.row])
                
                //2.- Quitar visualmente el elemto
                self.listaTareas.remove(at: indexPath.row)
                
                //3.- Actualizar la tabla y la bd
                self.guardar()
            }
            //        accionEliminar.image = UIImage(systemName: "trash")
            accionEliminar.backgroundColor = .blue
            
            return UISwipeActionsConfiguration(actions: [accionEliminar])
        }
        
    }


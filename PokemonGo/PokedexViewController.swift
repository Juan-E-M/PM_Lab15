//
//  PokedexViewController.swift
//  PokemonGo
//
//  Created by Mac 10 on 28/06/23.
//

import UIKit

class PokedexViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        pokemonsAtrapados = obtenerPokemonAtrapados()
        pokemonsNoAtrapados = obtenerPokemonNoAtrapados()

    }
    
    @IBOutlet weak var tableView: UITableView!
    var pokemonsAtrapados: [Pokemon] = []
    var pokemonsNoAtrapados: [Pokemon] = []

    
    @IBAction func mapTapped(_ sender: Any) {
        dismiss(animated: true, completion:nil)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pokemon: Pokemon
        let cell = UITableViewCell()
        if indexPath.section == 0 {
            pokemon = pokemonsAtrapados[indexPath.row]
            cell.textLabel?.text = "\(pokemon.nombre!) - \(pokemon.cantidad)"
        } else {
            pokemon = pokemonsNoAtrapados[indexPath.row]
            cell.textLabel?.text = pokemon.nombre
        }
        cell.imageView?.image = UIImage(named: pokemon.imagenNombre!)
        return cell

    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return pokemonsAtrapados.count
        } else {
            return pokemonsNoAtrapados.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Atrapados"
        } else {
            return "No Atrapados"
        }

    }
    
    
    //parte de edición de la tabla
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var pokemonAEliminar = pokemonsAtrapados[indexPath.row]
            pokemonAEliminar.atrapado = false
            pokemonAEliminar.cantidad = 1
            pokemonsAtrapados.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    
}

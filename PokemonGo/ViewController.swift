//
//  ViewController.swift
//  PokemonGo
//
//  Created by Mac 10 on 28/06/23.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {


    
    override func viewDidLoad() {
        super.viewDidLoad()
        ubicacion.delegate = self
        pokemons = obtenerPokemon()
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            setup()
            
            } else {
                ubicacion.requestWhenInUseAuthorization()
            }


    }
    
    
    func setup() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        ubicacion.startUpdatingLocation()
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
            if let coord = self.ubicacion.location?.coordinate {
                let pokemon = self.pokemons[Int(arc4random_uniform(UInt32(self.pokemons.count)))]
                let pin = PokePin(coord: coord, pokemon: pokemon)
                let randomLat = (Double(arc4random_uniform(200))-100.0)/5000.0
                let randomLon = (Double(arc4random_uniform(200))-100.0)/5000.0
                pin.coordinate.latitude += randomLat
                pin.coordinate.longitude += randomLon
                self.mapView.addAnnotation(pin)
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        if status == .authorizedWhenInUse {
            setup()
        }
    }
    
    var ubicacion = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    var contActualizaciones = 0
    var pokemons: [Pokemon] = []
    
    @IBAction func centrarTapped(_ sender: Any) {
        if let coord = ubicacion.location?.coordinate{
            let region = MKCoordinateRegion.init(center: coord, latitudinalMeters: 1000, longitudinalMeters:1000)
            mapView.setRegion(region, animated: true)
            contActualizaciones += 1
        }

    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if contActualizaciones<1 {
            let region = MKCoordinateRegion.init(center: ubicacion.location!.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
            contActualizaciones += 1
        } else {
            ubicacion.stopUpdatingLocation()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            let pinview = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
            pinview.image = UIImage(named: "player")
            var frame = pinview.frame
            frame.size.height = 50
            frame.size.width = 50
            pinview.frame = frame
            return pinview
        }

        let pinview = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        let pokemon = (annotation as! PokePin).pokemon
        pinview.image = UIImage(named: pokemon.imagenNombre!)

        var frame = pinview.frame
        frame.size.height = 50
        frame.size.width = 50
        pinview.frame = frame
        return pinview


    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        if view.annotation is MKUserLocation {
            return
        }
        let region = MKCoordinateRegion.init(center: (view.annotation?.coordinate)!, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(region, animated: true)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (Timer) in
            if let coord = self.ubicacion.location?.coordinate {
                let pokemon = (view.annotation as! PokePin).pokemon
                if mapView.visibleMapRect.contains(MKMapPoint(coord)) {
                    print("Puede atrapar el pokemon")
                    if pokemon.atrapado == true {
                        let alertaVC = UIAlertController(title: "Ya tienes el pokemon!!!", message: "¿Deseas atrapar de nuevo a \(pokemon.nombre!)?", preferredStyle: .alert)
                        let confirmAction = UIAlertAction(title: "si", style: .default) { (accion) in
                            (UIApplication.shared.delegate as! AppDelegate).saveContext()
                            mapView.removeAnnotation(view.annotation!)
                            pokemon.cantidad += 1
                            let alertaVC = UIAlertController(title: "Pokemon repetido atrapado!", message: "Pokemon  \(pokemon.nombre!) atrapado de nuevo", preferredStyle: .alert)
                            let pokedexAccion = UIAlertAction(title: "Ver pokedex", style: .default) { (accion) in
                                self.performSegue(withIdentifier: "pokedexSegue", sender: nil)
                            }
                            alertaVC.addAction(pokedexAccion)
                            self.present(alertaVC, animated: true, completion: nil)
                            
                        }
                        let cancelAction = UIAlertAction(title: "no", style: .default, handler: nil)
                        alertaVC.addAction(confirmAction)
                        alertaVC.addAction(cancelAction)
                        self.present(alertaVC, animated: true, completion: nil)
                    } else{
                        pokemon.atrapado = true
                        //Alerta de pokemon atrapado
                        let alertaVC = UIAlertController(title: "Felicidades!!!", message: "Atrapaste al pokemon \(pokemon.nombre!)", preferredStyle: .alert)
                        let pokedexAccion = UIAlertAction(title: "Ver pokedex", style: .default) { (accion) in
                            self.performSegue(withIdentifier: "pokedexSegue", sender: nil)
                        }
                        alertaVC.addAction(pokedexAccion)
                        self.present(alertaVC, animated: true, completion: nil)
                        (UIApplication.shared.delegate as! AppDelegate).saveContext()
                        mapView.removeAnnotation(view.annotation!)
                    }
                    
                    
                } else {
                    print("No se puede atrapar el pokemon")
                    let alertaVC = UIAlertController(title: "Upss. esta muy lejos", message: "No puede atrapar el pokemon \(pokemon.nombre!), Acercarse más", preferredStyle: .alert)
                    let okAccion = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertaVC.addAction(okAccion)
                    self.present(alertaVC, animated: true, completion: nil)
                    
                }
            }
        }


    }

}


//
//  Pokemon.swift
//  pokedex
//
//  Created by  Tim on 23.01.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import Foundation
import Alamofire


class Pokemon {
    
    private var _name: String!
    private var _pokedexId: Int!
    private var _description: String!
    private var _height: String!
    private var _weight: String!
    private var _defense: String!
    private var _baseAttack: String!
    private var _nextEvolutionTxt: String!
    private var _pokemon_url:String!
    private var _type: String!
    private var _nextEvolutionName: String!
    private var _nextEvolutionId: String!
    private var _nextEvolutionLvl: String!
    
    
    var name: String {
        return _name
    }
    
    var pokedexId: Int {
        return _pokedexId
    }
    
    var type: String {
        if _type == nil {
            _type = ""
        }
        return _type
    }
    
    var nextEvolutionName: String {
        if _nextEvolutionName == nil {
            _nextEvolutionName = ""
        }
        return _nextEvolutionName
    }
    
    var nextEvolutionId: String {
        if _nextEvolutionId == nil {
            _nextEvolutionId = ""
        }
        return _nextEvolutionId
    }
    
    var nextEvolutionLvl: String {
        if _nextEvolutionLvl == nil {
            _nextEvolutionLvl = ""
        }
        return _nextEvolutionLvl
    }
    
    var description: String {
        if _description == nil {
            _description = ""
        }
        return _description
    }
    
    var height: String {
        if _height == nil {
            _height = ""
        }
        return _height
    }
    
    var weight: String {
        if _weight == nil {
            _weight = ""
        }
        return _weight
    }
    
    var defense: String {
        if _defense == nil {
            _defense = ""
        }
        return _defense
    }
    
    var baseAttack: String {
        if _baseAttack == nil {
            _baseAttack = ""
        }
        return _baseAttack
    }
    
    var nextEvolutionTxt: String {
        if _nextEvolutionTxt == nil {
            _nextEvolutionTxt = ""
        }
        return _nextEvolutionTxt
    }
    
    
    init(name: String, pokedexId: Int) {
        
        self._name = name
        self._pokedexId = pokedexId
        //        self._baseAttack = baseAttack
        //        self._defense = defense
        //        self._description = description
        //        self._height = height
        //        self._nextEvolutionTxt = nextEvolutionTxt
        //        self._weight = weight
        
        self._pokemon_url = "\(URL_BASE)\(URL_POKEMON)\(self.pokedexId)/"
        
    }
    
    func downloadPokemonDetails(completed: @escaping DownloadComplete) {
        Alamofire.request(self._pokemon_url, method: .get).responseJSON { response in
            if let dict = response.result.value! as? Dictionary<String, Any> {
                if let weight = dict["weight"] as? String {
                    self._weight = weight
                }
                if let height = dict["height"] as? String {
                    self._height = height
                }
                if let attack = dict["attack"] as? Int {
                    self._baseAttack = "\(attack)"
                }
                if let defense = dict["defense"] as? Int {
                    self._defense = "\(defense)"
                }
                
                if let types = dict["types"] as? [Dictionary<String,String>] , types.count > 0{
                    if let name = types[0]["name"] {
                        self._type = name.capitalized
                    }
                    if types.count > 1 {
                        for x in 1..<types.count {
                            if let name = types[x]["name"] {
                                self._type! += "/\(name.capitalized)"
                            }
                        }
                    }
                } else {
                    self._type = ""
                }
                
                if let descArr = dict["descriptions"] as? [Dictionary<String,String>], descArr.count > 0{
                    if let url = descArr [0]["resource_uri"] {
                        let descURL = "\(URL_BASE)\(url)"
                        Alamofire.request(descURL, method: .get).responseJSON{ response in
                            if let descDict = response.result.value as? Dictionary<String,Any> {
                                if let description = descDict["description"] as? String {
                                    let newDesc = description.replacingOccurrences(of: "POKMON", with: "Pokemon")
                                    self._description = newDesc
                                }
                            }
                            completed()
                        }
                    } else {
                        self._description = ""
                    }
                    
                    if let evolutions = dict["evolutions"] as? [Dictionary<String,Any>] , evolutions.count > 0 {
                        if let nextEvo = evolutions[0]["to"] as? String {
                            if nextEvo.range(of: "mega") == nil {
                                self._nextEvolutionName = nextEvo
                                if let uri = evolutions[0]["resource_uri"] as? String {
                                    let newStr = uri.replacingOccurrences(of: "/api/v1/pokemon/", with: "")
                                    let nextEvoId = newStr.replacingOccurrences(of: "/", with: "")
                                    self._nextEvolutionId = nextEvoId
                                    
                                    if let lvlExist = evolutions[0]["level"] {
                                        if let lvl = lvlExist as? Int {
                                            self._nextEvolutionLvl = "\(lvl)"
                                        }
                                    } else {
                                        self._nextEvolutionLvl = ""
                                    }
                                }
                            }
                        }
                    }
                }
            }
            completed()
        }
        
    }
}

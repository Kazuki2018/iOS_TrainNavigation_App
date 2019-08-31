//
//  SettingTrainController.swift
//  searchTrain_Trial
//
//  Created by 山本　一貴 on 2019/03/07.
//  Copyright © 2019 山本　一貴. All rights reserved.
//

import UIKit
import Foundation

class SettingTrainController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        get_traininfo()
        // Do any additional setup after loading the view.
    }
    
    struct TrainInfo: Codable {
        var train_name: Railway
        var station: [Stations]
        var railway: String
        var ascendingRailDirection:String?
        var descendingRailDirection:String?
        struct Railway: Codable{
            var en: String
            var ja: String
        }
        
        struct Stations: Codable {
            var index: Int
            var station: String
            var StationTitle: Railway
            
            enum CodingKeys: String, CodingKey {
                case index = "odpt:index"
                case station = "odpt:station"
                case StationTitle = "odpt:stationTitle"
            }
            
        }
        
        enum CodingKeys: String, CodingKey {
            case railway = "owl:sameAs"
            case train_name = "odpt:railwayTitle"
            case station = "odpt:stationOrder"
            case ascendingRailDirection = "odpt:ascendingRailDirection"
            case descendingRailDirection = "odpt:descendingRailDirection"
        }
    }
    
    var Railway_name: [TrainInfo] = []
    
    func get_traininfo(){
        guard let req_url = URL(string: "https://api-tokyochallenge.odpt.org/api/v4/odpt:Railway?odpt:operator=odpt.Operator:JR-East&acl:consumerKey=82b96ad4217fe1fc3868f9889f68bf5cd78ee157c41337526dec39b12a64a004") else {
            return
        }
       print(req_url)
        let req = URLRequest(url: req_url)
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: req, completionHandler: {(data, responce, error)in
            session.finishTasksAndInvalidate()
            do {
                let decoder = JSONDecoder()
                self.Railway_name = try decoder.decode([TrainInfo].self, from: data!)
                self.tableView.reloadData()
            } catch {
                print(error)
            }
            })
        task.resume()
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Railway_name.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrainCell", for: indexPath)
        cell.textLabel?.text = Railway_name[indexPath.row].train_name.ja
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let railway = Railway_name[indexPath.row]
        prepare(railway_name: railway)
    }
    
    func prepare(railway_name: TrainInfo){
        let nav = self.navigationController
        let precontroller = nav?.viewControllers[(nav?.viewControllers.count)!-2] as! ViewController
        //precontroller.movefromSetTrain(railway_name: railway_name)
        _ = navigationController?.popViewController(animated: true)
    }

}

//
//  Train_timetable.swift
//  searchTrain_Trial
//
//  Created by 山本　一貴 on 2019/05/10.
//  Copyright © 2019 山本　一貴. All rights reserved.
//

import UIKit
import ISTimeline

class Train_timetable: UIViewController {
    var Traintimetable: Array<Dictionary<String, String>> = []
    
    struct Station_Data: Codable{
        var station_object: Language
        struct Language: Codable{
            var ja: String?
            var en: String?
        }
        enum CodingKeys: String, CodingKey {
            case station_object = "odpt:stationTitle"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frame = CGRect(x: 0.0, y: 20.0, width: 500.0, height: 600.0)
        let timeline = ISTimeline(frame: frame)
        timeline.backgroundColor = .white
        timeline.bubbleColor = .init(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        timeline.titleColor = .black
        timeline.descriptionColor = .darkText
        timeline.pointDiameter = 9.0
        timeline.lineWidth = 4.0
        timeline.bubbleRadius = 0.0
        display(table: self.Traintimetable[0], index: 0, timeline: timeline)
        
    }
    func display(table: Dictionary<String, String>, index: Int, timeline: ISTimeline){
        if index >= self.Traintimetable.count{
            return
        }
        var point: ISPoint
        if let time = table["odpt:departureTime"]{
            point = ISPoint(title: time + "発")
        }else{
            point = ISPoint(title: "到着")
        }
        var st_name : String = ""
        if let t = table["odpt:departureStation"]{
            st_name = t
        }else{
            if let s = table["odpt:arrivalStation"]{
                st_name = s
            }
        }
        self.return_station_janame(Station_name: st_name, finished: {(isSuccess: Bool, ja_name: String) in
            if isSuccess==true{
                point.description = ja_name
                point.lineColor = index % 2 == 0 ? .red : .green
                point.pointColor = point.lineColor
                timeline.points.append(point)
                
                if index+1 < self.Traintimetable.count {
                    self.display(table: self.Traintimetable[index+1], index: index+1, timeline: timeline)
                }else{
                    
                    self.view.addSubview(timeline)
                }
            }else{
                print("cannot do")
            }
        })
        // Do any additional setup after loading the view.
    }
    
    func return_station_janame(Station_name: String, finished: @escaping (Bool, String)->Void){
        var ja_name: String = ""
        let url_string = "https://api-tokyochallenge.odpt.org/api/v4/odpt:Station?owl:sameAs=" + Station_name + "&acl:consumerKey=82b96ad4217fe1fc3868f9889f68bf5cd78ee157c41337526dec39b12a64a004"
        let req_url = URL(string: url_string)
        print(req_url!)
        let req = URLRequest(url: req_url!)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: req, completionHandler: {(data, responce, error)  in
            session.finishTasksAndInvalidate()
            do {
                let decoder = JSONDecoder()
                let station = try decoder.decode([Station_Data].self, from: data!)
                if station.count>0,  let n = station[0].station_object.ja{
                    ja_name = n
                }else {
                    ja_name = "****"
                }
                let _ = finished(true, ja_name)
            } catch {
                print(error)
            }
        })
        task.resume()
    }
    
    
    

}

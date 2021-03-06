//
//  Bus.swift
//  Ruteame
//
//  Created by Roberto Avalos on 07/04/16.
//  Copyright © 2016 Roberto Avalos. All rights reserved.
//

import UIKit
import GoogleMaps

class BusData{
    
    var data: [[String:AnyObject]] = [
        [
            "busName": "Todas",
            "geoJsonName": "todas",
            "color": UIColor(red:0.93, green:0.78, blue:0.87, alpha:1.00),
            "coords": "",
            "southeast": [],
            "northeast": [],
        ],
        [
            "busName": "Ruta 1",
            "geoJsonName": "ruta-1",
            "color": UIColor(red:0.93, green:0.78, blue:0.87, alpha:1.00),
            "coords": "",
            "southeast": [19.220303, -103.758198],
            "northeast": [19.274346, -103.691632],
        ],
        [
            "busName": "Ruta 3",
            "geoJsonName": "ruta-3",
            "color": UIColor(red:0.98, green:0.67, blue:0.73, alpha:1.00),
             "coords": "",
            "southeast": [19.230289, -103.742026],
            "northeast": [19.261267, -103.685827],
        ],
        [
            "busName": "Ruta 4",
            "geoJsonName": "ruta-4",
            "color": UIColor(red:0.86, green:0.51, blue:0.78, alpha:1.00),
             "coords": "",
            "southeast": [19.230316, -103.757132],
            "northeast": [19.257726, -103.684404],
        ],
        [
            "busName": "Ruta 5",
            "geoJsonName": "ruta-5",
            "color": UIColor(red:0.98, green:0.43, blue:0.53, alpha:1.00),
             "coords": "",
            "southeast": [19.231055, -103.763426],
            "northeast": [19.270934, -103.679945],
        ],
        [
            "busName": "Ruta 7",
            "geoJsonName": "ruta-7",
            "color": UIColor(red:0.87, green:0.23, blue:0.48, alpha:1.00),
             "coords": "",
            "southeast": [19.231374, -103.752157],
            "northeast": [19.279845, -103.711515],
        ],
        [
            "busName": "Ruta 9",
            "geoJsonName": "ruta-9",
            "color": UIColor(red:0.72, green:0.86, blue:0.97, alpha:1.00),
             "coords": "",
            "southeast": [19.240856, -103.742893],
            "northeast": [19.301046, -103.721154],
        ],
        [
            "busName": "Ruta 9 A",
            "geoJsonName": "ruta-9-a",
            "color": UIColor(red:0.53, green:0.69, blue:0.82, alpha:1.00),
             "coords": "",
            "southeast": [19.235763, -103.748347],
            "northeast": [19.301063, -103.729649],
        ],
        [
            "busName": "Ruta 10",
            "geoJsonName": "ruta-10",
            "color": UIColor(red:0.33, green:0.80, blue:0.76, alpha:1.00),
             "coords": "",
            "southeast": [19.230698, -103.74202],
            "northeast": [19.261242, -103.686058],
        ],
        [
            "busName": "Ruta 11",
            "geoJsonName": "ruta-11",
            "color": UIColor(red:0.53, green:0.69, blue:0.71, alpha:1.00),
             "coords": "",
            "southeast": [19.230242, -103.748685],
            "northeast": [19.255766, -103.68646],
        ],
        [
            "busName": "Ruta 13",
            "geoJsonName": "ruta-13",
            "color": UIColor(red:0.10, green:0.64, blue:0.79, alpha:1.00),
             "coords": "",
            "southeast": [19.238197, -103.78261],
            "northeast": [19.275463, -103.723606],
        ],
        [
            "busName": "Ruta 13 A",
            "geoJsonName": "ruta-13-a",
            "color": UIColor(red:0.16, green:0.64, blue:0.71, alpha:1.00),
             "coords": "",
            "southeast": [19.238197, -103.78261],
            "northeast": [19.275462, -103.723606],
        ],
        [
            "busName": "Ruta 14",
            "geoJsonName": "ruta-14",
            "color": UIColor(red:0.14, green:0.27, blue:0.45, alpha:1.00),
             "coords": "",
            "southeast": [19.245909, -103.782658],
            "northeast": [19.285289, -103.685938],
        ],
        [
            "busName": "Ruta 15",
            "geoJsonName": "ruta-15",
            "color": UIColor(red:0.99, green:0.88, blue:0.57, alpha:1.00),
             "coords": "",
            "southeast": [19.238248, -103.763781],
            "northeast": [19.281007, -103.723601],
        ],
        [
            "busName": "Ruta 17",
            "geoJsonName": "ruta-17",
            "color": UIColor(red:0.99, green:0.78, blue:0.35, alpha:1.00),
             "coords": "",
            "southeast": [19.223929, -103.746103],
            "northeast": [19.270103, -103.686135],
        ],
        [
            "busName": "Ruta 19",
            "geoJsonName": "ruta-19",
            "color": UIColor(red:0.95, green:0.78, blue:0.68, alpha:1.00),
             "coords": "",
            "southeast": [19.226153, -103.769814],
            "northeast": [19.250339, -103.686354],
        ],
        [
            "busName": "Ruta 20",
            "geoJsonName": "ruta-20",
            "color": UIColor(red:0.51, green:0.47, blue:0.44, alpha:1.00),
             "coords": "",
            "southeast": [19.238437, -103.769314],
            "northeast": [19.270116, -103.686036],
        ],
        [
            "busName": "Ruta 21",
            "geoJsonName": "ruta-21",
            "color": UIColor(red:0.69, green:0.60, blue:0.47, alpha:1.00),
             "coords": "",
            "southeast": [19.229364, -103.74791],
            "northeast": [19.274202, -103.678719],
        ],
        [
            "busName": "Ruta 22",
            "geoJsonName": "ruta-22",
            "color": UIColor(red:0.77, green:0.81, blue:0.55, alpha:1.00),
             "coords": "",
            "southeast": [19.229097, -103.748283],
            "northeast": [19.274414, -103.678596],
        ],
        [
            "busName": "Ruta 24",
            "geoJsonName": "ruta-24",
            "color": UIColor(red:0.75, green:0.81, blue:0.22, alpha:1.00),
             "coords": "",
            "southeast": [19.219686, -103.748652],
            "northeast": [19.27986, -103.694216],
        ],
        [
            "busName": "Ruta 24 A",
            "geoJsonName": "ruta-24-a",
            "color": UIColor(red:0.47, green:0.62, blue:0.45, alpha:1.00),
             "coords": "",
            "southeast": [19.21969, -103.748633],
            "northeast": [19.279868, -103.694208],
        ],
        [
            "busName": "Ruta 27 A",
            "geoJsonName": "ruta-27-a",
            "color": UIColor(red:0.86, green:0.86, blue:0.96, alpha:1.00),
             "coords": "",
            "southeast": [19.245922, -103.742897],
            "northeast": [19.301072, -103.686022],
        ],
        [
            "busName": "Ruta 28",
            "geoJsonName": "ruta-28",
            "color": UIColor(red:0.58, green:0.45, blue:0.65, alpha:1.00),
             "coords": "",
            "southeast": [19.220779, -103.769294],
            "northeast": [19.247429, -103.713774],
        ],
        [
            "busName": "Ruta 29",
            "geoJsonName": "ruta-29",
            "color": UIColor(red:0.58, green:0.06, blue:0.34, alpha:1.00),
             "coords": "",
            "southeast": [19.238249, -103.758202],
            "northeast": [19.290554, -103.723602],
        ],
        [
            "busName": "Ruta a",
            "geoJsonName": "ruta-a",
            "color": UIColor(red:0.78, green:0.24, blue:0.34, alpha:1.00),
             "coords": "",
            "southeast": [19.21244, -103.782657],
            "northeast": [19.274388, -103.68608],
        ],
        [
            "busName": "Ruta b",
            "geoJsonName": "ruta-b",
            "color": UIColor(red:0.82, green:0.48, blue:0.49, alpha:1.00),
             "coords": "",
            "southeast": [19.212468, -103.782607],
            "northeast": [19.275398, -103.6861],
        ],
        [
            "busName": "Ruta cardona",
            "geoJsonName": "ruta-cardona",
            "color": UIColor(red:0.93, green:0.33, blue:0.24, alpha:1.00),
             "coords": "",
            "southeast": [19.225189, -103.725533],
            "northeast": [19.242176, -103.657227],
        ],
    ]
}
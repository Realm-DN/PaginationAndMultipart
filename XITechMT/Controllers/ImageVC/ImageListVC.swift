//
//  ImageListVC.swift
//  XITechMT
//
//  Created by Dev Rana on 17/10/24.
//

import UIKit
import Kingfisher

class ImageListVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var btnLoadMore: LoaderButton!{
        didSet{
            btnLoadMore.layer.borderColor = UIColor.black.cgColor
            btnLoadMore.layer.borderWidth = 1
        }
    }
    
    var imageList: [ImageDataModel] = []
    var current_page: Int? = 0
    
    let refreshControl = UIRefreshControl()
    
    var isReloading = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnLoadMore.setTitle("Click here to load more...", for: .normal)
        self.tableView.register(UINib(nibName: "ImageCell", bundle: nil), forCellReuseIdentifier: "ImageCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.current_page = 0
        self.btnLoadMore.isHidden = true
        loadMoreData {[weak self] success in
            guard let self = self else { return }
            print(success)
            self.tableView.reloadData()
            self.btnLoadMore.isHidden = false
        }
        setupRefreshControl()
    }
    
    func setupRefreshControl(){
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        self.btnLoadMore.isUserInteractionEnabled = false
        self.isReloading = true
        self.current_page = 0
        loadMoreData { success in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                self.tableView.reloadData()
                self.btnLoadMore.isUserInteractionEnabled = true
            }
        }
    }
    
    
    @IBAction func btnLoadMoreAction(_ sender: LoaderButton) {
        print("Tapped")
        sender.isLoading = true
        self.btnLoadMore.isUserInteractionEnabled = false
        let newpage = (self.current_page ?? 0) + 1
        self.current_page = isReloading ? 0 : newpage
        loadMoreData {[weak self] success in
            guard let self = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                sender.isLoading = false
                self.tableView.reloadData()
                self.btnLoadMore.isUserInteractionEnabled = true
            }
        }
    }
    
    func loadMoreData(completion: @escaping ((Bool) -> Void)) {
        fetchData(offset: current_page ?? 0) {[weak self] jsonData in
            guard let self = self else { return }
            if !jsonData.isEmpty{
                if self.isReloading {
                    self.isReloading = false
                    self.imageList.removeAll()
                }
                
                self.imageList.append(contentsOf: jsonData)
                DispatchQueue.main.async {
                    self.btnLoadMore.setTitle("Click here to load more...", for: .normal)
                    completion(true)
                }
            }
            else {
                self.isReloading = true
                DispatchQueue.main.async {
                    self.btnLoadMore.setTitle("Refresh", for: .normal)
                    completion(true)
                }
            }
            
        }
    }
}

extension ImageListVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.imageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ImageCell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageCell
        let urlStr = self.imageList[indexPath.row].xt_image
        let url = URL(string: urlStr ?? "")
        cell.imgMain.kf.setImage(with: url)
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(identifier: "FormVC") as! FormVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
typealias ResultCompletion = ([ImageDataModel]) -> Void
extension ImageListVC{
    func fetchData(offset: Int, completion: @escaping ResultCompletion) {
        guard let url = URL(string: "http://dev3.xicomtechnologies.com/xttest/getdata.php") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let parameters = "user_id=108&offset=\(offset)&type=popular"
        request.httpBody = parameters.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) {[weak self] data, response, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                
                if let jsonData = try? JSONDecoder().decode(DataModel.self, from: data){
                    print("Response jsonData: \(jsonData)")
                    completion(jsonData.images ?? [])
                } else{
                    print("Invalid JSON format")
                }
                
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("Response JSON: \(json)")
                } else {
                    print("Invalid JSON format")
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}

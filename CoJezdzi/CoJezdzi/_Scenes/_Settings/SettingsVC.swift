import UIKit

//import ActionSheetPicker_3_0

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

private struct ViewModel {
    let reuseID: String
    let title  : String

    init(reuseID: String, title: String) {
        self.reuseID = reuseID
        self.title   = title
    }
}

class SettingsVC: UITableViewController {

    var persisatance: SettingsPersistance?
    var picker: UIPickerView?

    fileprivate var cellOrdering: [ViewModel]  {

        let cells = [
            ViewModel(reuseID: C.Storyboard.CellReuseId.SettingsGoingDeeperCell, title: C.UI.Settings.MenuLabels.Filters),
            ViewModel(reuseID: C.Storyboard.CellReuseId.SettingsSwitchCell,      title: C.UI.Settings.MenuLabels.BussesOnly),
            ViewModel(reuseID: C.Storyboard.CellReuseId.SettingsSwitchCell,      title: C.UI.Settings.MenuLabels.TramsOnly),
            ViewModel(reuseID: C.Storyboard.CellReuseId.SettingsSwitchCell,      title: C.UI.Settings.MenuLabels.TramMarks),
            ViewModel(reuseID: C.Storyboard.CellReuseId.SettingsAboutAppCell,    title: C.UI.Settings.MenuLabels.AboutApp)]

        return cells
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate
extension SettingsVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        actionForCell(at: indexPath)
    }
    
    func refresSwitches() {
        guard let persisatance = persisatance else { return } // now work
        
        tableView.visibleCells.forEach { (cell) in
            if cell is SwitchTableViewCell {
                let switchCell = cell as! SwitchTableViewCell

                switch switchCell.switchNameLabel.text! {
                case C.UI.Settings.MenuLabels.TramMarks:
                    switchCell.cellSwitch.setOn(persisatance.showTramMarks, animated: true)
                    
                case C.UI.Settings.MenuLabels.TramsOnly:
                    switchCell.cellSwitch.setOn(persisatance.onlyTrams, animated: true)
                    
                case C.UI.Settings.MenuLabels.BussesOnly:
                    switchCell.cellSwitch.setOn(persisatance.onlyBusses, animated: true)
                    
                default:
                    break
                }
            }
        }
    }
    
    
    fileprivate func actionForCell(at indexPath: IndexPath) {
        let viewModel = cellOrdering[indexPath.row]
        let reuseID = viewModel.reuseID

        switch reuseID {
        case C.Storyboard.CellReuseId.SettingsGoingDeeperCell:
            switch viewModel.title {
            case C.UI.Settings.MenuLabels.Filters:
                break
                
            default:
                print("Unhandled action for cell with title \(viewModel.title)")
            }
            
        case C.Storyboard.CellReuseId.SettingsButtonCell:
            break
            
        case C.Storyboard.CellReuseId.SettingsAboutAppCell:
            break
            
        case C.Storyboard.CellReuseId.SettingsSwitchCell:
            tableView.visibleCells.forEach{ (cell: UITableViewCell) in
                let cellIndex = tableView.indexPath(for: cell)
                if cellIndex == indexPath {
                    let switchCell = cell as! SwitchTableViewCell
                    switchCell.toogle()
                }
            }
            
        default:
            return
        }
    }
}

// MARK: -
private typealias CellConfiguration = SettingsVC
extension CellConfiguration {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellOrdering.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCell(at: indexPath)
    }
    
    // MARK: Helpers
    func configureCell(at indexPath: IndexPath) -> UITableViewCell {
        let viewModel = cellOrdering[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.reuseID, for: indexPath)
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
    
    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        let viewModel = cellOrdering[indexPath.row]
        
        switch viewModel.reuseID {
        case C.Storyboard.CellReuseId.SettingsSwitchCell:
            let switchCell = cell as! SwitchTableViewCell
            switchCell.delegate = self
            configureSwitchCell(cell: switchCell, atIndexPath: indexPath)
            
        case C.Storyboard.CellReuseId.SettingsGoingDeeperCell:
            configureDeeper(cell: cell, with: viewModel)
            
        case C.Storyboard.CellReuseId.SettingsButtonCell:
            configureButton(cell: (cell as! ButtonTableViewCell), viewModel: viewModel)
            
        case C.Storyboard.CellReuseId.SettingsAboutAppCell:
            configureAboutApplicationCell(cell: cell, viewModel: viewModel)
            
        default:
            fatalError("Unhandled Cell Reuse ID: \(viewModel.reuseID)")
        }
    }
    
    private func configureDeeper(cell: UITableViewCell, with viewModel: ViewModel) {
        
        switch viewModel.title {
        case C.UI.Settings.MenuLabels.Filters:
            cell.textLabel?.text = "Wybierz Linie"
            cell.detailTextLabel?.text = "Wszystkie"
            
            if let selectedLines = persisatance?.selectedLines, selectedLines.count > 0 {
                cell.detailTextLabel?.text = selectedLines.joined(separator: ", ")
            }
            
        default:
            print("Unhandled title for deeper cell with title \(viewModel.title)")
        }
    }
    
    private func configureButton(cell: ButtonTableViewCell, viewModel: ViewModel) {
        cell.button.setTitle(viewModel.title, for: UIControlState())
    }
    
    private func configureAboutApplicationCell(cell: UITableViewCell, viewModel: ViewModel) {
        cell.textLabel?.text = viewModel.title
    }
    
    func configureSwitchCell(cell: SwitchTableViewCell, atIndexPath indexPath: IndexPath) {
        
        guard indexPath.row < cellOrdering.count else { return } // this is a error, some kind of log?
        guard let persisatance = persisatance else { return } // no persistance no work
        
        let viewModel = cellOrdering[indexPath.row]
        
        // updates the title
        cell.switchNameLabel.text = viewModel.title
        
        cell.cellSwitch.isOn = {
            switch viewModel.title {
            case C.UI.Settings.MenuLabels.TramMarks:
                return persisatance.showTramMarks
                
            case C.UI.Settings.MenuLabels.TramsOnly:
                return persisatance.onlyTrams
                
            case C.UI.Settings.MenuLabels.BussesOnly:
                return persisatance.onlyBusses
                
            default:
                print("\(#file) \(#line) -> Does not have a cell with this title: \(viewModel.title)")
                return false
            }
        }()
    }
    
    func refreshVisibleRows() {
        guard let visibleIndexes = tableView.indexPathsForVisibleRows else {
            return
        }

        tableView.reloadRows(at: visibleIndexes, with: .automatic)
    }
}

//MARK: -
extension SettingsVC: SwitchCellInteraction {
    func cellSwichValueDidChange(cell: SwitchTableViewCell, isOn: Bool) {
        guard let persisatance = persisatance else { return } // now work
        guard let cellTitle = cell.switchNameLabel.text else { return }

        switch cellTitle {
        case C.UI.Settings.MenuLabels.TramMarks:
            persisatance.showTramMarks = isOn
            
        case C.UI.Settings.MenuLabels.TramsOnly:
            persisatance.onlyTrams = isOn
            
        case C.UI.Settings.MenuLabels.BussesOnly:
            persisatance.onlyBusses = isOn

        default:
            print("\(#file) \(#line) -> No valid action for cell with title: \(String(describing: cell.switchNameLabel.text))")
        }
        
        refresSwitches()
    }
}

//: MARK: - FilerResultHandler
extension SettingsVC: FilerResultHandler {
    func selectedLines(_ lines: [String]) {
        if let per = persisatance {
            per.selectedLines = lines

            // 😱: relax it just finds the index and does somthing when it's not nil 😋
            if let index = cellOrdering.index(where: {$0.reuseID == C.Storyboard.CellReuseId.SettingsGoingDeeperCell}) {

                let indexPath = IndexPath.init(item: index, section: 0)
                tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
    }
}

// MARK: -
private typealias UserInteraction = SettingsVC
extension UserInteraction {
    @IBAction func uderDidTapCancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion:nil)
    }
}

// MARK: -
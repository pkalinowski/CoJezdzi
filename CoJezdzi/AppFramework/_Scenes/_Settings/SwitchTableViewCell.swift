import UIKit

protocol SwitchCellInteraction: class {
    func cellSwichValueDidChange(cell: SwitchTableViewCell, isOn: Bool)
}

class SwitchTableViewCell: UITableViewCell {

    @IBOutlet weak var cellSwitch: UISwitch!
    @IBOutlet weak var switchNameLabel: UILabel!
    
    weak var delegate: SwitchCellInteraction?

    @IBAction func userDidInteractWithSwitch(_ sender: UISwitch) {
        delegate?.cellSwichValueDidChange(cell: self, isOn: sender.isOn)
    }
    
    func updateSwitchState(_ state: Bool) {
        cellSwitch.setOn(state, animated: true)
    }
}

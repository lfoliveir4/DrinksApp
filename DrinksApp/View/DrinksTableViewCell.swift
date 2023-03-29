import UIKit

class DrinksTableViewCell: UITableViewCell {
    let imageDrink = UIImageView()
    let titleDrink = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        imageDrink.contentMode = .scaleAspectFit
        addSubview(imageDrink)

        titleDrink.textAlignment = .center
        titleDrink.font = UIFont.systemFont(ofSize: 16)
        addSubview(titleDrink)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        imageDrink.frame = CGRect(x: 10, y: 10, width: 30, height: 30)
        titleDrink.frame = CGRect(x: 50, y: 10, width: contentView.frame.width - 60, height: contentView.frame.height - 20)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


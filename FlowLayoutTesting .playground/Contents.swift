import UIKit
import Foundation
import PlaygroundSupport

// Класс ячейки должен наследоваться от `UICollectionViewCell`.
// Ключевое слово final позволяет немного ускорить компиляцию и гарантирует, что от класса не будет никаких наследников.
final class ColorCell: UICollectionViewCell {
    
    // Идентификатор ячейки — используется для регистрации и восстановления:
    static let identifier = "ColorCell"
    
    // Конструктор:
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Закруглим края для ячейки:
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

// Основной класс, в котором мы будем выполнять эксперименты;
// он же является `UICollectionViewDataSource`, поставщиком данных для коллекции:
final class SupplementaryCollection: NSObject, UICollectionViewDataSource {
    
    private let params: GeometricParams
    
    private let colors: [UIColor] = [
        .black, .blue, .brown,
        .cyan, .green, .orange,
        .red, .purple, .yellow
    ]
    
    let count: Int
    
    init(count: Int, using params: GeometricParams) {
        self.count = count
        self.params = params
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier,
                                                            
                                                            for: indexPath) as? ColorCell else {
            return UICollectionViewCell()
        }
        
        cell.prepareForReuse()
        
        // Произвольно выбираем цвет для фона ячейки:
        cell.contentView.backgroundColor = colors[Int.random(in: 0..<colors.count)]
        
        return cell
    }
}
    // MARK: - UICollectionViewDelegateFlowLayout
//сообщим, что класс SupplementaryCollection реализует протокол UICollectionViewDelegateFlowLayout.
extension SupplementaryCollection: UICollectionViewDelegateFlowLayout {
    
    //задает размеры ячейки коллекции (Расчёт размеров ячейки выполняем на основе значений из структуры params.paddingWidth)
    // (изменим возвращаемый размер ячейки)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        let height: CGFloat
        // Рассчитаем высоту.
        if indexPath.row % 6 < 2 {
            height = 2 / 3
        } else {
            height = 1 / 3
        }
        return CGSize(width: cellWidth,
                     height: cellWidth * 2 / 3)
    }
    
    //задаeт отступы от краёв коллекци
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: params.leftInset, bottom: 10, right: params.rightInset)
    }
    
    // отвечает за вертикальные отступы
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
    // отвечает за горизонтальные отступы между ячейками
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
    
}

struct GeometricParams {
    let cellCount: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpacing: CGFloat
    // Параметр вычисляется уже при создании, что экономит время на вычислениях при отрисовке коллекции.
    let paddingWidth: CGFloat
    
    init(cellCount: Int, leftInset: CGFloat, rightInset: CGFloat, cellSpacing: CGFloat) {
        self.cellCount = cellCount
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.cellSpacing = cellSpacing
        self.paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
    }
}

// Размеры для коллекции:
//(изменим размеры коллекции и параметры нашего FlowLayout - height: 400)
let size = CGRect(origin: CGPoint(x: 0, y: 0),
                  size: CGSize(width: 400, height: 400))
// Указываем, какой Layout хотим использовать:
let layout = UICollectionViewFlowLayout()

let collection = UICollectionView(frame: size,
                                  collectionViewLayout: layout)

//экземпляр структуры и передать её в конструктор класса-помощника:
//(три колонки теперь)
let params = GeometricParams(cellCount: 3,
                             leftInset: 10,
                             rightInset: 10,
                             cellSpacing: 10)
let helper = SupplementaryCollection(count: 31, using: params)

// Изменим направление скроллинга с вертикального (по умолчанию) на горизонтальное.
layout.scrollDirection = .horizontal

// Регистрируем ячейку в коллекции.
// Регистрируя ячейку, мы сообщаем коллекции, какими типами ячеек она может распоряжаться.
// При попытке создать ячейку с незарегистрированным идентификатором коллекция выдаст ошибку.
collection.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
collection.backgroundColor = .lightGray
collection.dataSource = helper
collection.delegate = helper

PlaygroundPage.current.liveView = collection

collection.reloadData()

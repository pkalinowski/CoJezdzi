
import ReSwift

protocol PersistanceProtocol {
    func load()
}

class Persistence: Dependable, PersistanceProtocol {
    var dependencyContainer: DependencyStore
    
    init(container: DependencyStore) {
        dependencyContainer = container
    }
    
    enum Keys {
        static let persistance = "Persistance.SettingsState"
    }
    
    func persist(state: SettingsState) {
        let data = try! JSONEncoder().encode(state)
        UserDefaults.standard.set(data, forKey: Keys.persistance)
    }
    
    func load() {
        defer {
            dependencyContainer.reduxStore.subscribe(self) {
                $0.select {
                    $0.settingsState
                }
            }
        }
        
        // TODO: move to bg queue
        
        guard let data = UserDefaults.standard.data(forKey: Keys.persistance) else { return }
        let state = try! JSONDecoder().decode(SettingsState.self, from: data)
        
        dependencyContainer.reduxStore.dispatch(SettingsDidRestoreAction(restoredState: state))
    }
}

// MARK: - ReSwift

extension Persistence: StoreSubscriber {
    func newState(state: SettingsState) {
        persist(state: state)
    }
}
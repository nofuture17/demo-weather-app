
class ModelError: AppError {
    override class var defaultDomain: String {
        return "RonasWeather.model"
    }
    override class var defaultCode: Int {
        return 200
    }
}

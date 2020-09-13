class ViewError: AppError {
    override class var defaultDomain: String {
        return "RonasWeather.view"
    }
    override class var defaultCode: Int {
        return 300
    }
}

enum ApiEndpoint {
  getUsers('/Staff'),
  getUsersByName('/Staff'),
  getUserByStaffId('/Staff/{staffId}'),
  updateUser('/Staff/security'),

  getUserById('/users/{id}'),

  getUserCategories('/CanteenSetting/userCategories'),
  getUserCategoryById('/CanteenSetting/userCategory/{id}'),

  getMeals('/Meal/mealSetup'),
  getActiveMeals('/Meal/activeMealSetup'),
  getMealById('/Meal/meal/{id}'),
  getMealTimes('/Meal/mealTime'),
  getMealTimeById('/Meal/mealTime/{id}'),
  getMealRosterIds('/Meal/roster'),
  getRostersById('/Meal/mealRoster/{id}'),
  getRosterByUserId('/Meal/mealRoster/{userId}'),

  getCanteenSettings('/CanteenSetting'),
  getCanteenSettingById('/CanteenSetting/location/{id}'),

  getServiceProviders('/ServiceProvider'),
  getActiveServiceProviders('/ServiceProvider/active'),
  getServiceProviderById('/ServiceProvider/serviceProvider/{id}'),

  getAllDeviceSetUps('/DeviceSetup'),
  getDeviceSetUpByCode('/DeviceSetup/deviceSetup/{code}'),
  getPhysicalDeviceBySerialNumber(
    '/DeviceSetup/physicaldeviceSetup/{serial}',
  ),
  setUpDevice('/DeviceSetup/physicalDevice'),

  getAllOrders('/Order/orders'),
  getOrdersByEmployeeId('/Order/order/{employeeId}'),
  getOrderDetailsByOrderId('/Order/orderDetail/{orderId}'),
  createOrder('/Order'),
  serveOrder('/Order'),

  uploadFile('/Files/upload'),

  createBatchOrder('/Order/badgeEntity'),
  clockInMeal('/Order/clockInMeal'),
  proxyClockInMeal('/Order/pickFor'),
  visitorClockInMeal('/Order/visitor-meal'),

  getOrderDataByOrderId('/Order/orderdata'),
  getOrderByOrderId('/Order/orderdata'),

  getBatchOrdersByUserId('/Order/badgedFood/{userId}'),
  getBatchAllOrders('/Order/badgedFoods'),

  createServeOrder('/Order');

  const ApiEndpoint(this.endPoint);

  final String endPoint;
}
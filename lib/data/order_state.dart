enum OrderState {
  newOrder,
  newOrderCalculating,
  newOrderCalculated,
  searchCar,
  driveToClient,
  driveAtClient,
  paidIdle,
  clientInCar;

  bool get isNewOrderAlarmPlay {
    if (this == OrderState.searchCar) return true;
    if (this == OrderState.driveToClient) return true;
    if (this == OrderState.driveAtClient) return true;
    if (this == OrderState.paidIdle) return true;
    if (this == OrderState.clientInCar) return true;
    return false;
  }
}

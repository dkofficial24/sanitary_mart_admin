import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sanitary_mart_admin/core/core.dart';
import 'package:sanitary_mart_admin/incentive_points/model/incentive_point_model.dart';
import 'package:sanitary_mart_admin/incentive_points/service/incentive_provider_service.dart';

class IncentivePointsProvider extends ChangeNotifier {
  ProviderState providerState = ProviderState.idle;

  List<IncentivePointInfo> incentivePointHistory = [];
  num totalPoints = 0;

  Future fetchTotalIncentivePoints(String uId) async {
    try {
      providerState = ProviderState.loading;
      IncentivePointService incentivePointService = Get.find();
      totalPoints = await incentivePointService.getTotalIncentivePoints(uId);
      providerState = ProviderState.idle;
    } catch (e) {
      providerState = ProviderState.error;
    } finally {
      notifyListeners();
    }
  }

  Future fetchIncentivePointsHistory(String uId) async {
    try {
      providerState = ProviderState.loading;
      IncentivePointService incentivePointService = Get.find();
      incentivePointHistory =
      await incentivePointService.getIncentivePointsHistory(uId);
      notifyListeners();
      providerState = ProviderState.idle;
    } catch (e) {
      //todo show error msg
      providerState = ProviderState.error;
    }
  }

  Future<void> incrementIncentivePoints(String uId, double points) async {
    try {
      providerState = ProviderState.loading;
      IncentivePointService incentivePointService = Get.find();
      await incentivePointService.incrementIncentivePoints(uId, points);
      await fetchTotalIncentivePoints(uId);
      notifyListeners();
      providerState = ProviderState.idle;
    } catch (e) {
      providerState = ProviderState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> decrementIncentivePoints(String uId, double points) async {
    try {
      providerState = ProviderState.loading;
      IncentivePointService incentivePointService = Get.find();
      await incentivePointService.decrementIncentivePoints(uId, points);
      await fetchTotalIncentivePoints(uId);
      notifyListeners();
      providerState = ProviderState.idle;
    } catch (e) {
      //todo show error msg
      providerState = ProviderState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateIncentiveRedeemStatus(
      String uId,
      RedeemStatus redeemStatus,
      String incentivePointId,
      ) async {
    try {
      providerState = ProviderState.loading;
      IncentivePointService incentivePointService = Get.find();
      await incentivePointService.updateIncentiveRedeemStatus(
          uId, redeemStatus, incentivePointId);
      await fetchIncentivePointsHistory(uId);
      notifyListeners();
      providerState = ProviderState.idle;
    } catch (e) {
      //todo show error msg
      providerState = ProviderState.error;
    }
  }
}


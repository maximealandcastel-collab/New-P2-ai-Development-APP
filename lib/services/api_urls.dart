import 'package:pler_to_pler_app/core/constants/api_constants.dart';

    /// Thin URL wrapper used by the paywall/promo flow.
    /// All other features use [ApiConstants] directly.
    class ApiUrls {
    ApiUrls._();

    static const String _base = ApiConstants.baseUrl;

    /// In-app purchase receipt verification
    static const String iapVerify = '${_base}/api/v1/iap/verify';

    /// Promo-code endpoints
    static const String promoValidate = '${_base}/api/v1/promo/validate';
    static const String promoRedeem   = '${_base}/api/v1/promo/redeem';
    }
    
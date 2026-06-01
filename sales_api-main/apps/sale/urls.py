from rest_framework import routers
from apps.sale.views import SaleViewSet

router = routers.DefaultRouter()
router.register('sales', SaleViewSet)

urlpatterns = router.urls
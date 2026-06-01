from rest_framework.routers import DefaultRouter
from apps.provider.views import ProviderViewSet

router = DefaultRouter()
router.register(r'providers', ProviderViewSet)

urlpatterns = router.urls
from rest_framework import routers
from apps.client.views import ClientViewSet

router = routers.DefaultRouter()
router.register('clients', ClientViewSet)

urlpatterns = router.urls